# Adrian Dizon's Project 01

## Prompt:
##### For the prompt, I decided to go with the built in prompt instead of read. I chose to do this because I want the user to enter multiple commands/functions they want to use and my script would be able to run them all. In order to choose the function to be performed, the user has to type in one or more of the commands that will be listed below (if the user is using more than one command, it must be separated with spaces)

## NOTE:
#### If you are going to input more than one function, make sure to separate it by spaces
##### Example: ./project_analyze.sh todo FileCount FileSize

## TODO Function:
##### The TODO function finds the lines of files where #TODO is located. It will print these lines in a file labeled todo.log
##### To access this function, enter "todo" (no quote) next to ./project_analyze.sh
##### To access the lines with #TODO enter "less todo.log" (no quotes) in the command line
##### Example: ./project_analyze.sh todo

## FileCount Function:
##### The FileCount function finds the files ending with .html, .js, .css, .py, .hs, and .sh. It will count the number of files with these extensions and display the result to the user
##### To access this function, enter "FileCount" (no quotes) next to ./project_analyze.sh
##### Example: ./project_analyze.sh FileCount

## Custom Function: FileSize Function:
##### The FileSize function prompts the user to enter a minimum file size and the FileSize function will list all the files that are greater than or equal to the specified file size. It will then ask the user If they want to delete, list the files in another file, or do nothing with them.
##### If you enter:
- 1: It will allow you to delete a file. It will ask for the path to the file you want deleted. You can copy and paste this from the list of the files with a size that is greater than or equal to the specified size
- 2: It will put all the files that are greater than or equal to the specified size into a file called fileSizes.txt. To access this, just type "less fileSizes.txt" (no quotes)
- If you enter any other number, the function will not do anything with the files and close the function
##### To access this function, enter "FileSize" (no quotes) next to ./project_analyze.sh
##### Example: ./project_analyze.sh FileSize

