# Makefile for backend operations

.PHONY: help venv install migrate run test clean docker-build docker-up docker-down

help:
	@echo "Available commands:"
	@echo "  make venv        - Create virtual environment"
	@echo "  make install     - Install dependencies"
	@echo "  make migrate     - Run database migrations"
	@echo "  make run         - Run development server"
	@echo "  make test        - Run tests"
	@echo "  make clean       - Clean Python cache"
	@echo "  make docker-build - Build Docker image"
	@echo "  make docker-up   - Start Docker containers"
	@echo "  make docker-down - Stop Docker containers"

venv:
	python -m venv venv
	@echo "Virtual environment created. Activate with:"
	@echo "  Windows: venv\\Scripts\\activate"
	@echo "  Linux/Mac: source venv/bin/activate"

install:
	pip install --upgrade pip
	pip install -r requirements.txt

migrate:
	python manage.py migrate

run:
	python manage.py runserver

test:
	pytest

clean:
	find . -type d -name __pycache__ -exec rm -r {} +
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type d -name "*.egg-info" -exec rm -r {} +

docker-build:
	docker build -t counter-backend .

docker-up:
	docker-compose up -d

docker-down:
	docker-compose down
