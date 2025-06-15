#!/bin/bash

# Script to create a new provisioning profile for HalalLens

echo "📱 Creating Provisioning Profile for HalalLens"
echo "============================================"

# Configuration
APP_BUNDLE_ID="com.akbarshalabs.halallens"
TEAM_ID="5A9TGST9H4"
DEVICE_ID="6B6E3988-3C10-4F6D-81DA-E216E00C5B22"
DEVELOPER_CERT="Apple Development: iamakbarsha1@gmail.com (VUUF8TL6V5)"

echo "ℹ️  Bundle ID: $APP_BUNDLE_ID"
echo "ℹ️  Team ID: $TEAM_ID"
echo "ℹ️  Device ID: $DEVICE_ID"
echo ""

# Create temporary Xcode project to generate provisioning profile
TEMP_PROJECT_DIR="/tmp/HalalLensTemp"
echo "🔨 Creating temporary Xcode project..."

# Remove existing temp directory
rm -rf "$TEMP_PROJECT_DIR"

# Create new iOS project
xcodebuild -project "$TEMP_PROJECT_DIR/HalalLensTemp.xcodeproj" \
  -scheme HalalLensTemp \
  -destination "id=$DEVICE_ID" \
  -allowProvisioningUpdates \
  -allowProvisioningDeviceRegistration \
  build-for-testing 2>/dev/null || {

  echo "📱 Manual Xcode setup required. Please follow these steps:"
  echo ""
  echo "1. Open Xcode"
  echo "2. Create a new iOS project:"
  echo "   - Choose 'App' template"
  echo "   - Product Name: HalalLensTemp"
  echo "   - Bundle Identifier: $APP_BUNDLE_ID"
  echo "   - Team: Select your development team"
  echo "3. Connect your iPhone"
  echo "4. Select your iPhone as the destination"
  echo "5. Click 'Build and Run' (▶️)"
  echo "6. Allow Xcode to register your device and create provisioning profile"
  echo "7. After successful build, close Xcode and run this script again"
  echo ""
  echo "This will generate the necessary provisioning profile."
  
  read -p "Press Enter after completing the Xcode setup..."
}

# Look for the newly created provisioning profile
echo "🔍 Looking for new provisioning profiles..."
NEW_PROFILE=$(find ~/Library/Developer/Xcode/DerivedData -name "*.mobileprovision" -newer "/tmp/last_profile_check" 2>/dev/null | head -1)

if [ -z "$NEW_PROFILE" ]; then
    echo "⚠️  No new provisioning profile found. Let's create one manually..."
    
    # Create a basic entitlements file with wildcard app ID
    cat > /tmp/entitlements_wildcard.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>application-identifier</key>
    <string>$TEAM_ID.*</string>
    <key>com.apple.developer.team-identifier</key>
    <string>$TEAM_ID</string>
    <key>get-task-allow</key>
    <true/>
    <key>keychain-access-groups</key>
    <array>
        <string>$TEAM_ID.*</string>
    </array>
</dict>
</plist>
EOF

    echo "✅ Created wildcard entitlements"
    echo "🔑 Signing app with wildcard provisioning..."
    
    # Sign with wildcard entitlements (development)
    codesign --force --sign "$DEVELOPER_CERT" --entitlements /tmp/entitlements_wildcard.plist "/Users/akbarsha/Desktop/code/halal-lens/target/dx/mobile/debug/ios/Mobile.app"
    
    if [ $? -eq 0 ]; then
        echo "✅ App signed successfully!"
        echo "📱 Ready to install on device"
    else
        echo "❌ Signing failed"
        exit 1
    fi
else
    echo "✅ Found new provisioning profile: $NEW_PROFILE"
    
    # Copy the new profile
    cp "$NEW_PROFILE" "/Users/akbarsha/Desktop/code/halal-lens/target/dx/mobile/debug/ios/Mobile.app/embedded.mobileprovision"
    
    # Extract entitlements from the new profile
    security cms -D -i "$NEW_PROFILE" | plutil -extract Entitlements xml1 - -o /tmp/extracted_entitlements.plist
    
    echo "🔑 Signing app with new provisioning profile..."
    codesign --force --sign "$DEVELOPER_CERT" --entitlements /tmp/extracted_entitlements.plist "/Users/akbarsha/Desktop/code/halal-lens/target/dx/mobile/debug/ios/Mobile.app"
    
    if [ $? -eq 0 ]; then
        echo "✅ App signed successfully!"
        echo "📱 Ready to install on device"
    else
        echo "❌ Signing failed"
        exit 1
    fi
fi

echo ""
echo "🚀 Now try installing the app:"
echo "   xcrun devicectl device install app --device $DEVICE_ID /Users/akbarsha/Desktop/code/halal-lens/target/dx/mobile/debug/ios/Mobile.app"
echo ""

