#!/usr/bin/env bash
# One-shot Android SDK install for the sidemdm Codespaces / devcontainer build.
# Runs as the vscode user; sudo is available for /opt writes.
set -euo pipefail

SDK_DIR="${ANDROID_HOME:-/opt/android-sdk}"
CMDLINE_TOOLS_VERSION="11076708"   # commandlinetools-linux-<ver>_latest.zip
PLATFORM="android-36"
BUILD_TOOLS="36.0.0"

echo "Installing Android SDK into $SDK_DIR"
sudo mkdir -p "$SDK_DIR/cmdline-tools"
sudo chown -R "$(id -u):$(id -g)" "$SDK_DIR"

# Use our own working dir under /tmp so the zip can be cleaned up.
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cd "$work"

curl -sSLf -o cmdline.zip \
  "https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS_VERSION}_latest.zip"

unzip -q cmdline.zip
# The zip contains a top-level 'cmdline-tools' directory that we want at
# $SDK_DIR/cmdline-tools/latest. Move accordingly.
rm -rf "$SDK_DIR/cmdline-tools/latest"
mv cmdline-tools "$SDK_DIR/cmdline-tools/latest"

SDKMANAGER="$SDK_DIR/cmdline-tools/latest/bin/sdkmanager"

# Accept licenses non-interactively and install the packages the Gradle build needs.
yes | "$SDKMANAGER" --licenses >/dev/null
"$SDKMANAGER" "platform-tools" "platforms;${PLATFORM}" "build-tools;${BUILD_TOOLS}"

# Make the Gradle wrapper executable (may already be ex).
if [ -f android/gradlew ]; then
  chmod +x android/gradlew
fi

echo
echo "Ready. To build:"
echo "  cd android && ./gradlew :app:testDebugUnitTest :app:assembleRelease"
