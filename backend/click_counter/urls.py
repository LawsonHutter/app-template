from django.urls import path
from . import views

app_name = 'click_counter'

urlpatterns = [
    path('', views.counter_view, name='counter'),
    path('reset/', views.reset_counter_view, name='reset-counter'),
]
