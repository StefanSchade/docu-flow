#!/bin/bash
#
# explanation: As we run in a container that mounts the project repo read only
# we can not rely on these scripts being executable. Therefore they are copied
# over to ~/scripts where we can take ownership and run them. However after a
# change, these copies have to be refreshed - this is the responsibiliy of this
# script.
#
# One challenge is, that the script performing the update itself is subject to
# the update (and as this script can be called by some other scripts the challenge
# extends to those scripts as well.) to avoid the issue of a script copying itself
# we copy to a third place and schedule the actuall replacement for a time when the
# script is not running anymore.


# Define source and target directories
SOURCE_DIR="/workspace/scripts/"
TARGET_DIR="~/scripts/"

# Create the target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Recursively copy all .sh files from source to target directory
find "$SOURCE_DIR" -name "*.sh" -exec cp --parents {} "$TARGET_DIR" \;

# Change ownership of all copied .sh files to the current user
sudo chown -R $(whoami):$(whoami) "$TARGET_DIR"

# Make all .sh files in the target directory executable and readable for everyone
chmod -R a+r,u+rx,g+rx "$TARGET_DIR"

echo "Scripts copied, ownership changed, and made executable and readable."

