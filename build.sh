#!/bin/bash
set -e

# Configure with CMake preset
echo "Configuring with CMake preset..."
cmake --preset Release

# Build the main HarfBuzz target in release mode
echo "Building HarfBuzz (Release)..."
cmake --build --preset Release --target HarfBuzz
