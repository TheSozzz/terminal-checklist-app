#!/bin/sh

#create list of items
file="/home/orca/Documents/scripts/assets/taskList.txt"

taskList=()
while IFS= read -r line
do 
	if [ -n "$line" ]; then
		taskList+=("$line")
	fi
done < "$file"

#write to txt file
function writeToFile() {
	array=("$@")
	echo "${array[0]}" > "$file"
	for line in "${array[@]:1}"; do
		echo "$line" >> "$file"
	done
}

#operation functions
function finish() {
	if [ "$1" = "a" ] || [ "$1" = "all" ]; then
		for (( index=0; index<${#taskList[@]}; index++ )); do
			if [ "${taskList[$index]:0:4}" != "{fi}" ]; then
				taskList[$index]="{fi}"${taskList[$index]}
			fi
		done
	else
		for arg in $@; do
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
#select operation
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


#display task list
count=0
echo "========================================"
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


