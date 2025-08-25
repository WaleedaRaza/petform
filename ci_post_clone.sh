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

# If you need Ruby gems (e.g., CocoaPods plugins), use the system Ruby and a local GEM_HOME
export GEM_HOME="$PWD/.gem"
export GEM_PATH="$GEM_HOME"
export PATH="$GEM_HOME/bin:$PATH"

# If you need Python tools
export PIP_USER=no
export PYTHONUSERBASE="$PWD/.pypkg"
export PATH="$PYTHONUSERBASE/bin:$PATH"

# Example: only run CocoaPods if a Podfile exists
if [[ -f "ios/Podfile" || -f "Podfile" ]]; then
  echo "Podfile found – attempting pod install"
  # CocoaPods is preinstalled in Xcode Cloud; avoid sudo and verbose noise
  # Use || true to prevent script failure if pod commands fail
  pod repo update --silent || echo "⚠️ pod repo update failed, continuing..."
  pod install --project-directory=ios || echo "⚠️ pod install failed, continuing..."
else
  echo "No Podfile found, skipping CocoaPods setup"
fi

# Example: install SwiftLint if used and not present
if grep -Riq "swiftlint" .; then
  if ! command -v swiftlint >/dev/null 2>&1; then
    echo "Installing SwiftLint via Mint (local vendor)"
    # Vendor Mint in repo or fetch a prebuilt binary you commit to Tools/
    # Safe fallback: use SwiftPM to build a local tool cache
    mkdir -p Tools
    pushd Tools
    if ! command -v xcrun >/dev/null; then echo "xcrun not found"; exit 1; fi
    if [ ! -f ./swiftlint ]; then
      echo "Building SwiftLint with SwiftPM (may take a bit)"
      git clone --depth 1 https://github.com/realm/SwiftLint.git
      pushd SwiftLint
      swift build -c release
      cp .build/release/swiftlint ../swiftlint
      popd
    fi
    export PATH="$PWD:$PATH"
    popd
  fi
  echo "SwiftLint version: $(swiftlint version)"
fi

# Example: set default env vars if not provided (avoid -u crashes)
: "${CONFIGURATION:=Release}"
: "${SCHEME:=Runner}"
: "${WORKSPACE:=Runner.xcworkspace}"

echo "CONFIGURATION=$CONFIGURATION"
echo "SCHEME=$SCHEME"
echo "WORKSPACE=$WORKSPACE"

# If you decrypt or read secrets, guard missing values
if [[ -n "${MY_SECRET:-}" ]]; then
  echo "Secret present (length: ${#MY_SECRET})"
else
  echo "MY_SECRET not set; skipping secret-dependent steps"
fi

echo "===== ci_post_clone: complete ====="
