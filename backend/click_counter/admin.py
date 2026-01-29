from django.contrib import admin
from .models import ClickCounter, Question, Answer, SurveyResponse, ResponseAnswer


@admin.register(ClickCounter)
class ClickCounterAdmin(admin.ModelAdmin):
    list_display = ['count', 'updated_at', 'created_at']
    readonly_fields = ['created_at', 'updated_at']


class AnswerInline(admin.TabularInline):
    model = Answer
    extra = 2
    fields = ['text', 'value', 'order']


@admin.register(Question)
class QuestionAdmin(admin.ModelAdmin):
    list_display = ['text', 'order', 'created_at']
    list_editable = ['order']
    inlines = [AnswerInline]
    search_fields = ['text']


@admin.register(Answer)
class AnswerAdmin(admin.ModelAdmin):
    list_display = ['text', 'question', 'value', 'order']
    list_filter = ['question']
    list_editable = ['order']


class ResponseAnswerInline(admin.TabularInline):
    model = ResponseAnswer
    readonly_fields = ['question', 'answer', 'created_at']
    extra = 0
    can_delete = False


@admin.register(SurveyResponse)
class SurveyResponseAdmin(admin.ModelAdmin):
    list_display = ['id', 'created_at', 'session_id']
    list_filter = ['created_at']
    readonly_fields = ['created_at']
    inlines = [ResponseAnswerInline]
    date_hierarchy = 'created_at'
