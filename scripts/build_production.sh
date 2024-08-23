#!/bin/bash

# This is not set if we run outside a github action pipe
if [ -z "$GITHUB_ACTOR" ]; then
    echo "Warning: GITHUB_ACTOR is not set. Using 'default-user'."
    GITHUB_ACTOR="StefanSchade"
fi

# Convert GITHUB_ACTOR to lowercase
GITHUB_ACTOR=$(echo "$GITHUB_ACTOR" | tr '[:upper:]' '[:lower:]')

# Set the image name and tag
IMAGE_NAME="ghcr.io/${GITHUB_ACTOR}/my-app-prod"
IMAGE_TAG="latest"

# Verify Docker is accessible
if ! docker info > /dev/null 2>&1; then
    echo "Error: Cannot connect to the Docker daemon."
    exit 1
fi

# Build the production Docker image
docker build -f /workspace/docker/Dockerfile.prod -t ${IMAGE_NAME}:${IMAGE_TAG} /workspace

# Check if running in GitHub Actions
if [ -z "$GITHUB_ACTIONS" ]; then
    echo "Not running in GitHub Actions, skipping push to registry."
    exit 0  # Exit with success since we don't want to push locally
else
    # Push the Docker image to GitHub Container Registry
    docker push ${IMAGE_NAME}:${IMAGE_TAG}
fi
