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

# Function to install packages
install_packages() {
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            echo "Installing $line"
            pip install "$line" --break-system-packages
        fi
    done <<< "$1"
}

# Function to uninstall packages
uninstall_packages() {
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            echo "Uninstalling $line"
            pip uninstall -y "$line"
        fi
    done <<< "$1"
}

# Function to compare requirements files and handle installations/uninstallations
manage_requirements() {
    local current_file="$1"
    local cached_file="$2"

    # Check if the cached requirements file exists
    if [ ! -f "$cached_file" ]; then
        echo "No cached file found. Installing all packages in $current_file"
        pip install --no-cache-dir --no-warn-script-location -r "$current_file" --break-system-packages
    else
        # Packages to install (new entries in the current requirements file)
        to_install=$(diff --new-line-format="%L" --old-line-format="" --unchanged-line-format="" "$cached_file" "$current_file")
        install_packages "$to_install"

        # Packages to uninstall (entries removed from the current requirements file)
        to_uninstall=$(diff --new-line-format="" --old-line-format="%L" --unchanged-line-format="" "$cached_file" "$current_file")
        uninstall_packages "$to_uninstall"
    fi

    # Update the cached requirements file
    cp "$current_file" "$cached_file"
}

# Check if the virtual environment exists
if [ ! -d "$VENV_DIR/bin" ]; then
    echo "Virtual environment not found. Setting up a new virtual environment..."
    python3 -m venv "$VENV_DIR"

    echo "Activating the new virtual environment..."
    source "$VENV_DIR/bin/activate"

    echo "Installing all packages from requirements.txt..."
    pip install --no-cache-dir --no-warn-script-location -r "$CURRENT_REQ_FILE" --break-system-packages

    echo "Installing all packages from requirements-dev.txt..."
    pip install --no-cache-dir --no-warn-script-location -r "$CURRENT_DEV_REQ_FILE" --break-system-packages

    # Ensure the requirements directory exists in the virtual environment
    mkdir -p "$VENV_REQS_DIR"

    # Copy the current requirements files to the virtual environment for future comparison
    cp "$CURRENT_REQ_FILE" "$CACHED_REQ_FILE"
    cp "$CURRENT_DEV_REQ_FILE" "$CACHED_DEV_REQ_FILE"
else
    # Activate the virtual environment
    echo "Activating the virtual environment..."
    source "$VENV_DIR/bin/activate"

    # Manage packages from requirements.txt
    echo "Managing production dependencies..."
    manage_requirements "$CURRENT_REQ_FILE" "$CACHED_REQ_FILE"

    # Manage packages from requirements-dev.txt
    echo "Managing development dependencies..."
    manage_requirements "$CURRENT_DEV_REQ_FILE" "$CACHED_DEV_REQ_FILE"
fi

# List installed packages
echo "These are the packages that have been installed..."
pip list

# Feedback message indicating the end of the process
echo "Python virtual environment setup is complete."
