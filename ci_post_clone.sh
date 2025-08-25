#!/bin/bash

# Debug Xcode Cloud CI Post-Clone Script
# This script identifies exactly why builds are failing

echo "🔍 DEBUG: Xcode Cloud environment analysis..."
echo "================================================"

# Environment variables
echo "📋 Environment Variables:"
echo "CI_WORKSPACE: $CI_WORKSPACE"
echo "CI_BUILD_ID: $CI_BUILD_ID"
echo "CI_COMMIT: $CI_COMMIT"
echo "CI_BRANCH: $CI_BRANCH"
echo "PWD: $(pwd)"
echo ""

# System information
echo "🖥️ System Information:"
echo "OS: $(uname -a)"
echo "Architecture: $(uname -m)"
echo "Available memory: $(free -h 2>/dev/null || echo 'free command not available')"
echo "Disk space: $(df -h . 2>/dev/null || echo 'df command not available')"
echo ""

# Flutter detection
echo "🔍 Flutter Detection:"
echo "PATH: $PATH"
echo ""

# Check multiple Flutter locations
FLUTTER_LOCATIONS=(
    "/usr/local/bin/flutter"
    "/opt/homebrew/bin/flutter"
    "/usr/local/flutter/bin/flutter"
    "/Users/runner/flutter/bin/flutter"
    "/Users/ci/flutter/bin/flutter"
    "/usr/bin/flutter"
)

echo "📍 Checking Flutter locations:"
for location in "${FLUTTER_LOCATIONS[@]}"; do
    if [ -x "$location" ]; then
        echo "✅ $location - EXISTS and EXECUTABLE"
        echo "   Version: $($location --version 2>/dev/null | head -n1 || echo 'Version check failed')"
    elif [ -f "$location" ]; then
        echo "⚠️ $location - EXISTS but NOT EXECUTABLE"
        ls -la "$location"
    else
        echo "❌ $location - NOT FOUND"
    fi
done
echo ""

# Check which command
echo "🔍 'which flutter' results:"
which flutter 2>/dev/null || echo "which flutter: not found"
echo ""

# Check command availability
echo "🔍 Available commands:"
echo "flutter: $(command -v flutter 2>/dev/null || echo 'not found')"
echo "dart: $(command -v dart 2>/dev/null || echo 'not found')"
echo "git: $(command -v git 2>/dev/null || echo 'not found')"
echo ""

# Navigate to workspace
echo "📁 Navigating to CI workspace..."
cd $CI_WORKSPACE
echo "Current directory: $(pwd)"
echo ""

# Check repository contents
echo "📋 Repository contents:"
ls -la
echo ""

# Check iOS directory
echo "📱 iOS directory contents:"
if [ -d "ios" ]; then
    ls -la ios/
    echo ""
    echo "📁 Flutter subdirectory:"
    if [ -d "ios/Flutter" ]; then
        ls -la ios/Flutter/
    else
        echo "❌ ios/Flutter directory not found"
    fi
    echo ""
    echo "📁 Pods directory:"
    if [ -d "ios/Pods" ]; then
        ls -la ios/Pods/Target\ Support\ Files/Pods-Runner/ 2>/dev/null || echo "Pods-Runner directory not found"
    else
        echo "❌ ios/Pods directory not found"
    fi
else
    echo "❌ ios directory not found"
fi
echo ""

# Check pubspec.yaml
echo "📦 pubspec.yaml check:"
if [ -f "pubspec.yaml" ]; then
    echo "✅ pubspec.yaml exists"
    echo "First few lines:"
    head -5 pubspec.yaml
else
    echo "❌ pubspec.yaml not found"
fi
echo ""

# Try to run Flutter if available
if command -v flutter &> /dev/null; then
    echo "🚀 Flutter found, attempting basic commands..."
    
    echo "📋 Flutter version:"
    flutter --version 2>&1 || echo "Flutter version failed"
    echo ""
    
    echo "📦 Flutter doctor:"
    flutter doctor 2>&1 || echo "Flutter doctor failed"
    echo ""
    
    echo "🔧 Flutter pub get:"
    flutter pub get 2>&1 || echo "Flutter pub get failed"
    echo ""
    
    echo "📱 Flutter build ios:"
    flutter build ios --no-codesign --debug 2>&1 || echo "Flutter build failed"
    echo ""
    
    echo "📁 After Flutter commands - Flutter directory:"
    if [ -d "ios/Flutter" ]; then
        ls -la ios/Flutter/
    fi
    echo ""
    
    echo "📁 After Flutter commands - Pods directory:"
    if [ -d "ios/Pods" ]; then
        ls -la ios/Pods/Target\ Support\ Files/Pods-Runner/ 2>/dev/null || echo "Pods-Runner directory not found"
    fi
else
    echo "❌ Flutter not available in PATH"
    echo "🔍 Trying to find Flutter in common locations..."
    
    # Try to add Flutter to PATH
    for location in "${FLUTTER_LOCATIONS[@]}"; do
        if [ -x "$location" ]; then
            echo "✅ Found Flutter at $location, adding to PATH..."
            export PATH="$(dirname $location):$PATH"
            break
        fi
    done
    
    # Try again
    if command -v flutter &> /dev/null; then
        echo "🚀 Flutter now available, attempting commands..."
        flutter --version 2>&1 || echo "Flutter version failed"
    else
        echo "❌ Still cannot find Flutter"
    fi
fi

echo "================================================"
echo "🔍 DEBUG: End of environment analysis"
echo ""

# Final status
echo "📊 FINAL STATUS:"
if command -v flutter &> /dev/null; then
    echo "✅ Flutter: AVAILABLE"
else
    echo "❌ Flutter: NOT AVAILABLE"
fi

if [ -f "ios/Flutter/Generated.xcconfig" ]; then
    echo "✅ Generated.xcconfig: EXISTS"
else
    echo "❌ Generated.xcconfig: MISSING"
fi

if [ -f "ios/Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Release-input-files.xcfilelist" ]; then
    echo "✅ Pods framework files: EXIST"
else
    echo "❌ Pods framework files: MISSING"
fi

echo ""
echo "🚀 Proceeding with build attempt..."
exit 0
