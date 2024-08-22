#!/bin/bash

# Set the image name and tag
IMAGE_NAME="my-app-prod"
IMAGE_TAG="latest"

# Build the production Docker image
docker build -f Dockerfile.prod -t ${IMAGE_NAME}:${IMAGE_TAG} .

# Optionally, you can add more logic here, such as pushing the image to a registry
# docker push ${IMAGE_NAME}:${IMAGE_TAG}

