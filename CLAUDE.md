# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Claude Code Proxy** is an HTTP proxy server that enables Claude Code CLI to work with OpenAI-compatible API providers by translating Claude's native API format to OpenAI's format. The proxy supports multiple providers (OpenAI, Azure, local models) while maintaining the full Claude Code experience including streaming, function calling, and image support.

## Development Commands

### Environment Setup
```bash
# Using UV (recommended)
uv sync

# Or using pip
pip install -r requirements.txt

# Copy and configure environment
cp .env.example .env
# Edit .env with your API configuration
```

### Running the Server
```bash
# Standard startup
python start_proxy.py

# With custom environment file
python start_proxy.py --env .env-custom

# Using UV
uv run claude-code-proxy

# Docker
docker compose up -d
```

### Testing
```bash
# Comprehensive integration tests
python src/test_claude_to_openai.py

# Unit tests with pytest
pytest tests/

# Test API connectivity
curl http://localhost:8082/test-connection
```

### Development Tools
```bash
# Code formatting
uv run black src/
uv run isort src/

# Type checking
uv run mypy src/

# Build binary
uv run pyinstaller --onefile src/main.py --name claude-code-proxy
```

## Architecture & Code Structure

### Layered Architecture
The project follows a clear separation of concerns:

```
├── API Layer (FastAPI endpoints)          # src/api/endpoints.py
├── Conversion Layer (Format translation)   # src/conversion/
├── Core Layer (Business logic)             # src/core/
└── Models Layer (Pydantic schemas)         # src/models/
```

### Key Files & Their Purpose
- `start_proxy.py` - Main entry point with CLI argument parsing and environment loading
- `src/main.py` - FastAPI application setup and server configuration
- `src/api/endpoints.py` - HTTP endpoints, request validation, and error handling
- `src/conversion/request_converter.py` - Claude → OpenAI format translation
- `src/conversion/response_converter.py` - OpenAI → Claude format translation
- `src/core/model_manager.py` - Model mapping logic (haiku/sonnet/opus → SMALL/MIDDLE/BIG)
- `src/core/config.py` - Environment variable handling and configuration
- `src/core/client.py` - OpenAI API client with retry logic and connection pooling

## Configuration System

### Environment Variables
The application uses a comprehensive environment-based configuration system:

**Required:**
- `OPENAI_API_KEY` - API key for target provider

**Model Mapping:**
- `BIG_MODEL` - Maps Claude opus requests (default: gpt-4o)
- `MIDDLE_MODEL` - Maps Claude sonnet requests (default: gpt-4o)
- `SMALL_MODEL` - Maps Claude haiku requests (default: gpt-4o-mini)

**Provider Configuration:**
- `OPENAI_BASE_URL` - API endpoint (default: https://api.openai.com/v1)
- `ANTHROPIC_API_KEY` - Optional client validation key

**Custom Headers:**
- `CUSTOM_HEADER_*` - Automatically injected headers (e.g., CUSTOM_HEADER_ACCEPT)

### Custom Header Injection
Environment variables with `CUSTOM_HEADER_` prefix are converted to HTTP headers:
```bash
CUSTOM_HEADER_ACCEPT="application/jsonstream" → Accept header
CUSTOM_HEADER_X_API_KEY="token" → X-API-Key header
```

## Key Development Patterns

### Model Mapping Strategy
The `ModelManager` implements intelligent model mapping:
- Claude models containing "haiku" → `SMALL_MODEL`
- Claude models containing "sonnet" → `MIDDLE_MODEL`
- Claude models containing "opus" → `BIG_MODEL`
- Non-Claude models pass through unchanged

### Request/Response Conversion
- **Request Converter**: Transforms Claude's structured message format to OpenAI's chat completion format
- **Response Converter**: Handles both streaming and non-streaming responses, converting OpenAI format back to Claude's expected structure
- Supports complex content types: text, images (base64), tool calls, and system messages

### Error Handling
- API key validation (optional)
- OpenAI error classification and user-friendly message translation
- Request cancellation detection for streaming responses
- Comprehensive logging with configurable levels

## Multi-Provider Support

### OpenAI
```bash
OPENAI_API_KEY="sk-openai-key"
OPENAI_BASE_URL="https://api.openai.com/v1"
```

### Azure OpenAI
```bash
OPENAI_API_KEY="azure-key"
OPENAI_BASE_URL="https://resource.openai.azure.com/openai/deployments/deployment"
AZURE_API_VERSION="2024-03-01-preview"
```

### Local Models (Ollama)
```bash
OPENAI_API_KEY="dummy-key"
OPENAI_BASE_URL="http://localhost:11434/v1"
BIG_MODEL="llama3.1:70b"
```

## Usage with Claude Code

```bash
# Start proxy server
python start_proxy.py

# Use Claude Code with proxy
ANTHROPIC_BASE_URL=http://localhost:8082 ANTHROPIC_API_KEY="any-value" claude

# Or set permanently
export ANTHROPIC_BASE_URL=http://localhost:8082
claude
```

## Important Implementation Details

- **Streaming Support**: Full SSE streaming with proper backpressure handling
- **Tool Use**: Complete function calling support with bidirectional conversion
- **Image Input**: Base64 encoded image support with proper MIME type handling
- **Connection Pooling**: Efficient HTTP connection reuse via httpx
- **Async/Await**: Full async support for high concurrency
- **Health Checks**: Built-in endpoints for connectivity testing