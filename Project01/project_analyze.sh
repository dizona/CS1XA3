#!/bin/bash
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

	fi
done

