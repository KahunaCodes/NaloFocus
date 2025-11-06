#!/bin/bash

# Build and run NaloFocus in development mode
echo "Building NaloFocus..."
swift build

if [ $? -eq 0 ]; then
    echo "Launching NaloFocus..."
    ./.build/debug/NaloFocus
else
    echo "Build failed!"
    exit 1
fi