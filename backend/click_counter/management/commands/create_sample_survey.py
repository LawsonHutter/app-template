"""
Management command to create sample survey questions and answers.
Run with: python manage.py create_sample_survey
"""
from django.core.management.base import BaseCommand
from click_counter.models import Question, Answer


class Command(BaseCommand):
    help = 'Creates sample survey questions and answers for testing'

    def handle(self, *args, **options):
        self.stdout.write('Creating sample survey questions...')

        # Question 1
        q1 = Question.objects.create(
            text='What is your favorite programming language?',
            order=0
        )
        Answer.objects.create(question=q1, text='Python', value='python', order=0)
        Answer.objects.create(question=q1, text='JavaScript', value='javascript', order=1)
        Answer.objects.create(question=q1, text='Java', value='java', order=2)
        Answer.objects.create(question=q1, text='C++', value='cpp', order=3)
        self.stdout.write(self.style.SUCCESS(f'Created question 1: {q1.text}'))

        # Question 2
        q2 = Question.objects.create(
            text='How many years of programming experience do you have?',
            order=1
        )
        Answer.objects.create(question=q2, text='Less than 1 year', value='0-1', order=0)
        Answer.objects.create(question=q2, text='1-3 years', value='1-3', order=1)
        Answer.objects.create(question=q2, text='3-5 years', value='3-5', order=2)
        Answer.objects.create(question=q2, text='5+ years', value='5+', order=3)
        self.stdout.write(self.style.SUCCESS(f'Created question 2: {q2.text}'))

        # Question 3
        q3 = Question.objects.create(
            text='What type of projects do you enjoy working on?',
            order=2
        )
        Answer.objects.create(question=q3, text='Web Development', value='web', order=0)
        Answer.objects.create(question=q3, text='Mobile Apps', value='mobile', order=1)
        Answer.objects.create(question=q3, text='Data Science', value='data', order=2)
        Answer.objects.create(question=q3, text='Game Development', value='game', order=3)
        self.stdout.write(self.style.SUCCESS(f'Created question 3: {q3.text}'))

        # Question 4
        q4 = Question.objects.create(
            text='How do you prefer to learn new technologies?',
            order=3
        )
        Answer.objects.create(question=q4, text='Online Courses', value='courses', order=0)
        Answer.objects.create(question=q4, text='Documentation', value='docs', order=1)
        Answer.objects.create(question=q4, text='Tutorial Videos', value='videos', order=2)
        Answer.objects.create(question=q4, text='Hands-on Projects', value='projects', order=3)
        self.stdout.write(self.style.SUCCESS(f'Created question 4: {q4.text}'))

        # Question 5
        q5 = Question.objects.create(
            text='What motivates you most in your work?',
            order=4
        )
        Answer.objects.create(question=q5, text='Solving Problems', value='problems', order=0)
        Answer.objects.create(question=q5, text='Building Products', value='products', order=1)
        Answer.objects.create(question=q5, text='Learning New Things', value='learning', order=2)
        Answer.objects.create(question=q5, text='Helping Others', value='helping', order=3)
        self.stdout.write(self.style.SUCCESS(f'Created question 5: {q5.text}'))

        self.stdout.write(self.style.SUCCESS('\nSuccessfully created 5 sample questions with answers!'))
        self.stdout.write('You can now test the survey in the Flutter app.')
