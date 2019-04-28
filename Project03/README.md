# README Project3: Speed Typer
This is project 3 for the Computer Science 1XA3 course. It features a game where the user must type as many words as they can in 30 seconds.
### How to run the project
- Clone the repository at https://github.com/dizona/CS1XA3.git in any directory you want
-  Make sure you have python installed and create a virtual environment with the command 
"python3 -m venv python_env" or use the one already in the folder.
- Now go into the virtual environment with "cd python_env" and once you are in, run
"source bin/activate"
- Navigate to CS1XA3/Project03 and do the command "pip install -r requirements.txt"
-  Now go to CS1XA3/Project03/django_project and perform the command 
"python3 manage.py runserver localhost:10015"
- Go to https://mac1xa3.ca/e/dizona/static/project3.html
- Register for an account and you're ready to play the game!
### Features
##### Basic App Features:
- Login feature
- Register feature that checks if a username is taken
- Game that makes use of time and keyboard input
- Displays the current user logged in and has a logout feature
- Save your score to the database 
##### Technical Features:
##### Elm:
- Utilizes Html.Events through onClick and keyboard input
- Uses Json.Encode to encode the username, password, and score when sending it to the server
- Uses Json.Decode to decode keyboard input
- Makes use of "List" import module to retrive the head and tail of a list
- Utilizes "Random" and "Random.List" import modules to shuffle a list to make it random
- Uses "Time" import to count the seconds the user has remaining in the game
##### Django:
- loginapp is used for user authentication and requests. This includes user authentication and retrieving and sending usernames and scores to the database through the use of JSON get and post
- Utilizes "OneToOne" relations for associating points with the user
- Utilizes Django's built in "User" and the "UserInfo" model and functions such as login, logout, authenticate etc.
### Bootstrap Template Credit: 
##### Login form template retrieved from:
```sh
https://codepen.io/khadkamhn/pen/ZGvPLo/
```
##### Template for the game retrieved from:
```sh
https://colorlib.com/wp/template/contact-form-v10/
```


