#!/bin/bash

###################################################
# Path to flutter
FLUTTER="/home/topg/.local/opt/flutter-3.16.2-2/bin/flutter"

# Build a version of your app.
# debug || profile || release
VERSION='release'

# The target platform for which the app is compiled.
# arm || arm64 || x64
PLATFORM='arm'

# Launch the installed application.
# true || false
RUN='false'
###################################################

# Open example folder if exist
if [ -d "example" ]; then
  # Get dependency plugin
  $FLUTTER pub get
  # Open example project
  cd example || exit
fi

# Start emulator
{
  if [ "$PLATFORM" = "x64" ]; then
    aurora-cli emulator start
  fi
} &> /dev/null

# Clear build
$FLUTTER clean

# Get dependency
$FLUTTER pub get

## Run build dart
$FLUTTER pub run build_runner build --delete-conflicting-outputs

{
  # Change output
  exec 5>&1

  # Build aurora application
  output=$($FLUTTER build aurora --target-platform aurora-$PLATFORM --$VERSION | tee /dev/fd/5)

  # Get path to rmp
  listRPMs=$(echo "$output" | grep "│" | tr -d "
" | sed 's/│//g' | sed 's/ //g' | sed 's/\.\//;/g')

  # Get package name
  for item in $(echo "$listRPMs" | tr ";" "
")
  do
    if [ -n "$item" ] && [[ $item != *"-debug"* ]]; then
      package=$(basename "$item" | cut -d '-' -f1)
      break
    fi
  done

  # Error if package path empty
  if [[ -z $package ]]; then
    echo "Error find package name"
    exit 1;
  fi

  # Run sign and install
  for item in $(echo "$listRPMs" | tr ";" "
")
  do
    if [ -n "$item" ]; then
      # Sign
      aurora-cli psdk sign -p "./$item"
      # Install
      if [[ "$PLATFORM" = "x64" ]]; then
        aurora-cli emulator install -p "./$item"
      else
        aurora-cli device install -p "./$item"
      fi
    fi
  done

  # Run package
  if [[ $RUN == "true" ]]; then
    for item in $(echo "$listRPMs" | tr ";" "
")
    do
      if [ -n "$item" ] && [[ $item != *"-debug"* ]]; then
        if [[ "$PLATFORM" = "x64" ]]; then
          aurora-cli emulator run -p "$package" -v
        else
          aurora-cli device run -p "$package" -v
        fi
        break
      fi
    done
  fi

} || {
  echo 'Error build'
  exit 1;
}

