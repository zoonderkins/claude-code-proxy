# Claude Code Proxy - Project Overview

## Purpose
Claude Code Proxy is an HTTP proxy server that enables Claude Code CLI to work with OpenAI-compatible API providers. It translates Claude's native API format to OpenAI's format, supporting multiple providers (OpenAI, Azure OpenAI, local models like Ollama, Requesty AI) while maintaining the full Claude Code experience.

## Key Features
- **Format Translation**: Bidirectional conversion between Claude and OpenAI API formats
- **Streaming Support**: Full SSE streaming with backpressure handling
- **Function Calling**: Complete tool use support with bidirectional conversion
- **Image Support**: Base64 encoded image support with MIME type handling
- **Multi-Provider**: Works with OpenAI, Azure OpenAI, Ollama, and other OpenAI-compatible APIs
- **Requesty Auto Cache**: Optional automatic request caching for improved performance

## Tech Stack
- **Language**: Python 3.12+
- **Web Framework**: FastAPI
- **ASGI Server**: Uvicorn
- **Data Validation**: Pydantic 2.0+
- **API Client**: OpenAI SDK
- **Package Manager**: UV (preferred) or pip

## Project Structure
```
├── start_proxy.py              # Main entry point with CLI argument parsing
├── src/
│   ├── main.py                 # FastAPI app setup and server config
│   ├── api/
│   │   └── endpoints.py        # HTTP endpoints, request validation
│   ├── conversion/
│   │   ├── request_converter.py    # Claude → OpenAI format translation
│   │   └── response_converter.py   # OpenAI → Claude format translation
│   ├── core/
│   │   ├── config.py           # Environment variable handling
│   │   ├── client.py           # OpenAI API client with retry logic
│   │   ├── model_manager.py    # Model mapping (haiku/sonnet/opus → SMALL/MIDDLE/BIG)
│   │   ├── constants.py        # Constants and enums
│   │   └── logging.py          # Logging configuration
│   └── models/
│       ├── claude.py           # Pydantic schemas for Claude API
│       └── openai.py           # Pydantic schemas for OpenAI API
└── tests/                      # Test files
```

## Configuration
Configuration is done via environment variables (see `.env.example`):
- `OPENAI_API_KEY` - Required API key for target provider
- `OPENAI_BASE_URL` - API endpoint (default: https://api.openai.com/v1)
- `BIG_MODEL` - Maps Claude opus requests (default: gpt-4o)
- `MIDDLE_MODEL` - Maps Claude sonnet requests (default: gpt-4o)
- `SMALL_MODEL` - Maps Claude haiku requests (default: gpt-4o-mini)
- `ANTHROPIC_API_KEY` - Optional client validation key
- `REQUESTY_AUTO_CACHE` - Enable automatic request caching
