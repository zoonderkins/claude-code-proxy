#!/usr/bin/env python3
"""Start Claude Code Proxy server."""

import sys
import os
import argparse
from dotenv import load_dotenv

# Parse command line arguments for --env before importing modules
parser = argparse.ArgumentParser(description='Start Claude Code Proxy server')
parser.add_argument('--env', type=str, help='Path to .env file (e.g., .env-requesty.glm)')
parser.add_argument('--help-proxy', action='store_true', help='Show proxy help')
args, remaining_args = parser.parse_known_args()

# Load specified .env file if provided
if args.env:
    env_path = os.path.join(os.path.dirname(__file__), args.env)
    if os.path.exists(env_path):
        load_dotenv(env_path, override=True)
        print(f"✅ Loaded environment from: {args.env}")
    else:
        print(f"❌ Error: Environment file not found: {args.env}")
        sys.exit(1)
else:
    # Load default .env file
    load_dotenv(override=True)

# Add src to Python path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

# Replace sys.argv to pass remaining args to main()
if args.help_proxy:
    sys.argv = [sys.argv[0], '--help']
else:
    sys.argv = [sys.argv[0]] + remaining_args

from src.main import main

if __name__ == "__main__":
    main()