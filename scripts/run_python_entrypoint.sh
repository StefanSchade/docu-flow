#!/bin/bash

# Activate the virtual environment
source /workspace/venv/bin/activate

# Run the Python script
python /workspace/src/entrypoint.py "$@"
