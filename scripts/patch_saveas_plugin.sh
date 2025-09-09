#!/usr/bin/env bash
set -euo pipefail

# Working directory should be frontend
ANDROID_DIR="android/app/src/main/java"
# Find MainActivity.java path dynamically (under application id path)
MAIN_ACTIVITY_PATH=$(grep -Rsl "class MainActivity" android/app/src/main/java || true)
if [ -z "$MAIN_ACTIVITY_PATH" ]; then
  echo "MainActivity.java not found" >&2
  exit 1
fi

# Determine package folder of MainActivity
MAIN_DIR=$(dirname "$MAIN_ACTIVITY_PATH")
PLUGIN_DIR="$MAIN_DIR/plugins"
mkdir -p "$PLUGIN_DIR"

# Copy plugin java
cp -f ../scripts/android/SaveAsPlugin.java "$PLUGIN_DIR/SaveAsPlugin.java"

# Ensure import and registration
if ! grep -q "SaveAsPlugin" "$MAIN_ACTIVITY_PATH"; then
  # Add import if not exists
  if ! grep -q "de.ams.Qualifizierungstool.plugins.SaveAsPlugin" "$MAIN_ACTIVITY_PATH"; then
    sed -i '1i import de.ams.Qualifizierungstool.plugins.SaveAsPlugin;' "$MAIN_ACTIVITY_PATH"
  fi
  # Insert registerPlugin inside onCreate block safely
  if grep -q "class MainActivity" "$MAIN_ACTIVITY_PATH"; then
    sed -i 's/super.onCreate(.*);/super.onCreate(savedInstanceState);\n        registerPlugin(SaveAsPlugin.class);/g' "$MAIN_ACTIVITY_PATH" || true
  fi
fi

echo "SaveAs plugin injected and MainActivity patched: $MAIN_ACTIVITY_PATH"