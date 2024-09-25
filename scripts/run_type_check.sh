#!/bin/bash

# Activate the virtual environment
source /venv/bin/activate

# Run type check 
mypy /workspace/src /workspace/tests/
