# Database Structure

This document explains the database schema and relationships for the survey application.

## Overview

The database uses **SQLite** for local development and **PostgreSQL** for production. The schema is the same for both - only the database engine differs.

## Tables

### 1. `click_counter_clickcounter`

**Purpose**: Stores the button click counter (legacy feature, can be ignored for survey functionality)

**Fields**:
- `id` (Primary Key, Auto-increment)
- `count` (Integer) - Current count value
- `created_at` (DateTime) - When created
- `updated_at` (DateTime) - Last update time

**Notes**: Uses singleton pattern - only one record (id=1) exists

---

### 2. `click_counter_question`

**Purpose**: Stores survey questions

**Fields**:
- `id` (Primary Key, Auto-increment)
- `text` (Text) - The question text
- `order` (Integer) - Display order (0, 1, 2, ...)
- `created_at` (DateTime) - When created
- `updated_at` (DateTime) - Last update time

**Relationships**:
- One-to-Many with `Answer` (one question has many answer choices)

**Example**:
```
id: 1
text: "What is your favorite programming language?"
order: 0
created_at: 2026-01-22 07:40:00
updated_at: 2026-01-22 07:40:00
```

---

### 3. `click_counter_answer`

**Purpose**: Stores answer choices for each question

**Fields**:
- `id` (Primary Key, Auto-increment)
- `question_id` (Foreign Key → `click_counter_question.id`)
- `text` (CharField, max 255) - The answer choice text displayed to users
- `value` (CharField, max 100) - Internal value stored when selected
- `order` (Integer) - Display order within the question (0, 1, 2, ...)
- `created_at` (DateTime) - When created

**Relationships**:
- Many-to-One with `Question` (many answers belong to one question)

**Example**:
```
id: 1
question_id: 1
text: "Python"
value: "python"
order: 0
created_at: 2026-01-22 07:40:00
```

**Why `text` and `value`?**
- `text`: What users see ("Python", "JavaScript", etc.)
- `value`: Internal identifier for processing ("python", "javascript", etc.)
- Allows you to change display text without breaking logic

---

### 4. `click_counter_surveyresponse`

**Purpose**: Stores a complete survey submission

**Fields**:
- `id` (Primary Key, Auto-increment)
- `created_at` (DateTime) - When the survey was submitted
- `session_id` (CharField, max 100, optional) - Optional session identifier

**Relationships**:
- One-to-Many with `ResponseAnswer` (one response has many answer records)

**Example**:
```
id: 1
created_at: 2026-01-22 08:15:30
session_id: "" (empty or optional identifier)
```

---

### 5. `click_counter_responseanswer`

**Purpose**: Links a survey response to specific answer choices (junction table)

**Fields**:
- `id` (Primary Key, Auto-increment)
- `response_id` (Foreign Key → `click_counter_surveyresponse.id`)
- `question_id` (Foreign Key → `click_counter_question.id`)
- `answer_id` (Foreign Key → `click_counter_answer.id`)
- `created_at` (DateTime) - When created

**Relationships**:
- Many-to-One with `SurveyResponse`
- Many-to-One with `Question`
- Many-to-One with `Answer`

**Constraints**:
- `unique_together = ['response', 'question']` - **One answer per question per response**
  - Prevents a user from answering the same question twice in one survey

**Example**:
```
id: 1
response_id: 1
question_id: 1
answer_id: 3
created_at: 2026-01-22 08:15:30
```

This means: Response #1 answered Question #1 with Answer #3

---

## Entity Relationship Diagram

```
┌─────────────────────┐
│     Question        │
│─────────────────────│
│ id (PK)             │
│ text                │
│ order               │
│ created_at          │
│ updated_at          │
└──────────┬──────────┘
           │
           │ 1:N
           │
           ▼
┌─────────────────────┐
│      Answer          │
│─────────────────────│
│ id (PK)             │
│ question_id (FK)    │──┐
│ text                │  │
│ value               │  │
│ order               │  │
│ created_at          │  │
└─────────────────────┘  │
                         │
                         │ N:1
                         │
┌─────────────────────┐ │
│   SurveyResponse     │ │
│─────────────────────│ │
│ id (PK)             │ │
│ created_at          │ │
│ session_id          │ │
└──────────┬──────────┘ │
           │            │
           │ 1:N        │
           │            │
           ▼            │
┌─────────────────────┐ │
│   ResponseAnswer    │ │
│─────────────────────│ │
│ id (PK)             │ │
│ response_id (FK)    │─┘
│ question_id (FK)    │──┐
│ answer_id (FK)      │──┼──┐
│ created_at          │  │  │
└─────────────────────┘  │  │
                         │  │
                         │  │
                         │  │
                         └──┘
```

---

## Data Flow Example

### Creating a Survey

1. **Create Questions**:
   ```python
   q1 = Question.objects.create(text="What is your favorite color?", order=0)
   q2 = Question.objects.create(text="How old are you?", order=1)
   ```

