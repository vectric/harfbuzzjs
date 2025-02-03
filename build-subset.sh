#!/bin/bash
set -e

# Configure with CMake preset
echo "Configuring with CMake preset..."
cmake --preset Release

# Build the HarfBuzz Subset target in release mode
echo "Building HarfBuzz Subset (Release)..."
cmake --build --preset Release --target HarfBuzzSubset
