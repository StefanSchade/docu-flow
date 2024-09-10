#!/bin/bash

echo "post create script"

# Wait until /var/run/docker.sock exists (retry up to 10 times)
attempt=0
while [ ! -e /var/run/docker.sock ] && [ $attempt -lt 10 ]; do
    sleep 1
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
/workspace/scripts/setup_python_virt_env.sh

# add current dir to PATH
echo 'export PATH=$PATH:/workspace/scripts/' >> ~/.bashrc
source ~/.bashrc
