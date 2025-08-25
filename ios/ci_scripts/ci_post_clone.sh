#!/bin/bash

# Xcode Cloud CI Post-Clone Script
# This script runs after the repository is cloned in Xcode Cloud

echo "🚀 Setting up Flutter for Xcode Cloud build..."

# Set multiple possible Flutter paths
export PATH="$PATH:/usr/local/bin:/opt/homebrew/bin:/usr/local/flutter/bin"

# Try to find Flutter in common locations
FLUTTER_PATH=""
for path in "/usr/local/bin/flutter" "/opt/homebrew/bin/flutter" "/usr/local/flutter/bin/flutter" "$(which flutter)"; do
    if [ -x "$path" ]; then
        FLUTTER_PATH="$path"
        echo "✅ Found Flutter at: $path"
        break
    fi
done

# If Flutter not found, try to install it
if [ -z "$FLUTTER_PATH" ]; then
    echo "⚠️ Flutter not found in common paths, attempting to install..."
    
    # Try to install Flutter using different methods
    if command -v brew &> /dev/null; then
        echo "📦 Installing Flutter via Homebrew..."
        brew install --cask flutter
        export PATH="$PATH:/opt/homebrew/bin"
    elif [ -d "/usr/local/flutter" ]; then
        echo "📦 Using system Flutter installation..."
        export PATH="$PATH:/usr/local/flutter/bin"
    else
        echo "❌ Could not find or install Flutter"
        echo "🔍 Available commands:"
        which -a flutter || echo "No flutter found"
        echo "🔍 PATH: $PATH"
        echo "🔍 Available in /usr/local/bin:"
        ls -la /usr/local/bin/ | grep flutter || echo "No flutter in /usr/local/bin"
        exit 1
    fi
fi

# Verify Flutter installation
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter still not found after setup attempts"
    echo "🔍 Final PATH: $PATH"
    echo "🔍 Available commands:"
    which -a flutter || echo "No flutter found"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n1)"

# Navigate to project root
cd $CI_WORKSPACE
echo "📁 Working directory: $(pwd)"

# Clean and regenerate Flutter files
echo "🧹 Cleaning Flutter build cache..."
flutter clean || echo "⚠️ Flutter clean failed, continuing..."

echo "📦 Getting Flutter dependencies..."
flutter pub get || {
    echo "❌ Flutter pub get failed"
    exit 1
}

echo "🔧 Generating iOS configuration files..."
flutter build ios --no-codesign --debug || {
    echo "❌ Flutter build failed"
    echo "🔍 Checking what files exist:"
    ls -la ios/Flutter/ || echo "No Flutter directory"
    exit 1
}

echo "✅ Flutter setup complete for Xcode Cloud!"
echo "📁 Generated files:"
ls -la ios/Flutter/
