#!/bin/bash
# publish_update.sh - Sign and publish a new Notext update
# Usage: ./publish_update.sh [/path/to/Notext.app]
# If no path provided, uses the latest build from ./dist/ or ~/Downloads/

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APPCAST="$SCRIPT_DIR/appcast.xml"
SPARKLE_BIN="$SCRIPT_DIR/.local-build/SourcePackages/artifacts/sparkle/Sparkle/bin"
DIST_DIR="$SCRIPT_DIR/dist"

# Find the app if not provided
if [ -z "$1" ]; then
    echo "🔍 Looking for Notext.app..."
    
    # Check dist folder first
    if [ -d "$DIST_DIR/Notext.app" ]; then
        APP_PATH="$DIST_DIR/Notext.app"
        echo "   Found in ./dist/"
    # Check Downloads
    elif [ -d "$HOME/Downloads/Notext.app" ]; then
        APP_PATH="$HOME/Downloads/Notext.app"
        echo "   Found in ~/Downloads/"
    else
        echo "❌ No Notext.app found. Run 'make release' first."
        exit 1
    fi
else
    APP_PATH="$1"
fi

if [ ! -d "$APP_PATH" ]; then
    echo "❌ Error: App not found at $APP_PATH"
    exit 1
fi

APP_NAME="Notext"
ZIP_NAME="${APP_NAME}.zip"
ZIP_PATH="/tmp/$ZIP_NAME"

# Get version info
APP_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$APP_PATH/Contents/Info.plist" 2>/dev/null)
APP_BUILD=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$APP_PATH/Contents/Info.plist" 2>/dev/null)

if [ -z "$APP_VERSION" ] || [ -z "$APP_BUILD" ]; then
    echo "❌ Error: Could not read version info from app"
    exit 1
fi

echo ""
echo "📦 Notext v$APP_VERSION (build $APP_BUILD)"
echo "   App: $APP_PATH"
echo ""

# Create zip
echo "🗜️ Creating $ZIP_NAME..."
rm -f "$ZIP_PATH"
ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"
ZIP_SIZE=$(stat -f%z "$ZIP_PATH")

# Sign the update
echo "✍️ Signing update..."
if [ ! -f "$SPARKLE_BIN/sign_update" ]; then
    echo "❌ Sparkle sign_update not found. Building Sparkle first..."
    echo "   Run: cd $SCRIPT_DIR && xcodebuild -project Notext.xcodeproj -scheme Sparkle build"
    exit 1
fi

SIGN_OUTPUT=$("$SPARKLE_BIN/sign_update" "$ZIP_PATH" 2>&1)
ED_SIGNATURE=$(echo "$SIGN_OUTPUT" | sed -n 's/.*sparkle:edSignature="\([^"]*\)".*/\1/p')

if [ -z "$ED_SIGNATURE" ]; then
    echo "❌ Failed to sign update. Make sure Sparkle tools are built."
    echo "   Output: $SIGN_OUTPUT"
    exit 1
fi

echo "✅ Signature: $ED_SIGNATURE"
echo ""

# Create appcast entry
PUB_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

cat > "$APPCAST" << EOF
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.sparkle-project.org/xml/1.0">
  <channel>
    <title>Notext Updates</title>
    <link>https://raw.githubusercontent.com/EVELETTE/Notext/main/appcast.xml</link>
    <description>Most recent changes with links to updates.</description>
    <language>en</language>
    <item>
      <title>Version $APP_VERSION</title>
      <pubDate>$PUB_DATE</pubDate>
      <sparkle:version>$APP_BUILD</sparkle:version>
      <sparkle:shortVersionString>$APP_VERSION</sparkle:shortVersionString>
      <enclosure
          url="https://github.com/EVELETTE/Notext/releases/download/v$APP_VERSION/$ZIP_NAME"
          sparkle:edSignature="$ED_SIGNATURE"
          length="$ZIP_SIZE"
          type="application/octet-stream"
      />
    </item>
  </channel>
</rss>
EOF

echo "✅ appcast.xml updated"
echo ""
echo "📋 Next steps:"
echo "1. Create GitHub release:"
echo "   gh release create v$APP_VERSION --title \"Notext v$APP_VERSION\" --generate-notes"
echo ""
echo "2. Upload the ZIP:"
echo "   gh release upload v$APP_VERSION $ZIP_PATH"
echo ""
echo "3. Commit and push appcast.xml:"
echo "   git add appcast.xml && git commit -m \"Update appcast for v$APP_VERSION\" && git push"
echo ""
echo "🎉 Once uploaded, users will receive the update automatically via Sparkle!"
