from django.urls import path
from . import views


urlpatterns = [
    path("lab7/", views.post_req, name = 'lab7app-post_req'),
    ]
