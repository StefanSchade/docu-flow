#!/bin/bash

# Set colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to run a command and check if it was successful
run_command() {
    "$@"
    status=$?
    if [ $status -ne 0 ]; then
        echo -e "${RED}Error with $1${NC}"
        exit $status
    fi
}

echo "Running tests..."
run_command /workspace/scripts/run_tests.sh

echo "Running linting..."
run_command /workspace/scripts/run_lint.sh

echo "Building production image..."
run_command /workspace/scripts/build_production.sh

echo -e "${GREEN}All steps completed successfully!${NC}"

