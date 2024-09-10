#!/bin/bash

# Activate the virtual environment
source /venv/bin/activate
if [[ "$VIRTUAL_ENV" != "" ]]; then
    echo "Virtual environment activated."
else
    echo "Failed to activate virtual environment."
    exit 1
fi


# Tell python to include the src dir into the path
export PYTHONPATH=$PYTHONPATH:/workspace/src

# Set the coverage file path to a directory within /workspace/target
export COVERAGE_FILE=/target/.coverage

# Verify the PYTHONPATH
echo "PYTHONPATH: $PYTHONPATH"

# Run a quick check to ensure Python sees the src directory
python -c "import sys; print(sys.path)"

# Run pytest to discover and run all tests in that dir
pytest --maxfail=1 --disable-warnings --cov=/workspace/src --cov-report=term --cov-report=html:/target/coverage_html /workspace/tests/ 

