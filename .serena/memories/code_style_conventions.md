# Code Style and Conventions

## Formatting Tools
- **Black**: Code formatter with line-length 100
- **isort**: Import sorter (profile: black, line_length: 100)
- **mypy**: Static type checker (Python 3.12, disallow_untyped_defs: true)

## Naming Conventions
- **Variables/Functions**: `snake_case` (e.g., `openai_api_key`, `map_claude_model_to_openai`)
- **Classes**: `PascalCase` (e.g., `Config`, `ModelManager`, `RequestConverter`)
- **Constants**: `UPPER_SNAKE_CASE` (e.g., `MAX_TOKENS_LIMIT`)
- **Private members**: Leading underscore `_private_method`

## Type Hints
Type hints are **required** for function parameters and return types:
```python
def map_claude_model_to_openai(self, claude_model: str) -> str:
    """Map Claude model names to OpenAI model names based on BIG/SMALL pattern"""
    ...
```

## Docstrings
Use triple-quoted docstrings for functions and classes:
```python
def validate_api_key(self):
    """Basic API key validation"""
    ...
```

## Imports
- Standard library imports first
- Third-party imports second
- Local imports last
- Each group separated by a blank line

```python
import sys
import os

from fastapi import FastAPI
from pydantic import BaseModel

from src.core.config import config
from src.api.endpoints import router
```

## Architecture Patterns
1. **Layered Architecture**: Clear separation between API, conversion, core, and models layers
2. **Single Responsibility**: Each module has a focused purpose
3. **Configuration via Environment**: All settings loaded from environment variables
4. **Pydantic Models**: Data validation using Pydantic schemas
5. **Async/Await**: Full async support for high concurrency

## Error Handling
- Use appropriate HTTP status codes
- Provide user-friendly error messages
- Log errors with context
- Handle edge cases gracefully

## File Organization
- One class per file when the class is substantial
- Related functions can be grouped in a single module
- Keep files focused and under ~300 lines when possible
