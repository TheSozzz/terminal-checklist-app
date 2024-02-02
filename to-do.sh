#!/bin/bash

#create new checklist directory 
scriptDir=$(dirname "$0")
listDir="$scriptDir/checklistAppLists"
settingsFile="$scriptDir/checklistAppSettings.txt"

if ! [ -d "$listDir" ]; then
	mkdir "$scriptDir/checklistAppLists"
fi

if ! [ -e "$settingsFile" ]; then #if the settings file doesn't exist, make it with init params. 
	echo >> "$scriptDir/checklistAppSettings.txt"
	echo "listOpen=0" > "$settingsFile"
	echo "currentList=-1" >> "$settingsFile"
fi

#global variables
taskList=()			#items in current file being read

function readSettingsFile() {
	ogIFS=IFS 
	while IFS= read -r line; do #creates everything (that's specified in if statement) in the settings file as a var. 
		IFS="=" read -r name value <<< "$line"
		IFS=$ogIFS
		if [[ "$name" == "listOpen" ]]; then
			listOpen=$value
		elif [[ "$name" == "currentList" ]]; then
			currentList=$value
		fi
	done < "$settingsFile"
}

function setSettingsFile() {
	toFind=$1
	newVal=$2
	sed -i "$line s/$toFind.*/$toFind=$newVal/" "$settingsFile"
}

