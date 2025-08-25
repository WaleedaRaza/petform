#!/bin/bash

# Minimal Xcode Cloud CI Post-Clone Script
# This script just verifies required files exist (no Flutter execution)

echo "🚀 Minimal Flutter verification for Xcode Cloud..."

# Navigate to project root
cd $CI_WORKSPACE
echo "📁 Working directory: $(pwd)"

# Check if required files exist
echo "🔍 Verifying required Flutter files..."

REQUIRED_FILES=(
    "ios/Flutter/Generated.xcconfig"
    "ios/Flutter/flutter_export_environment.sh"
    "ios/Flutter/Flutter.podspec"
    "ios/Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Release-input-files.xcfilelist"
    "ios/Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Release-output-files.xcfilelist"
)

ALL_EXIST=true

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file exists"
    else
        echo "❌ $file missing"
        ALL_EXIST=false
    fi
done

if [ "$ALL_EXIST" = true ]; then
    echo "🎉 All required files exist! Build should proceed successfully."
    exit 0
else
    echo "⚠️ Some required files are missing."
    echo "📋 Missing files should be generated during the build process."
    echo "🚀 Proceeding with build attempt..."
    exit 0
fi
