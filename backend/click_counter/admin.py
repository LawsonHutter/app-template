from django.contrib import admin
from .models import ClickCounter


@admin.register(ClickCounter)
class ClickCounterAdmin(admin.ModelAdmin):
    list_display = ['count', 'updated_at', 'created_at']
    readonly_fields = ['created_at', 'updated_at']
