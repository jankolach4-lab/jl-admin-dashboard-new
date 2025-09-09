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

# Ensure import after package line
if ! grep -q "de.ams.Qualifizierungstool.plugins.SaveAsPlugin" "$MAIN_ACTIVITY_PATH"; then
  sed -i '/^package .*;/a import de.ams.Qualifizierungstool.plugins.SaveAsPlugin;' "$MAIN_ACTIVITY_PATH"
fi

# Ensure registerPlugin call in onCreate, or create onCreate if missing
if grep -q "onCreate(.*Bundle" "$MAIN_ACTIVITY_PATH"; then
  if ! grep -q "registerPlugin(SaveAsPlugin.class)" "$MAIN_ACTIVITY_PATH"; then
    sed -i '/super\.onCreate(/a\        registerPlugin(SaveAsPlugin.class);' "$MAIN_ACTIVITY_PATH"
  fi
else
  # Inject onCreate method before final closing brace
  tmpfile=$(mktemp)
  awk 'BEGIN{inserted=0} {
    if(!inserted && $0 ~ /class[[:space:]]+MainActivity[^{]*{/){
      class_found=1
    }
    if(class_found && !inserted && $0 ~ /^}\s*$/){
      print "    @Override";
      print "    protected void onCreate(android.os.Bundle savedInstanceState) {";
      print "        super.onCreate(savedInstanceState);";
      print "        registerPlugin(SaveAsPlugin.class);";
      print "    }";
      inserted=1;
    }
    print $0
  }' "$MAIN_ACTIVITY_PATH" > "$tmpfile"
  mv "$tmpfile" "$MAIN_ACTIVITY_PATH"
fi


echo "SaveAs plugin injected and MainActivity patched: $MAIN_ACTIVITY_PATH"