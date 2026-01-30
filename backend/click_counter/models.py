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
