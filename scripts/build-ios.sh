#!/bin/bash
# Build Flutter iOS App for TestFlight
# Requires macOS with Xcode installed

set -e

API_URL="${1:-https://dipoll.net/api/counter/}"
BUILD_NUMBER="${2:-}"
OPEN_XCODE="${3:-false}"

echo "========================================"
echo "  Build Flutter iOS App"
echo "========================================"
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "ERROR: iOS builds require macOS with Xcode installed"
    exit 1
fi

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
FRONTEND_PATH="$PROJECT_ROOT/frontend"

cd "$FRONTEND_PATH"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "ERROR: Flutter not found. Please install Flutter SDK."
    exit 1
fi

echo "Flutter: $(flutter --version | head -1)"
echo ""

# Check iOS toolchain
echo "Checking iOS toolchain..."
if ! flutter doctor | grep -q "iOS toolchain"; then
    echo "WARNING: iOS toolchain may not be configured"
    echo "Run 'flutter doctor' to check setup"
fi

# Install dependencies
echo "Installing dependencies..."
flutter pub get > /dev/null

# Build iOS app
echo "Building iOS app..."
echo "  API URL: $API_URL"
if [ -n "$BUILD_NUMBER" ]; then
    echo "  Build Number: $BUILD_NUMBER"
fi
echo ""

# Build command
BUILD_CMD="flutter build ios --release --dart-define=API_BASE_URL=$API_URL"
if [ -n "$BUILD_NUMBER" ]; then
    BUILD_CMD="$BUILD_CMD --build-number=$BUILD_NUMBER"
fi

if ! eval "$BUILD_CMD"; then
    echo "ERROR: iOS build failed!"
    exit 1
fi

echo "✓ Build successful!"
echo ""

# Check if build output exists
BUILD_PATH="$FRONTEND_PATH/build/ios/iphoneos"
if [ ! -d "$BUILD_PATH" ]; then
    echo "WARNING: Build output not found at: $BUILD_PATH"
fi

echo "Next steps:"
echo "  1. Open Xcode: open ios/Runner.xcworkspace"
echo "  2. Select 'Any iOS Device' (not simulator)"
echo "  3. Product > Archive"
echo "  4. Distribute App > App Store Connect"
echo ""

if [ "$OPEN_XCODE" = "true" ]; then
    echo "Opening Xcode..."
    open ios/Runner.xcworkspace
fi
