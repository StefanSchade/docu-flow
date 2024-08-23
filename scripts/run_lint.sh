#!/bin/bash

# Activate the virtual environment
source /workspace/venv/bin/activate

# Run linter (e.g., flake8)
flake8 /workspace/src /workspace/tests/