#create list of lists 
function makeListList() { 
	listList=()
	for list in "$listDir"/*.txt; do
		[ -e "$list" ] || continue
		listList+=("$(basename "$list")")
	done
}

#create new text file
function makeFile() { 
	for name in "$@"; do
		matched=false
		for list in "${listList[@]}"; do
			if [[ "$list" == "$name".txt ]]; then
				matched=true;
				echo "Error: can't create list \"$name\". List with this name already exists."	
			fi
		done
		if [[ $matched == false ]]; then
			echo >> "$scriptDir/checklistAppLists/$name.txt"
		fi
	done
}

function deleteFile() { 
	for index in "$@"; do
		if [[ "$index" =~ ^"a"("ll")? ]]; then
			for list in "${listList[@]}"; do 
				rm "$scriptDir/checklistAppLists/$list"
			done
		elif [ $index -ge ${#listList[@]} ] || [ $index -lt 0 ]; then 
			echo "Error: can't delete list number ($index). List does not exist. "
		else
			rm "$scriptDir/checklistAppLists/${listList[$index]}"
		fi
	done
}

function renameFile() {
	array=("$@")
	for (( i=0; i<${#array[@]}; i+=2 )); do
		n="${array[i]}"
		newName="${array[i+1]}"
		mv "$listDir/${listList[$n]}" "$listDir/$newName.txt"
	done
}

function readFile() { #create list of items in text file
	while IFS= read -r line; do 
		if [ -n "$line" ]; then
			taskList+=("$line")
		fi
	done < "$listDir/${listList[$currentList]}"
}

#write to txt file
function writeToFile() {
	array=("$@")
	echo "${array[0]}" > "$listDir/${listList[$currentList]}"
	for line in "${array[@]:1}"; do
		echo "$line" >> "$listDir/${listList[$currentList]}"
	done
}

#operation functions
function finish() {
	if [ "$1" = "a" ] || [ "$1" = "all" ]; then
		for (( index=0; index<${#taskList[@]}; index++ )); do
			if [ "${taskList[$index]:0:4}" != "{fi}" ]; then
				taskList[index]="{fi}"${taskList[index]}
			fi
		done
	else
		for arg in "$@"; do
			if [ $arg -ge ${#taskList[@]} ]; then
				echo "Item ($arg) - Not on list, cannot mark finished"
			elif [ "${taskList[$arg]:0:4}" != "{fi}" ]; then
				taskList[$arg]="{fi}${taskList[$arg]}"
			fi
		done
	fi
	writeToFile "${taskList[@]}"
}

function xfinish() {
	if [ "$1" = "a" ] || [ "$1" = "all" ]; then
		for (( index=0; index<${#taskList[@]}; index++ )); do
			if [ "${taskList[$index]:0:4}" = "{fi}" ]; then
				taskList[$index]=${taskList[$index]:4}
			fi
		done
	else
		for arg in $@; do
			if [ $arg -ge ${#taskList[@]} ]; then
				echo "Item ($arg) - Not on list, cannot mark unfinished"
			elif [ "${taskList[$arg]:0:4}" = "{fi}" ]; then
				taskList[$arg]="${taskList[$arg]:4}"
			fi
		done
	fi
	writeToFile "${taskList[@]}"
}

function delete() {
	for arg in $@; do
		if [ $arg = "a" ] || [ $arg = "all" ]; then
			taskList=()
		elif [ $arg -ge ${#taskList[@]} ]; then
			echo "Item ($arg) - Not on list, cannot delete >:"
		else
			unset taskList[$arg]
		fi
	done	
	writeToFile "${taskList[@]}"
}

function add() {
	for item in "$@"; do
		taskList+=("$item")
	done  
	writeToFile "${taskList[@]}"
}

function edit() {
	for item in "$@"; do
		text=$( echo "$item" | cut -d "_" -f 2)
		n=$( echo $item | cut -d "_" -f 1)
		if [ $n -ge ${#taskList[@]} ]; then
			echo "Item ($n) - Not on list, cannot edit >:"
		else
			taskList[$n]="$text"
		fi
	done
	writeToFile "${taskList[@]}"
}

#display task list
function showListItems() {
	count=0
	echo "========================================"
	echo " ${listList[$currentList]} "
	echo "----------------------------------------"
	if [ ${#taskList[@]} -gt 0 ]; then
		for item in "${taskList[@]}"; do
			if [ "${item:0:4}" = "{fi}" ]; then
				echo "[$count] ${item:4}"
			else
				echo "<$count> $item"
			fi
			((count=count+1))
		done
	else
	echo " List is empty ¯\_(ツ)_/¯"
	fi 
	echo "----------------------------------------"	
}



#list list names
function showLists() {
	if [[ -z "$@" ]]; then
		echo "========================================"
		echo " YOUR CURRENT LISTS:"
		echo "----------------------------------------"
		if [ ${#listList[@]} -gt 0 ]; then
			for index in ${!listList[@]}; do
				echo "$index. ${listList[$index]%.*}"
			done

		else
			echo " No lists right now ¯\_\(ツ\)_/¯"
			echo " To create a new list, use: create name_of_list"
		fi 
		echo "========================================"
	fi
}

#make list List before so commands can be used
readSettingsFile
makeListList

#select in list operation
if [ "$listOpen" = 1 ]; then
	if [ "$1" = "q" ] || [ "$1" = "quit" ]; then
		setSettingsFile "listOpen" 0
		setSettingsFile "currentList" -1
		readSettingsFile
		showLists
	else 
		readFile
		if [ "$1" = "d" ] || [ "$1" = "delete" ]; then
			delete "${@:2}"
		elif [ "$1" = "a" ] || [ "$1" = "add" ]; then
			add "${@:2}"
		elif [ "$1" = "e" ] || [ "$1" = "edit" ]; then
			edit "${@:2}"
		elif [ "$1" = "f" ] || [ "$1" = "finish" ]; then
			finish "${@:2}"
		elif [ "$1" = "xf" ] || [ "$1" = "xfinish" ]; then
			xfinish "${@:2}"
		fi
		showListItems
	fi
else
	if [[ $1 =~ ^[0-9]+$ ]] && [[ $1 -lt ${#listList[@]} ]] && [[ $1 -ge 0 ]]; then 
		setSettingsFile "listOpen" 1
		setSettingsFile "currentList" "$1"
		readSettingsFile #actually updates the variables, not just the text file
		readFile 
		showListItems
	else
		if [ "$1" = "create" ] || [ "$1" = "c" ]; then
			makeFile "${@:2}"
		elif [ "$1" = "delete" ] || [ "$1" = "d" ]; then
			deleteFile "${@:2}"
		elif [ "$1" = "rename" ] || [ "$1" = "r" ]; then
			renameFile "${@:2}" 
		fi
		makeListList
		showLists
	fi
fi
