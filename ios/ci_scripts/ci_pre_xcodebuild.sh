#!/bin/bash

# Xcode Cloud Pre-Build Script
# This runs BEFORE xcodebuild and handles CocoaPods setup

echo "🚀 Pre-build setup for Xcode Cloud..."

# Navigate to project root
cd $CI_WORKSPACE
echo "📁 Working directory: $(pwd)"

# Check if Pods directory exists and is properly set up
if [ -d "ios/Pods" ]; then
    echo "✅ Pods directory exists"
    
    # Verify Podfile.lock and Manifest.lock are in sync
    if [ -f "ios/Podfile.lock" ] && [ -f "ios/Pods/Manifest.lock" ]; then
        echo "🔍 Checking Podfile.lock vs Manifest.lock..."
        
        # Inline the diff check that Xcode Cloud blocks
        if diff "ios/Podfile.lock" "ios/Pods/Manifest.lock" > /dev/null 2>&1; then
            echo "✅ Podfile.lock and Manifest.lock are in sync"
            echo "SUCCESS" > "${CI_DERIVED_DATA_DIR}/Pods-Runner-checkManifestLockResult.txt"
        else
            echo "❌ Podfile.lock and Manifest.lock are out of sync"
            echo "🔧 Attempting to fix by running pod install..."
            
            # Try to run pod install if available
            if command -v pod &> /dev/null; then
                cd ios
                pod install --repo-update || echo "⚠️ pod install failed, continuing..."
                cd ..
            else
                echo "⚠️ pod command not available, continuing with build..."
            fi
        fi
    else
        echo "⚠️ Podfile.lock or Manifest.lock missing, continuing..."
    fi
else
    echo "❌ Pods directory not found"
    echo "🔧 This may cause build failures in Xcode Cloud"
fi

# Verify Flutter configuration files exist
echo "🔍 Verifying Flutter configuration files..."
REQUIRED_FILES=(
    "ios/Flutter/Generated.xcconfig"
    "ios/Flutter/flutter_export_environment.sh"
    "ios/Flutter/Flutter.podspec"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file exists"
    else
        echo "❌ $file missing"
    fi
done

echo "🚀 Pre-build setup complete, proceeding with xcodebuild..."
