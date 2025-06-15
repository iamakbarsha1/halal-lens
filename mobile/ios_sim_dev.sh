#!/bin/bash

# iOS Simulator Development Script for HalalLens
# Fixes architecture issues with dx serve

echo "📱 HalalLens iOS Simulator Development"
echo "====================================="

# Configuration
APP_PATH="/Users/akbarsha/Desktop/code/halal-lens/target/dx/mobile/debug/ios/Mobile.app"
BUNDLE_ID="com.akbarshalabs.halallens"
SIMULATOR_ID="BB72BEC5-BB4C-4FFA-B9C8-721AD9FF6EF4"  # iPhone 16 Pro

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Step 1: Build with dx (but ignore the binary it creates)
print_info "Building app with dx..."
if dx build --platform ios; then
    print_success "dx build completed"
else
    echo "❌ dx build failed"
    exit 1
fi

# Step 2: Build correct x86_64 binary
print_info "Building x86_64 binary for simulator..."
if cargo build --target x86_64-apple-ios --features mobile; then
    print_success "x86_64 binary built"
else
    echo "❌ Failed to build x86_64 binary"
    exit 1
fi

# Step 3: Replace the binary in the app bundle
print_info "Replacing binary with correct architecture..."
cp /Users/akbarsha/Desktop/code/halal-lens/target/x86_64-apple-ios/debug/mobile "$APP_PATH/mobile"

# Verify architecture
ARCH=$(file "$APP_PATH/mobile" | grep -o "x86_64")
if [ "$ARCH" = "x86_64" ]; then
    print_success "Binary architecture: x86_64 ✓"
else
    echo "❌ Wrong architecture detected"
    exit 1
fi

# Step 4: Install on simulator
print_info "Installing app on iPhone 16 Pro simulator..."
if xcrun simctl install "$SIMULATOR_ID" "$APP_PATH"; then
    print_success "App installed successfully"
else
    echo "❌ Installation failed"
    exit 1
fi

# Step 5: Launch the app
print_info "Launching HalalLens..."
if xcrun simctl launch "$SIMULATOR_ID" "$BUNDLE_ID"; then
    print_success "🚀 HalalLens is now running on iPhone 16 Pro simulator!"
    echo ""
    print_info "Simulator: iPhone 16 Pro (iOS 18.2)"
    print_info "Bundle ID: $BUNDLE_ID"
    print_info "Architecture: x86_64"
    echo ""
    print_warning "For hot reloading, you may need to rebuild and run this script again"
else
    echo "❌ Failed to launch app"
    exit 1
fi

