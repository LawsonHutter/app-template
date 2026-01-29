# Survey App Setup Guide

This guide explains how to set up and use the survey functionality.

## Backend Setup

### 1. Create Database Migrations

```powershell
cd backend
python manage.py makemigrations
python manage.py migrate
```

### 2. Create Sample Survey Questions

```powershell
python manage.py create_sample_survey
```

This creates 5 sample questions with answer choices that you can test with.

### 3. Or Create Questions via Django Admin

1. Start the backend: `.\scripts\start-backend-local.ps1`
2. Go to http://localhost:8000/admin
3. Log in with your superuser account
4. Add Questions and Answers manually

## Frontend Setup

### 1. Install Dependencies

```powershell
cd frontend
flutter pub get
```

### 2. Run the App

```powershell
flutter run -d chrome
```

Or use the script:
```powershell
.\scripts\start-frontend-local.ps1
```

## Using the Survey

1. **Start the app** - The survey will load questions from the backend
2. **Answer questions** - Click on an answer choice, then click "Next"
3. **Navigate** - Use "Previous" to go back, "Next" to continue
4. **Submit** - On the last question, click "Submit"
5. **Loading** - A loading screen appears while processing
6. **Results** - View your results and answers

## Customizing Questions

### Via Django Admin

1. Go to http://localhost:8000/admin
2. Click on **Questions**
3. Add/edit questions and their answer choices
4. Set the `order` field to control question sequence

### Via Code

Edit `backend/click_counter/management/commands/create_sample_survey.py` to customize the sample questions.

### Via API

You can also create questions programmatically:

```python
from click_counter.models import Question, Answer

question = Question.objects.create(
    text='Your question here?',
    order=0
)

Answer.objects.create(
    question=question,
    text='Answer choice 1',
    value='value1',
    order=0
)
```

## Customizing Results Logic

Edit the `process_survey_results()` function in `backend/click_counter/views.py` to add your custom logic.

Example customizations:
- Calculate scores based on answer values
- Categorize responses (e.g., "Type A", "Type B")
- Show recommendations based on answers
- Generate reports

## API Endpoints

### Get Survey Questions
```
GET /api/counter/survey/questions/
```

Returns all questions with their answer choices.

### Submit Survey
```
POST /api/counter/survey/submit/
```

Body:
```json
{
  "responses": [
    {"question_id": 1, "answer_id": 3},
    {"question_id": 2, "answer_id": 5}
  ],
  "session_id": "optional-session-id"
}
```

Returns:
```json
{
  "success": true,
  "response_id": 1,
  "results": {
    "total_questions": 5,
    "answers": [...],
    "summary": "You answered 5 questions."
  }
}
```

## Troubleshooting

### No questions showing
- Make sure you've run migrations: `python manage.py migrate`
- Create sample questions: `python manage.py create_sample_survey`
- Check backend is running: http://localhost:8000/api/counter/survey/questions/

### Can't submit survey
- Make sure all questions are answered
- Check backend logs for errors
- Verify API endpoint is correct

### Results not showing
- Check the `process_survey_results()` function in views.py
- Verify the results structure matches what the frontend expects

## Next Steps

1. **Customize questions** - Add your own questions via admin or code
2. **Customize results** - Modify `process_survey_results()` for your logic
3. **Style the UI** - Update Flutter theme and colors
4. **Add features** - Progress bar, question validation, etc.
