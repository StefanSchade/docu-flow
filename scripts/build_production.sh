#!/bin/bash

# Set the image name and tag
IMAGE_NAME="ghcr.io/${GITHUB_ACTOR}/my-app-prod"
IMAGE_TAG="latest"

# Build the production Docker image
docker build -f Dockerfile.prod -t ${IMAGE_NAME}:${IMAGE_TAG} .

# Push the Docker image to GitHub Container Registry
docker push ${IMAGE_NAME}:${IMAGE_TAG}

