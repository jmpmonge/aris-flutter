#!/usr/bin/env bash
set -euo pipefail

# Compila Flutter web en Netlify (Linux). En local: flutter build web --release
if command -v flutter >/dev/null 2>&1; then
  flutter pub get
  flutter build web --release
  exit 0
fi

FLUTTER_HOME="${HOME}/flutter"
if [[ ! -d "${FLUTTER_HOME}/bin" ]]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "${FLUTTER_HOME}"
fi
export PATH="${FLUTTER_HOME}/bin:${PATH}"
flutter config --enable-web
flutter pub get
flutter build web --release
