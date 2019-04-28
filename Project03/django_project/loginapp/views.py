from django.shortcuts import render
from django.http import HttpResponse
from django.contrib.auth.models import User
from django.contrib.auth import authenticate, login, logout
import json
from django.db import IntegrityError

# Create your views here.
from .models import UserInfo

#Adds a user to the database. It will not add if the user already exists
def add_user(request):
    """recieves a json request { 'username' : 'val0', 'password' : 'val1' } and saves it
       it to the database using the django User Model
       Assumes success and returns an empty Http Response"""
    logout(request)
    try:
        json_req = json.loads(request.body)
        uname = json_req.get('username','')
        passw = json_req.get('password','')

        if uname != '':
            newAcc = UserInfo.objects.create_user_info(username=uname,
                                        password=passw)
            logout(request)
            newAcc.save()
            login(request,newAcc.user)
            return HttpResponse('LoggedIn')

        else:
            return HttpResponse('LoggedOut')
    except IntegrityError:
        logout(request)
        return HttpResponse('Exists')

#Logs the user in if the proper username and password is entered (ie. it exists)
def login_user(request):
    """recieves a json request { 'username' : 'val0' : 'password' : 'val1' } and
       authenticates and loggs in the user upon success """

    json_req = json.loads(request.body)
    uname = json_req.get('username','')
    passw = json_req.get('password','')

    user = authenticate(request,username=uname,password=passw)
    if user is not None:
        login(request,user)
        return HttpResponse("LoggedIn")
    else:
        return HttpResponse('LoginFailed')

#Logs the user out of the system
def logout_user(request):
    logout(request)
    return HttpResponse("Logout")

def user_info(request):
    """serves content that is only available to a logged in user"""

    if not request.user.is_authenticated:
        return HttpResponse("LoggedOut")
    else:
        # do something only a logged in user can do
        return HttpResponse("Hello " + request.user.first_name)

#Checks if the user is authenticated
def getuserinfo(request):
    if request.user.is_authenticated:
        return HttpResponse("Authenticated")
    else:
        return HttpResponse("NotAuthenticated")

#Returns the username of the user logged in
def getusername(request):
    return HttpResponse(request.user.get_username())

#Saves the score of the user only if it is greater than or equal to their current score
def postscore(request):
    #print(request.user.is_authenticated)
    json_req = json.loads(request.body)
    x = json_req.get('score',0)
    logged = UserInfo.objects.get(user=request.user)
    if x >= logged.points:
        logged.points=x
        logged.save()
        #print(logged)
        return HttpResponse("ScoreSaved")
    else:
        return HttpResponse("NotSaved")

#Gets the score of the user
def getscore(request):
    logged = UserInfo.objects.get(user=request.user)
    return HttpResponse(logged.points)
