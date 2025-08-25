#!/bin/bash
# ci_post_clone_minimal.sh (root level for Xcode Cloud)
# Minimal but robust post-clone script

echo "===== ci_post_clone_minimal: start ====="

# Basic environment logging
echo "PWD: $(pwd)"
echo "SHELL: $SHELL"

# Set safe defaults to avoid -u crashes
: "${CONFIGURATION:=Release}"
: "${SCHEME:=Runner}"
: "${WORKSPACE:=Runner.xcworkspace}"

echo "CONFIGURATION=$CONFIGURATION"
echo "SCHEME=$SCHEME"
echo "WORKSPACE=$WORKSPACE"

# Check if required directories exist
if [ -d "ios" ]; then
    echo "✅ ios directory exists"
else
    echo "❌ ios directory missing"
    exit 1
fi

if [ -d "ios/Pods" ]; then
    echo "✅ Pods directory exists"
else
    echo "❌ Pods directory missing"
    exit 1
fi

# Check if required files exist
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
    echo "🎉 All required files exist!"
else
    echo "⚠️ Some files are missing, but continuing..."
fi

echo "===== ci_post_clone_minimal: complete ====="
