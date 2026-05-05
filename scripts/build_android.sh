#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
    export $(cat .env | xargs)
fi

# Check if MAPBOX_TOKEN is set
if [ -z "$MAPBOX_TOKEN" ]; then
    echo "Error: MAPBOX_TOKEN not found in .env file"
    exit 1
fi

# Set Mapbox tokens for build
export MAPBOX_ACCESS_TOKEN=$MAPBOX_TOKEN
export MAPBOX_DOWNLOADS_TOKEN=$MAPBOX_TOKEN

echo "Mapbox tokens loaded from .env file"
echo "Building Flutter app..."

# Run flutter build with environment variables
flutter build apk --dart-define=MAPBOX_ACCESS_TOKEN=$MAPBOX_TOKEN --dart-define=MAPBOX_DOWNLOADS_TOKEN=$MAPBOX_TOKEN