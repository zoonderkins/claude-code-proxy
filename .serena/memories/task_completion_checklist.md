# Task Completion Checklist

When completing a task in this codebase, ensure the following steps are done:

## Before Committing Code

### 1. Code Quality Checks
```bash
# Format code
uv run black src/

# Sort imports
uv run isort src/

# Type checking
uv run mypy src/
```

### 2. Run Tests
```bash
# Unit tests
pytest tests/

# Integration tests (if applicable)
python src/test_claude_to_openai.py
```

### 3. Manual Verification
- [ ] Start the server: `python start_proxy.py`
- [ ] Test basic functionality: `curl http://localhost:8082/health`
- [ ] Test connection: `curl http://localhost:8082/test-connection`

## Code Review Checklist
- [ ] Type hints added to new functions
- [ ] Docstrings for public functions/classes
- [ ] No hardcoded secrets or API keys
- [ ] Error handling for edge cases
- [ ] Follows existing code patterns
- [ ] No unnecessary dependencies added

## Environment Variables
If adding new configuration:
- [ ] Add to `src/core/config.py`
- [ ] Document in `.env.example`
- [ ] Update `CLAUDE.md` if significant

## Testing Checklist
- [ ] Unit tests for new functions
- [ ] Edge cases covered
- [ ] Error conditions tested
- [ ] Async functions properly tested

## Documentation
- [ ] Update README.md if adding features
- [ ] Update CLAUDE.md for significant changes
- [ ] Add inline comments for complex logic
