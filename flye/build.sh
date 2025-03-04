#!/bin/bash
set -e  # Exit on errors

# Dynamic build arguments
## Software
### Flye
#### Source
FLYE_SOURCE=https://github.com/mikolmogorov/Flye
#### Version
##### Fetch the latest Flye version from the new repository
FLYE_VERSION=$(curl -s "https://api.github.com/repos/mikolmogorov/Flye/releases/latest" | jq -r '.tag_name')
##### Check if the version was fetched successfully
if [[ -z "$FLYE_VERSION" ]]; then
    echo "Failed to fetch the latest Flye version. Exiting."
    exit 1
fi
echo "Latest Flye version is: $FLYE_VERSION"
## Date
BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')

# Build the Docker image
echo "Building Flye v$FLYE_VERSION ($FLYE_SOURCE)"
docker build \
-f Dockerfile \
--build-arg BUILD_DATE="$BUILD_DATE" \
--build-arg FLYE_VERSION="$FLYE_VERSION" \
--build-arg FLYE_SOURCE="$FLYE_SOURCE" \
-t flye:latest .