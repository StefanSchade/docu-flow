#!/bin/bash

# Feedback message indicating the start of the process
echo "Python virtual environment setup"

# Define the virtual environment directory
VENV_DIR="/venv"
WORKSPACE_DIR="/workspace"
VENV_REQS_DIR="$VENV_DIR/requirements"
CURRENT_REQ_FILE="$WORKSPACE_DIR/requirements.txt"
CURRENT_DEV_REQ_FILE="$WORKSPACE_DIR/requirements-dev.txt"
CACHED_REQ_FILE="$VENV_REQS_DIR/requirements.txt"
CACHED_DEV_REQ_FILE="$VENV_REQS_DIR/requirements-dev.txt"

# Take ownership
sudo chown -R developer:developer "$VENV_DIR"

# Create directory for cached requirements files if it doesn't exist
echo "Creating requirements directory at $VENV_REQS_DIR..."
mkdir -p "$VENV_REQS_DIR"

# Function to compute the checksum of a file
compute_checksum() {

    if [ -f "$1" ]; then
        md5sum "$1" | awk '{ print $1 }'
    else
        echo "file_not_found"
    fi
}

# Compute checksums for current and cached requirements files
CURRENT_REQ_CHECKSUM=$(compute_checksum "$CURRENT_REQ_FILE")
CURRENT_DEV_REQ_CHECKSUM=$(compute_checksum "$CURRENT_DEV_REQ_FILE")
CACHED_REQ_CHECKSUM=$(compute_checksum "$CACHED_REQ_FILE")
CACHED_DEV_REQ_CHECKSUM=$(compute_checksum "$CACHED_DEV_REQ_FILE")

# Check if the virtual environment already exists and if requirements have changed
if [ -d "$VENV_DIR" ] && [ "$CURRENT_REQ_CHECKSUM" == "$CACHED_REQ_CHECKSUM" ] && [ "$CURRENT_DEV_REQ_CHECKSUM" == "$CACHED_DEV_REQ_CHECKSUM" ]; then
    echo "No changes in requirements files. Skipping virtual environment setup."
else
    echo "Requirements files have changed or virtual environment does not exist. Setting up the virtual environment..."

    # Remove the contents of the existing virtual environment if it exists
    if [ -d "$VENV_DIR" ]; then
        echo "Removing existing virtual environment contents to start fresh..."
        sudo rm -rf "$VENV_DIR"/*
    fi

    # Create a new virtual environment
    echo "Creating a new Python virtual environment - this may take a while..."
    python3 -m venv "$VENV_DIR"

    # Activate the virtual environment
    echo "Activating the virtual environment..."
    source "$VENV_DIR/bin/activate"

    # Install dependencies from requirements files
    echo "Installing dependencies for production AND development"
    pip install --no-cache-dir --no-warn-script-location -r "$CURRENT_REQ_FILE" --break-system-packages
    pip install --no-cache-dir --no-warn-script-location -r "$CURRENT_DEV_REQ_FILE" --break-system-packages

    # Update the cached requirements files with the current ones
    echo "Updating cached requirements files..."
    cp "$CURRENT_REQ_FILE" "$CACHED_REQ_FILE"
    cp "$CURRENT_DEV_REQ_FILE" "$CACHED_DEV_REQ_FILE"

    # Feedback message indicating the end of the process
    echo "Python virtual environment setup is complete."
fi

# Activate the virtual environment
echo "Activating the virtual environment..."
source "$VENV_DIR/bin/activate"

# List installed packages
echo "These are the packages that have been installed..."
pip list

