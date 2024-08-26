#!/bin/bash

# Activate the virtual environment
source /venv/bin/activate

# Run linter 
flake8 /workspace/src /workspace/tests/
