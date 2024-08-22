#!/bin/bash

# Activate the virtual environment
source /workspace/venv/bin/activate

# Run pytest to discover and run all tests in that dir
pytest /workspace/tests
