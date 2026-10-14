#!/bin/bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="AleBar.app"
APP_DIR="$DIR/$APP_NAME"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "Creating app bundle at $APP_DIR..."
rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy binary
cp "$DIR/.build/out/Products/Debug/AleBar" "$MACOS_DIR/AleBar"
chmod +x "$MACOS_DIR/AleBar"

# Create Info.plist
cat <<EOF > "$CONTENTS_DIR/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>AleBar</string>
    <key>CFBundleIdentifier</key>
    <string>com.themanoftalent.alebar</string>
    <key>CFBundleName</key>
    <string>AleBar</string>
    <key>CFBundleDisplayName</key>
    <string>AleBar</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
</dict>
</plist>
EOF

echo "Generating AppIcon.icns for AleBar..."
ICONSET_DIR="/tmp/AleBarIcon.iconset"
rm -rf "$ICONSET_DIR"
mkdir -p "$ICONSET_DIR"

# Generate 1024x1024 master icon using Swift and AppKit
cat << 'SWIFTEOF' > /tmp/generate_alebar_icon.swift
import AppKit

let size = NSSize(width: 1024, height: 1024)
let image = NSImage(size: size)
image.lockFocus()

// Squircle background
let rect = NSRect(x: 100, y: 100, width: 824, height: 824)
let path = NSBezierPath(roundedRect: rect, xRadius: 180, yRadius: 180)

// Deep Amber / Obsidian Gradient
let gradient = NSGradient(
    starting: NSColor(red: 0.12, green: 0.08, blue: 0.18, alpha: 1.0),
    ending: NSColor(red: 0.22, green: 0.15, blue: 0.32, alpha: 1.0)
)
gradient?.draw(in: path, angle: -45)

// Outer golden accent border
NSColor(red: 0.95, green: 0.75, blue: 0.25, alpha: 0.35).setStroke()
path.lineWidth = 14
path.stroke()

// Warm golden glowing circle backdrop
let glowPath = NSBezierPath(ovalIn: NSRect(x: 292, y: 292, width: 440, height: 440))
NSColor(red: 0.98, green: 0.65, blue: 0.15, alpha: 0.22).setFill()
glowPath.fill()

// Ale Mug Body
let mugRect = NSRect(x: 340, y: 280, width: 280, height: 400)
let mugPath = NSBezierPath(roundedRect: mugRect, xRadius: 40, yRadius: 40)
NSColor(red: 0.95, green: 0.65, blue: 0.12, alpha: 0.9).setFill()
mugPath.fill()

NSColor(white: 1.0, alpha: 0.85).setStroke()
mugPath.lineWidth = 20
mugPath.stroke()

// Ale Mug Handle
let handle = NSBezierPath()
handle.move(to: NSPoint(x: 620, y: 600))
handle.curve(
    to: NSPoint(x: 620, y: 360),
    controlPoint1: NSPoint(x: 770, y: 600),
    controlPoint2: NSPoint(x: 770, y: 360)
)
handle.lineWidth = 26
handle.lineCapStyle = .round
NSColor(white: 1.0, alpha: 0.85).setStroke()
handle.stroke()

// Ale Glass Vertical Ribs / Highlights
for i in 0..<3 {
    let ribX = 400.0 + CGFloat(i) * 80.0
    let rib = NSBezierPath()
    rib.move(to: NSPoint(x: ribX, y: 320))
    rib.line(to: NSPoint(x: ribX, y: 620))
    rib.lineWidth = 8
    rib.lineCapStyle = .round
    NSColor(white: 1.0, alpha: 0.25).setStroke()
    rib.stroke()
}

// Rich Creamy Foam on top
let foam1 = NSBezierPath(ovalIn: NSRect(x: 320, y: 640, width: 110, height: 95))
let foam2 = NSBezierPath(ovalIn: NSRect(x: 400, y: 660, width: 120, height: 105))
let foam3 = NSBezierPath(ovalIn: NSRect(x: 490, y: 650, width: 110, height: 95))
let foam4 = NSBezierPath(ovalIn: NSRect(x: 550, y: 640, width: 95, height: 85))

NSColor(white: 0.98, alpha: 0.95).setFill()
foam1.fill()
foam2.fill()
foam3.fill()
foam4.fill()

// Menu Bar Island Pill directly above the Ale mug
let pillRect = NSRect(x: 382, y: 790, width: 260, height: 46)
let pillPath = NSBezierPath(roundedRect: pillRect, xRadius: 23, yRadius: 23)
NSColor(red: 0.98, green: 0.72, blue: 0.20, alpha: 0.9).setFill()
pillPath.fill()

// Three dots inside menu bar pill
for i in -1...1 {
    let dotX = 512.0 + CGFloat(i) * 45.0
    let dot = NSBezierPath(ovalIn: NSRect(x: dotX - 10, y: 803, width: 20, height: 20))
    NSColor(red: 0.15, green: 0.10, blue: 0.20, alpha: 0.9).setFill()
    dot.fill()
}

image.unlockFocus()

if let tiff = image.tiffRepresentation,
   let rep = NSBitmapImageRep(data: tiff),
   let png = rep.representation(using: .png, properties: [:]) {
    try? png.write(to: URL(fileURLWithPath: "/tmp/alebar_icon_1024.png"))
}
SWIFTEOF

swift /tmp/generate_alebar_icon.swift

# Generate standard iconset sizes
sips -z 16 16     /tmp/alebar_icon_1024.png --out "$ICONSET_DIR/icon_16x16.png" > /dev/null
sips -z 32 32     /tmp/alebar_icon_1024.png --out "$ICONSET_DIR/icon_16x16@2x.png" > /dev/null
sips -z 32 32     /tmp/alebar_icon_1024.png --out "$ICONSET_DIR/icon_32x32.png" > /dev/null
sips -z 64 64     /tmp/alebar_icon_1024.png --out "$ICONSET_DIR/icon_32x32@2x.png" > /dev/null
sips -z 128 128   /tmp/alebar_icon_1024.png --out "$ICONSET_DIR/icon_128x128.png" > /dev/null
sips -z 256 256   /tmp/alebar_icon_1024.png --out "$ICONSET_DIR/icon_128x128@2x.png" > /dev/null
sips -z 256 256   /tmp/alebar_icon_1024.png --out "$ICONSET_DIR/icon_256x256.png" > /dev/null
sips -z 512 512   /tmp/alebar_icon_1024.png --out "$ICONSET_DIR/icon_256x256@2x.png" > /dev/null
sips -z 512 512   /tmp/alebar_icon_1024.png --out "$ICONSET_DIR/icon_512x512.png" > /dev/null
cp /tmp/alebar_icon_1024.png "$ICONSET_DIR/icon_512x512@2x.png"

iconutil -c icns "$ICONSET_DIR" -o "$RESOURCES_DIR/AppIcon.icns"
rm -rf "$ICONSET_DIR" /tmp/generate_alebar_icon.swift /tmp/alebar_icon_1024.png

echo "Application bundle created successfully: $APP_DIR"
