#!/bin/bash

echo "post create script"

#!/bin/bash

# Check if 'atd' is running
if ! pgrep -x "atd" > /dev/null; then
    echo "'atd' daemon is not running. Attempting to start it..."
    sudo service atd start

    # Recheck if 'atd' started successfully
    if ! pgrep -x "atd" > /dev/null
    then
        echo "Error: Failed to start 'atd'. Exiting..."
        exit 1
    else
        echo "'atd' daemon started successfully."
    fi
else
    echo "'atd' daemon is already running."
fi

echo "'atd' daemon is running. Proceeding with script execution."

echo "Wait until /var/run/docker.sock exists (retry up to 10 times)"
attempt=0
while [ ! -e /var/run/docker.sock ] && [ $attempt -lt 10 ]; do
    sleep 1
    echo "attempt ${atttempt}"
    attempt=$((attempt + 1))
done

# Fix permissions for the Docker socket if it exists
if [ -e /var/run/docker.sock ]; then
    sudo chown root:docker /var/run/docker.sock
    sudo chmod 660 /var/run/docker.sock
fi

# Take ownership for the workspace including the mounted dirs
sudo chown -R developer:developer /target || echo "Could not change ownership of /target"
sudo chown -R developer:developer /venv || echo "Could not change ownership of /venv"

# set read and write permission
sudo chmod -R 777 /target || echo "Could not change permissions of /target"
sudo chmod -R 777 /venv || echo "Could not change permissions of /venv"

# directories and shell scripts need to be executable
sudo find /venv -type d -exec chmod 755 {} \;
sudo find /venv -type f -name "*.sh" -exec chmod 755 {} \;

# setup the python virtual environment
bash ${HOME}/scripts/setup_python_virt_env.sh

# I have the PYTHONPATH doubled in the shell - apparently the ENV definition in the Dockerfile.dev
# is sufficient also for interactive shells. For the moment I comment out this section to ckeck
# if this is indeed redundand
#
# echo "Checking PYTHONPATH in .bashrc"
# if ! grep -q 'export PYTHONPATH="/workspace/src/:/workspace/tests/:$PYTHONPATH"' ~/.bashrc; then
#     echo "Adding source and test dir to PYTHONPATH"
#     echo 'export PYTHONPATH="/workspace/src/:/workspace/tests/:$PYTHONPATH"' >> ~/.bashrc
# fi

echo "Checking HOME in .bashrc"
if ! grep -q 'export PATH="${HOME}/scripts:$PATH"' ~/.bashrc; then
    echo "Adding scripts folder to PATH"
    echo 'export PATH="${HOME}/scripts:$PATH"' >> ~/.bashrc
fi

. ~/.bashrc

echo "PYTHONPATH=${PYTHONPATH}"
echo "PATH=${PATH}"

# this must not be followed by a long running method since it
# is scheduling a process one minute after completion of the script 
# relying on the assumption that the main script is finished then

echo "Updating the scripts"

${HOME}/scripts/update_scripts.sh
