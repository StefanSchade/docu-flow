#!/bin/bash

# Take ownership for the workspace including the mounted dirs
sudo chown -R developer:developer /workspace/target

# Set executable permissions on scripts
sudo chmod +x /workspace/scripts/*.sh
