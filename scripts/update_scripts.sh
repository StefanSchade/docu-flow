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
if [ -d $TEMP_DIR ]; then
    echo "Error: Temporary directory $TEMP_DIR already exists. Aborting."
    exit 1
fi

echo "Creating temporary directory for scripts: ${TEMP_DIR}"
# Create the temporary directory
mkdir -p $TEMP_DIR

# Use tar to copy only the structure under /workspace/scripts to the temporary directory
(
    cd "$SOURCE_DIR"
    tar cf - . | (cd "$TEMP_DIR" && tar xf -)
)

# Change ownership of all copied .sh files to the current user
sudo chown -R $(whoami):$(whoami) "$TEMP_DIR"

# Make all .sh files in the temporary directory executable and readable for everyone
find "$TEMP_DIR" -name "*.sh" -exec chmod a+r,u+rx,g+rx {} \;

# Schedule the replacement of the current ~/scripts directory with the temporary one
# echo "mv -T $TEMP_DIR $TARGET_DIR && rm -rf $TEMP_DIR" | at now + 1 minute

# As the very last operation, refresh the shell's command cache by rehashing
# echo "hash -r" | at now + 1 minute 1 second

# Define log file
DELAYED_ACTION_LOGFILE="${HOME}/delayed_action.log"

# Schedule the replacement of the current ~/scripts directory with the temporary one
# echo "echo 'Starting script at $(date)' >> $DELAYED_ACTION_LOGFILE; \
# whoami >> $DELAYED_ACTION_LOGFILE; \
# cp -r /home/developer/.tmp_scripts_$RANDOM_NUMBER/* /home/developer/scripts/ >> $DELAYED_ACTION_LOGFILE 2>&1; \
# rm -rf /home/developer/.tmp_scripts_$RANDOM_NUMBER >> $DELAYED_ACTION_LOGFILE 2>&1; \
# echo 'Script completed at $(date)' >> $DELAYED_ACTION_LOGFILE; \
# echo -e '\a'" | at now + 2 minute

rm -f $DELAYED_ACTION_LOGFILE

# Schedule the replacement of the current ~/scripts directory with the temporary one
echo "EXEC_TIME=\$(date); \
echo \"Starting script at $(date)\" >> $DELAYED_ACTION_LOGFILE; \
whoami >> $DELAYED_ACTION_LOGFILE; \
cp -r /home/developer/.tmp_scripts_$RANDOM_NUMBER/* /home/developer/scripts/ >> $DELAYED_ACTION_LOGFILE 2>&1; \
rm -rf /home/developer/.tmp_scripts_$RANDOM_NUMBER >> $DELAYED_ACTION_LOGFILE 2>&1; \
EXEC_TIME=\$(date); \
echo \"Script completed at \${EXEC_TIME}\" >> $DELAYED_ACTION_LOGFILE; \
echo -e '\a'" | at now + 1 minutes

# Add a line to log the time of committing and the job queue status to the log file
atq >> $DELAYED_ACTION_LOGFILE

echo "Scripts copied to $TEMP_DIR, ownership changed, and made executable."
echo "Replacement scheduled and will be executed within 1 minute from $(date)"

