#!/bin/bash
#all files are relative to CS1XA3
cd ..

#Checks if todo.log exitsts. If it does delete and create a new one.
if [ -f ./Project01/todo.log ]; then
	rm ./Project01/todo.log
else
	touch ./Project01/todo.log
fi

#Checks every files in repo
for userInput in "$@"
do
  	if [ "$userInput" = "todo-log" ]; then
		if [ -f ./Project01/todo.log ]; then
			rm ./Project/01/todo.log
		else
			touch ./Project01/todo.log
		fi
		
		grep -r --exclude={project_analyze.sh,todo.log} "#TODO" ./ >> ./Project01/todo.log

	fi
done

