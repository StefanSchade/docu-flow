#!/bin/bash

# Activate the virtual environment
source /workspace/venv/bin/activate

# Set the coverage file path to a directory within /workspace/target
export COVERAGE_FILE=/workspace/target/.coverage

# Run pytest to discover and run all tests in that dir
pytest --maxfail=1 --disable-warnings --cov=/workspace/src --cov-report=term --cov-report=html:/workspace/coverage_html /workspace/tests/
