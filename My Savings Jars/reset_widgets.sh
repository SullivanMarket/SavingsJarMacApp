#!/bin/bash

echo "🔧 Cleaning up for widget refresh..."

# Step 1: Quit Xcode if running
echo "🚫 Closing Xcode..."
osascript -e 'quit app "Xcode"'

# Step 2: Clean Derived Data
echo "🧹 Removing Derived Data..."
rm -rf ~/Library/Developer/Xcode/DerivedData

# Step 3: Reset widget cache
echo "🌀 Killing Dock to refresh widget registration..."
killall Dock

# Step 4: Reopen Xcode
echo "🚀 Reopening Xcode..."
open -a Xcode

echo "✅ Done! Now open your project, clean build (⇧⌘K), build and run the main app, and check widgets."
