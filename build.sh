#!/bin/sh
set -e; cd "$(dirname "$0")"
A=LetYourMacSleep.app; rm -rf $A; mkdir -p $A/Contents/MacOS
swiftc -O main.swift -o $A/Contents/MacOS/LetYourMacSleep
cat > $A/Contents/Info.plist <<P
<?xml version="1.0" encoding="UTF-8"?><plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>local.letyourmacsleep</string>
<key>CFBundleExecutable</key><string>LetYourMacSleep</string>
<key>CFBundleName</key><string>LetYourMacSleep</string>
<key>LSUIElement</key><true/>
<key>NSMicrophoneUsageDescription</key><string>Detects whether you are speaking before sleeping the Mac.</string>
</dict></plist>
P
codesign --force --sign - $A
echo "built $A  (open it, or: open $A)"