2. **Create Answers**:
   ```python
   Answer.objects.create(question=q1, text="Red", value="red", order=0)
   Answer.objects.create(question=q1, text="Blue", value="blue", order=1)
   Answer.objects.create(question=q2, text="18-25", value="18-25", order=0)
   ```

### Submitting a Survey

1. **User selects answers**:
   - Question 1 → Answer "Red" (answer_id=1)
   - Question 2 → Answer "18-25" (answer_id=3)

2. **Create SurveyResponse**:
   ```python
   response = SurveyResponse.objects.create(session_id="user123")
   # response.id = 1
   ```

3. **Create ResponseAnswer records**:
   ```python
   ResponseAnswer.objects.create(
       response=response,      # response_id=1
       question=q1,            # question_id=1
       answer=answer_red       # answer_id=1
   )
   ResponseAnswer.objects.create(
       response=response,      # response_id=1
       question=q2,            # question_id=2
       answer=answer_18_25     # answer_id=3
   )
   ```

### Retrieving Survey Data

**Get all questions with answers**:
```python
questions = Question.objects.all().prefetch_related('answers')
for question in questions:
    print(question.text)
    for answer in question.answers.all():
        print(f"  - {answer.text}")
```

**Get a response with all answers**:
```python
response = SurveyResponse.objects.get(id=1)
response_answers = ResponseAnswer.objects.filter(response=response)
for ra in response_answers:
    print(f"Q: {ra.question.text}")
    print(f"A: {ra.answer.text}")
```

---

## Database Tables Summary

| Table | Purpose | Key Fields |
|-------|---------|------------|
| `click_counter_clickcounter` | Legacy counter | count |
| `click_counter_question` | Survey questions | text, order |
| `click_counter_answer` | Answer choices | question_id, text, value, order |
| `click_counter_surveyresponse` | Survey submissions | created_at, session_id |
| `click_counter_responseanswer` | Links responses to answers | response_id, question_id, answer_id |

---

## Relationships Summary

1. **Question → Answer**: One-to-Many
   - One question has many answer choices
   - `Answer.question_id` → `Question.id`

2. **SurveyResponse → ResponseAnswer**: One-to-Many
   - One survey response has many answer records
   - `ResponseAnswer.response_id` → `SurveyResponse.id`

3. **Question → ResponseAnswer**: One-to-Many
   - One question can appear in many responses
   - `ResponseAnswer.question_id` → `Question.id`

4. **Answer → ResponseAnswer**: One-to-Many
   - One answer choice can be selected in many responses
   - `ResponseAnswer.answer_id` → `Answer.id`

---

## Constraints

1. **Unique Constraint**: `ResponseAnswer` has `unique_together = ['response', 'question']`
   - Ensures one answer per question per survey response
   - Prevents duplicate answers for the same question

2. **Cascade Deletes**:
   - Deleting a `Question` deletes all its `Answer` records
   - Deleting a `SurveyResponse` deletes all its `ResponseAnswer` records
   - Deleting an `Answer` deletes all `ResponseAnswer` records that used it

---

## Query Examples

### Get all questions in order
```python
questions = Question.objects.all().order_by('order')
```

### Get all answers for a question
```python
question = Question.objects.get(id=1)
answers = question.answers.all().order_by('order')
```

### Get all responses with their answers
```python
responses = SurveyResponse.objects.all()
for response in responses:
    answers = ResponseAnswer.objects.filter(response=response)
    for ra in answers:
        print(f"{ra.question.text}: {ra.answer.text}")
```

### Count responses per question
```python
from django.db.models import Count
questions = Question.objects.annotate(
    response_count=Count('responseanswer')
)
```

### Get most popular answer for a question
```python
from django.db.models import Count
question = Question.objects.get(id=1)
popular_answer = Answer.objects.filter(question=question).annotate(
    count=Count('responseanswer')
).order_by('-count').first()
```

---

## Viewing the Database

### Using Django Admin
1. Go to http://localhost:8000/admin
2. Log in with superuser account
3. View/edit all tables

### Using SQLite Browser
1. Download DB Browser for SQLite
2. Open `backend/db.sqlite3`
3. Browse tables and data

### Using Django Shell
```powershell
cd backend
.\venv\Scripts\Activate.ps1
python manage.py shell
```

Then:
```python
from click_counter.models import Question, Answer, SurveyResponse, ResponseAnswer

# View all questions
Question.objects.all()

# View all answers
Answer.objects.all()

# View all responses
SurveyResponse.objects.all()
```

---

## Database Location

- **Local Development**: `backend/db.sqlite3` (SQLite file)
- **Production/Docker**: PostgreSQL database in Docker volume

---

## Notes

- All tables use auto-incrementing `id` as primary key
- Timestamps (`created_at`, `updated_at`) are automatically managed
- Foreign keys use `CASCADE` deletion (deleting parent deletes children)
- The `order` fields control display sequence
- The `value` field in `Answer` is for programmatic logic (e.g., scoring, categorization)
