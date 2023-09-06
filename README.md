# terminal-tasklist-app
A basic tasklist app accessible through the terminal. It works by creating a text file called 

To print the tasklist to terminal, just run the file without inputting any commands. To make this easier you can give the file an alias, such as 

`alias task="location_of_file`

The program can add, delete, edit, and mark tasks finished/unfinished. In order for the command to be completed it must be put in after referencing the file:

`./location_of_program command additional_inputs`

The commands are:
- **to add**

  command = **a** / **add**
  
  additional inputs = **"new tasklist item in quotes" "you can add multiple at a time"**
  
  example = `./location_of_program a "sharpen pencils" "clean keyboard" "buy milk"`

- **to delete**

  command = **d** / **delete**

  additional inputs = **numbers of lines to delete separated by space OR a / all , to delete all**

  example = `./location_of_program d 0 4 5`  `./location_of_program d a`

- **to edit**

  command = **e** / **edit**

  additional inputs = **"1_number of line you want to edit, followed by underscore followed by new text in quotes" "this can be done for multiple lines"**

  example = `./location_of_program e "0_replace sharpener" "1_get typewriter" "2_make milkshake"`

- **to mark finished**

  command = **f** / **finish**

  additional inputs = **numbers of lines to mark finished separated by space OR a / all , to finish all**

  example = `./location_of_program f 2 5 3`  `./location_of_program f a`

- **to mark unfinished**  (tasks are unfinished by default)
  
  command = **xf** / **xfinish**

  additional inputs = **numbers of lines to mark unfinished separated by space OR a / all , to finish all**

  example = `./location_of_program xf 0 2 3`  `./location_of_program xf a`

