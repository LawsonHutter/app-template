# Contributing Guidelines

## Branch Naming Convention

- `main` - Production-ready code
- `develop` - Integration branch for features
- `feature/description` - New features
- `fix/description` - Bug fixes
- `backend/description` - Backend-specific changes
- `frontend/description` - Frontend-specific changes

## Commit Message Format

```
type(scope): subject

body (optional)

footer (optional)
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples
```
feat(backend): add user authentication API
fix(frontend): resolve login form validation issue
docs: update README with setup instructions
```

## Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Code Style

### Backend (Django)
- Follow PEP 8 style guide
- Use type hints where appropriate
- Write docstrings for functions and classes

### Frontend (Flutter)
- Follow Flutter style guide
- Use meaningful variable names
- Add comments for complex logic
