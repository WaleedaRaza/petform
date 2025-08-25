#!/bin/bash

# Xcode Cloud CI Post-Clone Script
# This script runs after the repository is cloned in Xcode Cloud

echo "🚀 Setting up Flutter for Xcode Cloud build..."

# Set Flutter path (Xcode Cloud has Flutter pre-installed)
export PATH="$PATH:/usr/local/bin"

# Verify Flutter installation
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found in PATH"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n1)"

# Navigate to project root
cd $CI_WORKSPACE

# Clean and regenerate Flutter files
echo "🧹 Cleaning Flutter build cache..."
flutter clean

echo "📦 Getting Flutter dependencies..."
flutter pub get

echo "🔧 Generating iOS configuration files..."
flutter build ios --no-codesign --debug

echo "✅ Flutter setup complete for Xcode Cloud!"
echo "📁 Generated files:"
ls -la ios/Flutter/
