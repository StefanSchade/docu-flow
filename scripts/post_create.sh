#!/bin/bash

# Fix permissions for the Docker socket if it exists
if [ -e /var/run/docker.sock ]; then
    sudo chown root:docker /var/run/docker.sock
    sudo chmod 660 /var/run/docker.sock
fi

# Take ownership for the workspace including the mounted dirs
sudo chown -R developer:developer /workspace/target

# Set executable permissions on scripts
sudo chmod +x /workspace/scripts/*.sh

# Start an interactive bash session
exec /bin/bash
