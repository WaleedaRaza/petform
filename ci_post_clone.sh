#!/bin/bash
# ci_post_clone.sh (root level for Xcode Cloud)
# Fail fast and log commands
set -euo pipefail
IFS=$'\n\t'
echo "===== ci_post_clone: start ====="

# Helpful logging
echo "SHELL: $SHELL"
echo "PWD: $(pwd)"
echo "Xcode version: $(xcodebuild -version || true)"
echo "Swift version: $(swift --version || true)"
echo "PATH: $PATH"

# CocoaPods: prefer the system one, but ensure we can run it
if ! command -v pod >/dev/null 2>&1; then
  export GEM_HOME="$PWD/.gem"
  export GEM_PATH="$GEM_HOME"
  export PATH="$GEM_HOME/bin:$PATH"
  gem install cocoapods -N
fi

# Run pods inside ios/ directory
if [ -d "ios" ]; then
  echo "📱 Installing CocoaPods in ios/ directory..."
  pushd ios
  
  # If your repo doesn't commit Pods/, always generate them fresh
  pod repo update --silent || true
  pod install
  
  # Verify the filelists exist (helps catch mis-path issues early)
  echo "🔍 Verifying CocoaPods framework filelists..."
  ls "Pods/Target Support Files/Pods-Runner/"Pods-Runner-frameworks-*-input-files.xcfilelist || echo "⚠️ Some input filelists missing"
  ls "Pods/Target Support Files/Pods-Runner/"Pods-Runner-frameworks-*-output-files.xcfilelist || echo "⚠️ Some output filelists missing"
  
  popd
else
  echo "❌ ios directory not found"
  exit 1
fi

# Verify Flutter configuration files exist
echo "🔍 Verifying Flutter configuration files..."
REQUIRED_FILES=(
    "ios/Flutter/Generated.xcconfig"
    "ios/Flutter/flutter_export_environment.sh"
    "ios/Flutter/Flutter.podspec"
    "ios/Flutter/Debug.xcconfig"
    "ios/Flutter/Release.xcconfig"
    "ios/Flutter/Profile.xcconfig"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file exists"
    else
        echo "❌ $file missing"
    fi
done

echo "===== ci_post_clone: complete ====="
