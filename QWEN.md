## Qwen Added Memories
- ## Distribution & Build Process

### Build Commands:
- `make whisper` - Clone and build whisper.cpp XCFramework dependency
- `make release` - Build Notext.app + create Notext.zip + Notext.dmg in ./dist/
- `make local` - Build for local use (no Apple Developer cert needed)

### DMG Creation:
- `./create_dmg.sh` - Creates Notext_Install.dmg (drag-and-drop installer)
  - Extracts app from Notext.zip if .app not found
  - Creates staging with Notext.app + /Applications symlink
  - Uses AppleScript to configure Finder window layout
  - Compresses to UDZO format
  - Output: ./dist/Notext_Install.dmg (~11MB)

### Publishing:
- `./publish_update.sh` - Signs update with Sparkle and updates appcast.xml
- GitHub Release: `gh release create vX.Y.Z --title "Notext vX.Y.Z" --generate-notes`
- Upload: `gh release upload vX.Y.Z ./dist/Notext.zip ./dist/Notext.dmg ./dist/Notext_Install.dmg`

### Distribution Files:
- Notext.zip - For GitHub Releases + Sparkle updates
- Notext.dmg - Standard DMG
- Notext_Install.dmg - Drag & Drop installer (Notext.app → Applications)

### Dependencies:
- whisper.cpp lives in ~/Notext-Dependencies/ (outside repo, gitignored)
- Built via ./build-xcframework.sh from whisper.cpp repo
- ## DMG Install Script (create_dmg.sh)
- Creates Notext_Install.dmg with:
  - Custom PNG background (dark gradient + grid + "Notext" text + security warning in purple box)
  - Notext.app (left side at {160,140})
  - Applications symlink (right side at {500,140})
  - README.txt with 3-step install guide including "System Settings > Privacy & Security > Open Anyway"
- Python generates PNG pixel-by-pixel (no external deps needed)
- Window size: 660x480, icon view, 128px icons
- Detaches ALL volumes matching "Notext*" before compressing
