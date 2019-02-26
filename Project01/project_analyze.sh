#i!/bin/bash
#all files are relative to CS1XA3
cd ..
#read -p "Welcome! Enter: \n 1 For #TODO function" 
#Checks every files in repo
for userInput in "$@"
do
  	if [ "$userInput" = "todo" ]; then
		if [ -f ./Project01/todo.log ]; then
			rm ./Project01/todo.log
		else
			touch ./Project01/todo.log
		fi
		
		grep -r --exclude={project_analyze.sh,todo.log} --exclude-dir=.git "#TODO" ./ >> ./Project01/todo.log
	
	elif [ "$userInput" = "FileCount" ]; then
		
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
		bash=$(find ./ -iname "*sh" | wc -l)
		echo "Bash: $bash"
	
	elif [ "$userInput" = "FileSize" ]; then
		read -p "Enter the minimum size of the files you wish to look for (in bytes): " fileSize
		echo "These are the files that have the size that is greater than or equal to $fileSize : "
		echo ""

		#FIX THIS WILL TEMPORARILY REFER TO ONLY A SPECIFIC DIRECTORY
		find ./ -path ./.git -prune -o -type f ! -name 'project_analyze.sh' -size +"$fileSize"c -print0 | while IFS= read -d $'\0' file
		do
			sizeOfFile=$(stat -c%s "$file")
			echo $file
			echo "> The size of $file = $sizeOfFile bytes."
			echo ""

		done

		read -p "What would you like to do with them? Enter:
		1 to remove specified files
		2 to put a list of them in a file
		3 to do nothing with them
		Enter choice here: " fileChoice

		if [ "$fileChoice" = "1" ]; then
			read -p "Enter the exact namee(s) of the file(s) you wish to remove (separate by spaces): " deleteFile

			for dFile in "$deleteFile"
			do
				#FIX THIS ONLY TEMP FOR TESTING
				find ./Project01/randomFilesToTestSize -name "$dFile" -print0 | xargs -0 rm
				echo "$dFIle has been removed"
				echo ""
			done

		elif [ "$fileChoice" = "2" ]; then
			if [ -f ./Project01/fileSizes.txt ]; then
				rm ./Project01/fileSizes.txt
			else
				touch ./Project01/fileSizes.txt
			fi

			find ./ -path ./.git -prune -o -type f ! -name 'project_analyze.sh' -size +"$fileSize"c -print0 | while IFS= read -d $'\0' file
			do
				sizeOfFile=$(stat -c%s "$file")
				echo "$file" >> ./Project01/fileSizes.txt
				echo "The size of $file = $sizeOfFile bytes" >> ./Project01/fileSizes.txt
				echo "" >> ./Project01/fileSizes.txt
			
			done

			echo "All the files that have a size greater than or equal to $fileSize are written in fileSizes.txt"



		elif [ "$fileChoice" = "3" ]; then
			echo "The FileSize function will close now."
		fi
	
	fi

done
