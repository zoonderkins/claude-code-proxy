# Suggested Commands

## Environment Setup
```bash
# Install dependencies using UV (recommended)
uv sync

# Or using pip
pip install -r requirements.txt

# Copy and configure environment
cp .env.example .env
# Edit .env with your API configuration
```

## Running the Server
```bash
# Standard startup
python start_proxy.py

# With custom environment file
python start_proxy.py --env .env-custom

# Using UV
uv run claude-code-proxy

# Show help
python start_proxy.py --help-proxy
```

## Testing
```bash
# Run pytest unit tests
pytest tests/

# Run with verbose output
pytest tests/ -v

# Run comprehensive integration tests
python src/test_claude_to_openai.py

# Test API connectivity
curl http://localhost:8082/test-connection

# Health check
curl http://localhost:8082/health
```

## Code Quality
```bash
# Format code with Black
uv run black src/

# Sort imports with isort
uv run isort src/

# Type checking with mypy
uv run mypy src/

# Run all quality checks
uv run black src/ && uv run isort src/ && uv run mypy src/
```

## Build
```bash
# Build standalone binary
uv run pyinstaller --onefile src/main.py --name claude-code-proxy
```

## Using with Claude Code
```bash
# Start proxy server in one terminal
python start_proxy.py

# In another terminal, use Claude Code with proxy
ANTHROPIC_BASE_URL=http://localhost:8082 ANTHROPIC_API_KEY="any-value" claude

# Or set permanently in shell profile
export ANTHROPIC_BASE_URL=http://localhost:8082
```

## System Utilities (macOS/Darwin)
```bash
# Git operations
git status
git diff
git log --oneline -10

# File operations
ls -la
find . -name "*.py" -type f
grep -r "pattern" src/

# Process management
lsof -i :8082  # Check if port is in use
kill -9 <PID>  # Kill process
```
