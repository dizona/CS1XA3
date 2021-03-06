from django.urls import path
from . import views

# mapped from path hello/
urlpatterns = [
    #path('sessionincr/', views.session_incr , name = 'userauthapp-sesson_incr') ,
    #path('sessionget/', views.session_get , name = 'userauthapp-sesson_get') ,
    path('adduser/', views.add_user , name = 'loginapp-add_user') ,
    path('loginuser/', views.login_user , name = 'loginapp-login_user') ,
    path('userinfo/', views.user_info , name = 'loginapp-user_info') ,
    path('getuserinfo/', views.getuserinfo , name = 'loginapp-getuserinfo'),
    path('getusername/', views.getusername , name = 'loginapp-getusername'),
    path('logoutuser/', views.logout_user , name = 'loginapp-logout_user'),
    path('postscore/',views.postscore, name = 'loginapp-postscore'),
    path('getscore/',views.getscore, name = 'loginapp-getscore'),

]
