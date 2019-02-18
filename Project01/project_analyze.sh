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

	fi

done

