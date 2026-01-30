"""
URL configuration for counter_backend project.
"""
from django.contrib import admin
from django.urls import path, include
from django.http import JsonResponse
from django.conf import settings
from django.conf.urls.static import static


def api_root(request):
    """Root API endpoint - for testing connectivity"""
    return JsonResponse({
        'message': 'Counter App Backend API',
        'version': '1.0.0',
        'status': 'running'
    })


urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', api_root, name='api-root'),
    path('api/counter/', include('click_counter.urls')),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
