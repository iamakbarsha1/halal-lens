#!/bin/bash

# HalalLens iPhone Deployment Script

echo "📱 HalalLens iPhone Deployment"
echo "=============================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_PATH="/Users/akbarsha/Desktop/code/halal-lens/target/dx/mobile/debug/ios/Mobile.app"
BUNDLE_ID="com.example.Mobile"
DEVICE_ID="6B6E3988-3C10-4F6D-81DA-E216E00C5B22"  # Your iPhone 14

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if device is connected
print_status "Checking if iPhone is connected..."
if xcrun devicectl list devices | grep -q "$DEVICE_ID"; then
    print_success "iPhone 14 is connected"
else
    print_error "iPhone 14 not found. Please connect your device."
    exit 1
fi

# Check if app exists
if [ ! -d "$APP_PATH" ]; then
    print_error "App not found at $APP_PATH"
    print_status "Please build the app first: cd mobile && dx build --platform ios --device true"
    exit 1
fi

print_success "App found at $APP_PATH"

# Build the app for device
print_status "Building app for iOS device..."
cd mobile
if dx build --platform ios --device true; then
    print_success "Build completed successfully"
else
    print_error "Build failed"
    exit 1
fi

# Install app on device
print_status "Installing app on iPhone..."
print_warning "Make sure your iPhone is unlocked and you've enabled Developer Mode"
print_warning "You may need to trust the developer certificate in Settings > General > VPN & Device Management"

if xcrun devicectl device install app --device "$DEVICE_ID" "$APP_PATH"; then
    print_success "App installed successfully!"
    
    # Launch the app
    print_status "Launching HalalLens..."
    if xcrun devicectl device process launch --device "$DEVICE_ID" "$BUNDLE_ID"; then
        print_success "App launched successfully! 🚀"
        print_status "HalalLens is now running on your iPhone 14"
    else
        print_warning "App installed but failed to launch automatically"
        print_status "You can manually launch the app from your iPhone home screen"
    fi
else
    print_error "Failed to install app"
    echo ""
    print_warning "Common issues and solutions:"
    echo "  1. Make sure your iPhone is unlocked"
    echo "  2. Enable Developer Mode: Settings > Privacy & Security > Developer Mode"
    echo "  3. Trust this computer when prompted"
    echo "  4. You may need an Apple Developer account for code signing"
    echo ""
    exit 1
fi

