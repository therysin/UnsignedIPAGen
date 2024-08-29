#!/bin/bash

# Get the current directory
CURRENT_DIR=$(pwd)

XCODEPROJ_FILE=$(find . -maxdepth 1 -name "*.xcodeproj" | head -n 1)
PROJECT_NAME=$(basename "$XCODEPROJ_FILE" .xcodeproj)

# Ask for the IPA file name
read -p "Enter the name for the IPA file (without extension): " IPA_NAME

# Check if IPA_NAME is empty
if [ -z "$IPA_NAME" ]; then
    echo "IPA name cannot be empty. Exiting."
    exit 1
fi

# Append .ipa extension
IPA_FILE="$IPA_NAME.ipa"

# Step 1: Build and archive the project
xcodebuild archive \
    -project "$XCODEPROJ_FILE" \
    -scheme "$PROJECT_NAME" \
    -archivePath "$CURRENT_DIR/unsigned.xcarchive" \
    -configuration Release \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

# Step 2: Create a temporary working directory
WORK_DIR="$CURRENT_DIR/ipa_build"
APP_DIR="$WORK_DIR/Payload"
mkdir -p "$APP_DIR"

# Step 3: Copy the .app from the .xcarchive to Payload folder
cp -R "$CURRENT_DIR/unsigned.xcarchive/Products/Applications/"$PROJECT_NAME".app" "$APP_DIR/"

# Step 4: Change directory to the working directory
cd "$WORK_DIR"

# Step 5: Zip the Payload folder into an IPA file
zip -r "$IPA_FILE" Payload

# Step 6: Move the IPA file to the current directory
mv "$IPA_FILE" "$CURRENT_DIR/"

# Step 7: Clean up the temporary directory
rm -rf "$WORK_DIR"
rm -rf "$CURRENT_DIR/unsigned.xcarchive"

echo "IPA generated at $CURRENT_DIR/$IPA_FILE"
