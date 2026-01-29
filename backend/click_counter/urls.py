from django.urls import path
from . import views

app_name = 'click_counter'

urlpatterns = [
    path('', views.counter_view, name='counter'),
    path('survey/questions/', views.survey_questions_view, name='survey-questions'),
    path('survey/submit/', views.submit_survey_view, name='survey-submit'),
]
