#!/bin/bash

# Activate the virtual environment
source /venv/bin/activate
if [[ "$VIRTUAL_ENV" != "" ]]; then
    echo "Virtual environment activated."
else
    echo "Failed to activate virtual environment."
    exit 1
fi

# Include src and tests directories in PYTHONPATH
export PYTHONPATH=$PYTHONPATH:/workspace/src:/workspace/tests

# Set the coverage file path
export COVERAGE_FILE=/target/.coverage

# Verify the PYTHONPATH
echo "PYTHONPATH: $PYTHONPATH"

# Check Python's sys.path
python -c "import sys; print(sys.path)"

# Set the path for the MonkeyType SQLite database
export MT_DB_PATH=/target/monkeytype.sqlite3

# Check if MonkeyType is enabled
if [ "$MONKEYTYPE_ENABLED" = "1" ]; then
   echo "MonkeyType is enabled. Collecting type data..."
   # https://pypi.org/project/pytest-monkeytype/
   py.test --monkeytype-output=/target/monkeytype.sqlite3  \
          --verbose                                       \
          --maxfail=1                                     \
          --disable-warnings                              \
          --cov=/workspace/src                            \
          --cov-report=term                               \
          --cov-report=html:/target/coverage_html         \
         /workspace/tests/
   
  echo "Type data collection completed."
else
   echo "MonkeyType is disabled. Running tests without type data collection."
   # Run pytest normally
   pytest --verbose                                 \ 
          --maxfail=1                               \
          --disable-warnings                        \
          --cov=/workspace/src                      \
          --cov-report=term                         \
          --cov-report=html:/target/coverage_html   \
          /workspace/tests/
   echo "Tests completed without type data collection."
fi

