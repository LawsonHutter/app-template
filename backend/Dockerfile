# Multi-stage Django Dockerfile
# Supports both development and production builds

# Base stage - common setup
FROM python:3.11-slim as base

# Set environment variables
# PYTHONDONTWRITEBYTECODE: Prevents Python from writing .pyc files
# PYTHONUNBUFFERED: Ensures Python output is sent straight to terminal (good for Docker logs)
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Set working directory inside container
WORKDIR /app

# Install system dependencies needed for PostgreSQL
# gcc: Needed for compiling some Python packages
# postgresql-client: Tools for interacting with PostgreSQL
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file first (allows Docker to cache this layer)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Copy all project files into container
COPY . .

# Expose port 8000 (Django's default port)
EXPOSE 8000

# Development target (default)
FROM base as development
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

# Production target
FROM base as production
# Install gunicorn for production server
RUN pip install gunicorn
# Collect static files (if needed)
# RUN python manage.py collectstatic --noinput || true
# Use gunicorn for production
CMD ["gunicorn", "survey_backend.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "3", "--timeout", "120"]
