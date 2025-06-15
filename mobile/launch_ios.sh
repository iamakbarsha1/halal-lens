#!/bin/bash

# HalalLens iOS Launch Script

APP_PATH="/Users/akbarsha/Desktop/code/halal-lens/target/dx/mobile/debug/ios/Mobile.app"
BUNDLE_ID="com.example.Mobile"

# Device UUIDs
iPHONE_16="D4C98DD6-C9B3-4318-9AB9-6228C9B67216"
iPHONE_16_PRO="BB72BEC5-BB4C-4FFA-B9C8-721AD9FF6EF4"
iPHONE_16_PRO_MAX="3A13205B-365B-4068-8B4F-8467AD4BD763"
iPHONE_16_PLUS="C4953619-8F3F-4C65-86B0-D4F916406C8B"
iPHONE_SE="18DAC440-933A-4789-A8B6-21809990C6FA"

# Function to launch app on specific device
launch_on_device() {
    local device_id=$1
    local device_name=$2
    
    echo "🚀 Launching HalalLens on $device_name..."
    
    # Boot the device
    echo "📱 Booting $device_name..."
    xcrun simctl boot $device_id 2>/dev/null || echo "Device already booted"
    
    # Install the app
    echo "📦 Installing app..."
    xcrun simctl install $device_id $APP_PATH
    
    # Launch the app
    echo "🎯 Launching app..."
    xcrun simctl launch $device_id $BUNDLE_ID
    
    echo "✅ App launched successfully on $device_name!"
}

# Parse command line arguments
case $1 in
    "iphone16")
        launch_on_device $iPHONE_16 "iPhone 16"
        ;;
    "iphone16pro")
        launch_on_device $iPHONE_16_PRO "iPhone 16 Pro"
        ;;
    "iphone16promax")
        launch_on_device $iPHONE_16_PRO_MAX "iPhone 16 Pro Max"
        ;;
    "iphone16plus")
        launch_on_device $iPHONE_16_PLUS "iPhone 16 Plus"
        ;;
    "iphonese")
        launch_on_device $iPHONE_SE "iPhone SE"
        ;;
    *)
        echo "📱 HalalLens iOS Launcher"
        echo "Usage: $0 [device]"
        echo ""
        echo "Available devices:"
        echo "  iphone16        - iPhone 16 (iOS 18.2)"
        echo "  iphone16pro     - iPhone 16 Pro (iOS 18.2)"
        echo "  iphone16promax  - iPhone 16 Pro Max (iOS 18.2)"
        echo "  iphone16plus    - iPhone 16 Plus (iOS 18.2)"
        echo "  iphonese        - iPhone SE 3rd Gen (iOS 18.2)"
        echo ""
        echo "Example: $0 iphone16pro"
        ;;
esac

