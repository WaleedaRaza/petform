#!/bin/bash

# Xcode Cloud Post-Build Script
# This runs AFTER xcodebuild completes

echo "🚀 Post-build processing for Xcode Cloud..."

# Navigate to project root
cd $CI_WORKSPACE
echo "📁 Working directory: $(pwd)"

# Check build results
if [ $CI_XCODEBUILD_RESULT -eq 0 ]; then
    echo "✅ Build completed successfully!"
    
    # Check if the app was built
    if [ -f "ios/build/ios/iphoneos/Runner.app" ]; then
        echo "✅ Runner.app created successfully"
        echo "📱 App size: $(du -h ios/build/ios/iphoneos/Runner.app | cut -f1)"
    else
        echo "⚠️ Runner.app not found in expected location"
    fi
else
    echo "❌ Build failed with exit code: $CI_XCODEBUILD_RESULT"
    echo "🔍 Check build logs for specific error details"
fi

# Show final status of required files
echo "📊 Final status of required files:"
REQUIRED_FILES=(
    "ios/Flutter/Generated.xcconfig"
    "ios/Flutter/flutter_export_environment.sh"
    "ios/Flutter/Flutter.podspec"
    "ios/Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Release-input-files.xcfilelist"
    "ios/Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Release-output-files.xcfilelist"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file exists"
    else
        echo "❌ $file missing"
    fi
done

echo "🚀 Post-build processing complete!"
