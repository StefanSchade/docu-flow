#!/bin/bash

# Activate the virtual environment
source /venv/bin/activate

# Verify that the virtual environment was activated
if [[ "$VIRTUAL_ENV" != "" ]]; then
    echo "Virtual environment activated."
else
    echo "Failed to activate virtual environment."
    exit 1
fi

# Hardcoded data directory in the container
DATA_DIR="/workspace/data"

# Run the Python pipeline, passing all script arguments and setting the data directory
python /workspace/src/main.py --data-dir "$DATA_DIR" "$@"

# Deactivate the virtual environment
deactivate

