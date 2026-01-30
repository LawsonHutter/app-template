from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .models import ClickCounter


@api_view(['GET', 'POST'])
def counter_view(request):
    """
    API endpoint to get and update the button click counter.
    
    GET: Returns the current count
    POST: Increments the count by 1 and returns the new count
    """
    counter = ClickCounter.get_singleton()
    
    if request.method == 'GET':
        # Return the current count
        return Response({
            'count': counter.count,
            'updated_at': counter.updated_at
        })
    
    elif request.method == 'POST':
        # Increment the count
        counter.count += 1
        counter.save()
        return Response({
            'count': counter.count,
            'updated_at': counter.updated_at,
            'message': 'Counter incremented successfully'
        }, status=status.HTTP_200_OK)


@api_view(['POST'])
def reset_counter_view(request):
    """
    API endpoint to reset the counter to zero.
    
    POST: Resets the count to 0 and returns the new count
    """
    counter = ClickCounter.get_singleton()
    counter.count = 0
    counter.save()
    return Response({
        'count': counter.count,
        'updated_at': counter.updated_at,
        'message': 'Counter reset to zero'
    }, status=status.HTTP_200_OK)
