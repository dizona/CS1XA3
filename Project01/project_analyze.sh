#!/bin/bash
#all files are relative to CS1XA3
cd ..

#Loops through all the function the user specifies
for userInput in "$@"
do
	#todo function
  	if [ "$userInput" = "todo" ]; then
		#Checks if the todo.log file exists and it will delete it if it does and create a new one
		if [ -f ./Project01/todo.log ]; then
			rm ./Project01/todo.log
			touch ./Project01/todo.log
		else
			touch ./Project01/todo.log
		fi
		
		#Checks through all the files with "#TODO" and send the lines with "#TODO" to the file todo.log
		grep -r --exclude={project_analyze.sh,todo.log} --exclude-dir=.git "#TODO" ./ >> ./Project01/todo.log
	
	#FileCount function
	elif [ "$userInput" = "FileCount" ]; then
		
		#Checks the occurances of files with certain extensions and will count them. The result will be returned to the user
		html=$(find ./ -iname "*.html" | wc -l)
		echo "HTML: $html"
		javaScript=$(find ./ -iname "*.js" | wc -l)
		echo "JavaScript: $javaScript"
		css=$(find ./ -iname "*.css" | wc -l)
		echo "CSS: $css"
		python=$(find ./ -iname "*.py" | wc -l)
		echo "Python: $python"
		haskell=$(find ./ -iname "*.hs" | wc -l)
		echo "Haskell: $haskell" 
		bash=$(find ./ -iname "*.sh" | wc -l)
		echo "Bash: $bash"
	
	#Custom Feature: FileSize function
	elif [ "$userInput" = "FileSize" ]; then
		#Prompts the user to enter a minimum file size they want to look for
		read -p "Enter the minimum size of the files you wish to look for (in bytes): " fileSize
		echo "These are the files that have the size that is greater than or equal to $fileSize : "
		echo ""

		#Finds The files that are >= to the specified file size
		find ./ -path ./.git -prune -o -type f ! -name 'project_analyze.sh' -size +"$fileSize"c -print0 | while IFS= read -d $'\0' file
		do
			sizeOfFile=$(stat -c%s "$file")
			echo $file
			echo "> The size of $file = $sizeOfFile bytes."
			echo ""

		done
		
		#Prompts the user about what they want to do with the files
		read -p "What would you like to do with them? Enter:
		1 to remove a specified file
		2 to put a list of them in a file
		Any number (e.g. 3, 4, 5, etc.) to do nothing with them
		Enter choice here: " fileChoice
		
		#If the user enters "1" the user will be able to remove a specified file
		if [ "$fileChoice" = "1" ]; then
			read -p "Enter the exact path of the file you wish to remove. You can copy and paste the path of the file from above: " deleteFile

			#Deletes the file
			rm "$deleteFile"
			echo "The file has been removed"
			echo ""
		
		#If the user enters "2" the files that are >= to the specified file size will be put in a file called fileSizes.txt
		elif [ "$fileChoice" = "2" ]; then
			#Checks if the file fileSize exists and will delete and create a new one if it does
			if [ -f ./Project01/fileSizes.txt ]; then
				rm ./Project01/fileSizes.txt
				touch ./Project01/fileSizes.txt
			else
				touch ./Project01/fileSizes.txt
			fi
			
			#Finds all the files >= to the specified file size and appends it to fileSizes.txt
			find ./ -path ./.git -prune -o -type f ! -name 'project_analyze.sh' -size +"$fileSize"c -print0 | while IFS= read -d $'\0' file
			do
				sizeOfFile=$(stat -c%s "$file")
				echo "$file" >> ./Project01/fileSizes.txt
				echo "The size of $file = $sizeOfFile bytes" >> ./Project01/fileSizes.txt
				echo "" >> ./Project01/fileSizes.txt
			
			done

			echo "All the files that have a size greater than or equal to $fileSize are written in fileSizes.txt. Enter less 'fileSizes.txt' (no quotes) to access."


		#If the user enters any other number other than 1 or 2 nothing will be done with the found files
		else
			echo "The FileSize function will close now."
		fi
	
	fi

done
