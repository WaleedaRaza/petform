#!/bin/bash

# Simple Xcode Cloud CI Post-Clone Script
# This script ensures required Flutter files exist

echo "🚀 Simple Flutter setup for Xcode Cloud..."

# Navigate to project root
cd $CI_WORKSPACE
echo "📁 Working directory: $(pwd)"

# Check if required files already exist
echo "🔍 Checking for required Flutter files..."

REQUIRED_FILES=(
    "ios/Flutter/Generated.xcconfig"
    "ios/Flutter/flutter_export_environment.sh"
    "ios/Flutter/Flutter.podspec"
    "ios/Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Release-input-files.xcfilelist"
    "ios/Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Release-output-files.xcfilelist"
)

MISSING_FILES=()

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file exists"
    else
        echo "❌ $file missing"
        MISSING_FILES+=("$file")
    fi
done

if [ ${#MISSING_FILES[@]} -eq 0 ]; then
    echo "🎉 All required files exist! Build should proceed."
    exit 0
else
    echo "⚠️ Some files are missing. Attempting to generate them..."
    
    # Try to run Flutter commands if available
    if command -v flutter &> /dev/null; then
        echo "📦 Running flutter pub get..."
        flutter pub get || echo "⚠️ flutter pub get failed"
        
        echo "🔧 Running flutter build ios..."
        flutter build ios --no-codesign --debug || echo "⚠️ flutter build failed"
    else
        echo "⚠️ Flutter not available, but required files should be in repository"
    fi
    
    # Final check
    echo "🔍 Final check of required files:"
    for file in "${REQUIRED_FILES[@]}"; do
        if [ -f "$file" ]; then
            echo "✅ $file exists"
        else
            echo "❌ $file still missing"
        fi
    done
    
    echo "🚀 Proceeding with build attempt..."
    exit 0
fi
