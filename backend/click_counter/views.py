from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .models import ClickCounter, Question, Answer, SurveyResponse, ResponseAnswer
from django.db import transaction


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


@api_view(['GET'])
def survey_questions_view(request):
    """
    Get all survey questions with their answer choices.
    Returns questions in order.
    """
    questions = Question.objects.all().prefetch_related('answers')
    
    questions_data = []
    for question in questions:
        questions_data.append({
            'id': question.id,
            'text': question.text,
            'order': question.order,
            'answers': [
                {
                    'id': answer.id,
                    'text': answer.text,
                    'value': answer.value,
                    'order': answer.order,
                }
                for answer in question.answers.all()
            ]
        })
    
    return Response({
        'questions': questions_data,
        'total': len(questions_data)
    })


@api_view(['POST'])
def submit_survey_view(request):
    """
    Submit a survey response.
    
    Expected payload:
    {
        "responses": [
            {"question_id": 1, "answer_id": 3},
            {"question_id": 2, "answer_id": 5},
            ...
        ],
        "session_id": "optional-session-id"
    }
    """
    try:
        responses_data = request.data.get('responses', [])
        session_id = request.data.get('session_id', '')
        
        if not responses_data:
            return Response(
                {'error': 'No responses provided'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Validate all questions and answers exist
        question_ids = [r.get('question_id') for r in responses_data]
        answer_ids = [r.get('answer_id') for r in responses_data]
        
        questions = Question.objects.filter(id__in=question_ids)
        answers = Answer.objects.filter(id__in=answer_ids)
        
        if questions.count() != len(set(question_ids)):
            return Response(
                {'error': 'Invalid question ID(s)'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        if answers.count() != len(set(answer_ids)):
            return Response(
                {'error': 'Invalid answer ID(s)'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Create survey response and answers in a transaction
        with transaction.atomic():
            survey_response = SurveyResponse.objects.create(session_id=session_id)
            
            for response_data in responses_data:
                question_id = response_data.get('question_id')
                answer_id = response_data.get('answer_id')
                
                question = Question.objects.get(id=question_id)
                answer = Answer.objects.get(id=answer_id)
                
                # Verify answer belongs to question
                if answer.question_id != question_id:
                    return Response(
                        {'error': f'Answer {answer_id} does not belong to question {question_id}'},
                        status=status.HTTP_400_BAD_REQUEST
                    )
                
                ResponseAnswer.objects.create(
                    response=survey_response,
                    question=question,
                    answer=answer
                )
        
        # Process the responses and generate results
        results = process_survey_results(survey_response)
        
        return Response({
            'success': True,
            'response_id': survey_response.id,
            'results': results,
            'message': 'Survey submitted successfully'
        }, status=status.HTTP_201_CREATED)
        
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


def process_survey_results(survey_response):
    """
    Process survey responses and generate results.
    This is where you can add custom logic based on answer choices.
    
    Returns a dictionary with results that will be displayed to the user.
    """
    # Get all answers for this response
    response_answers = ResponseAnswer.objects.filter(response=survey_response).select_related('question', 'answer')
    
    # Example: Count answers by value
    answer_counts = {}
    answer_details = []
    
    for response_answer in response_answers:
        value = response_answer.answer.value
        answer_counts[value] = answer_counts.get(value, 0) + 1
        answer_details.append({
            'question': response_answer.question.text,
            'answer': response_answer.answer.text,
            'value': value
        })
    
    # Example logic: Determine result based on answers
    # You can customize this logic based on your survey needs
    total_questions = response_answers.count()
    
    # Simple example: Calculate a score or category
    # This is just an example - customize based on your needs
    result_summary = {
        'total_questions': total_questions,
        'answers': answer_details,
        'summary': f'You answered {total_questions} questions.',
        # Add your custom logic here
    }
    
    # Example: If you want to categorize responses
    # You can add logic like:
    # - If most answers are "A", show result type 1
    # - If most answers are "B", show result type 2
    # etc.
    
    return result_summary
