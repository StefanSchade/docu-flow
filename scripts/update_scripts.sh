#!/bin/bash
#
# explanation: As we run in a container that mounts the project repo read-only,
# we cannot rely on these scripts being executable. Therefore, they are copied
# over to ~/scripts where we can take ownership and run them. After a change,
# these copies have to be refreshed—this is the responsibility of this script.
#
# The challenge is that this script (update_scripts.sh) itself is subject to
# the update, and it might also be called by other scripts. To avoid a script
# copying itself while running, we copy to a temporary directory with a random
# number and schedule the replacement once the script is not running anymore.

# Define source and target directories
SOURCE_DIR="/workspace/scripts/"
TARGET_DIR="${HOME}/scripts"

# Generate a random number for the temporary directory
RANDOM_NUMBER=$(shuf -i 10000-99999 -n 1)
TEMP_DIR="${HOME}/.tmp_scripts_$RANDOM_NUMBER"

# Check if the temporary directory already exists
if [ -d "$TEMP_DIR" ]; then
    echo "Error: Temporary directory $TEMP_DIR already exists. Aborting."
    exit 1
fi


echo "creating temporary directory for scripts: ${TEMP_DIR}"
# Create the temporary directory
mkdir -p $TEMP_DIR

# Recursively copy all .sh files from source to the temporary directory
find "$SOURCE_DIR" -name "*.sh" -exec cp --parents {} "$TEMP_DIR" \;

# Change ownership of all copied .sh files to the current user
sudo chown -R $(whoami):$(whoami) "$TEMP_DIR"

# Make all .sh files in the temporary directory executable and readable for everyone
chmod -R a+r,u+rx,g+rx "$TEMP_DIR"

# Schedule the replacement of the current ~/scripts directory with the temporary one
echo "mv $TEMP_DIR/* $TARGET_DIR && rm -rf $TEMP_DIR" | at now + 1 minute
# as the very last operation, refresh the shells command cache by rehashing
echo "hash -r" | at now + 1 minute 1 second

echo "Scripts copied to $TEMP_DIR, ownership changed, and made executable."
echo "Replacement scheduled in 1 minute."
echo ${date}
