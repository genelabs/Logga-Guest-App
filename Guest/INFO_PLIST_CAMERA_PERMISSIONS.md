# Camera & Photo Library Permissions

## Add These to Your Info.plist

You need to add camera and photo library usage descriptions to your Info.plist file.

### Method 1: Using Xcode Interface

1. Open your project in Xcode
2. Select your target
3. Go to the "Info" tab
4. Click the "+" button to add new keys
5. Add these keys:

**Key 1:**
- Key: `Privacy - Camera Usage Description`
- Type: String
- Value: `We need camera access to take visitor photos for security and identification purposes.`

**Key 2:**
- Key: `Privacy - Photo Library Usage Description`
- Type: String  
- Value: `We need photo library access to select visitor photos for security and identification purposes.`

### Method 2: Direct XML (If editing Info.plist as source code)

Add these lines inside the `<dict>` tag in your Info.plist:

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to take visitor photos for security and identification purposes.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to select visitor photos for security and identification purposes.</string>
```

### Complete Info.plist Example:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    
    <!-- ADD THESE TWO ENTRIES -->
    <key>NSCameraUsageDescription</key>
    <string>We need camera access to take visitor photos for security and identification purposes.</string>
    
    <key>NSPhotoLibraryUsageDescription</key>
    <string>We need photo library access to select visitor photos for security and identification purposes.</string>
    
    <!-- Your other keys continue below... -->
</dict>
</plist>
```

## What Happens Without These?

If you don't add these permissions:
- App will CRASH when trying to access camera
- iOS requires explanation for privacy-sensitive features
- Users will see a permission dialog with your description text

## Testing Permissions:

After adding these keys:
1. Delete the app from your device/simulator
2. Rebuild and reinstall
3. First time accessing camera, user will see permission dialog
4. They can choose "Allow" or "Don't Allow"

## Simulator Note:

The iOS Simulator doesn't have a camera, so:
- Camera button won't work in simulator
- Photo library access will work
- Test camera features on a real device
