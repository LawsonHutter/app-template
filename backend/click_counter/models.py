from django.db import models


class ClickCounter(models.Model):
    """
    Simple model to store the button click counter.
    We'll use a singleton pattern - only one counter instance.
    """
    count = models.IntegerField(default=0)
    updated_at = models.DateTimeField(auto_now=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = "Click Counter"
        verbose_name_plural = "Click Counters"

    def __str__(self):
        return f"Counter: {self.count}"

    @classmethod
    def get_singleton(cls):
        """
        Get or create the single counter instance.
        There should only be one counter in the database.
        """
        counter, created = cls.objects.get_or_create(pk=1)
        return counter


class Question(models.Model):
    """
    Survey question model.
    Questions are ordered by their order field.
    """
    text = models.TextField(help_text="The question text")
    order = models.IntegerField(default=0, help_text="Order of the question in the survey")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['order']
        verbose_name = "Question"
        verbose_name_plural = "Questions"

    def __str__(self):
        return f"Q{self.order + 1}: {self.text[:50]}"


class Answer(models.Model):
    """
    Answer choice for a question.
    """
    question = models.ForeignKey(Question, on_delete=models.CASCADE, related_name='answers')
    text = models.CharField(max_length=255, help_text="The answer choice text")
    value = models.CharField(max_length=100, help_text="Value stored when this answer is selected")
    order = models.IntegerField(default=0, help_text="Order of the answer in the question")
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['order']
        verbose_name = "Answer"
        verbose_name_plural = "Answers"

    def __str__(self):
        return f"{self.question.text[:30]} - {self.text}"


class SurveyResponse(models.Model):
    """
    Stores a complete survey response with all answers.
    """
    created_at = models.DateTimeField(auto_now_add=True)
    session_id = models.CharField(max_length=100, blank=True, help_text="Optional session identifier")

    class Meta:
        ordering = ['-created_at']
        verbose_name = "Survey Response"
        verbose_name_plural = "Survey Responses"

    def __str__(self):
        return f"Response {self.id} - {self.created_at.strftime('%Y-%m-%d %H:%M')}"


class ResponseAnswer(models.Model):
    """
    Links a survey response to a specific answer choice.
    """
    response = models.ForeignKey(SurveyResponse, on_delete=models.CASCADE, related_name='answers')
    question = models.ForeignKey(Question, on_delete=models.CASCADE)
    answer = models.ForeignKey(Answer, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = "Response Answer"
        verbose_name_plural = "Response Answers"
        unique_together = ['response', 'question']  # One answer per question per response

    def __str__(self):
        return f"Response {self.response.id} - {self.question.text[:30]}: {self.answer.text}"
