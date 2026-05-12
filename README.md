# Flutter Chrome Extension

[![Extension checks](https://github.com/gabrimatic/flutter_chrome_extension/actions/workflows/extension.yml/badge.svg)](https://github.com/gabrimatic/flutter_chrome_extension/actions/workflows/extension.yml)
[![Flutter](https://img.shields.io/badge/Flutter-Web-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Chrome](https://img.shields.io/badge/Chrome-Manifest%20V3-4285F4?logo=googlechrome&logoColor=white)](https://developer.chrome.com/docs/extensions)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)

Flutter Chrome Extension is a Manifest V3 popup built with Flutter Web. You use it as a compact starter for browser-extension UI work: a real Flutter popup, static Chrome package, no background worker, no host permissions, and no remote assets.

The extension ships as the contents of `build/web`. Chrome reads `manifest.json`, opens `index.html` as the toolbar popup, and runs the compiled Flutter app from local package files.

## At a Glance

| Surface | What it does |
|---------|--------------|
| Popup UI | Shows extension status, build guidance, and a release checklist in a compact Flutter interface. |
| Manifest | Uses Chrome Manifest V3 with `action.default_popup`, icon declarations, and an extension-page CSP. |
| Permissions | Requests none by default. Add permissions only when the feature needs them. |
| Build | Produces a static `build/web` folder you can load as an unpacked extension. |
| Verification | Runs format, analyze, widget tests, web build, and artifact validation in CI. |

## Quick Start

Requirements: **Flutter stable**, **Dart 3**, and **Google Chrome**.

```bash
git clone https://github.com/gabrimatic/flutter_chrome_extension.git
cd flutter_chrome_extension
flutter pub get
./tool/build_extension.sh
```

Load the extension:

1. Open `chrome://extensions`.
2. Turn on **Developer mode**.
3. Click **Load unpacked**.
4. Select `build/web`.
5. Open the extension from the Chrome toolbar.

## Development

Run the app as a normal Flutter web target while working on UI:

```bash
flutter run -d chrome
```

Build the extension package before testing it inside Chrome:

```bash
./tool/build_extension.sh
```

Verify the package shape:

```bash
dart run tool/verify_extension_build.dart
```

The build command uses Flutter's CSP mode, keeps Flutter web resources local to the package, and disables source maps for a cleaner extension artifact.

## Runtime Model

| Part | Runtime behavior |
|------|------------------|
| UI | Flutter Web compiled into `main.dart.js`. |
| Popup host | Chrome extension action popup at `index.html`. |
| Assets | Bundled inside `build/web`; no CDN dependency in the extension package. |
| Permissions | Empty by default. |
| Background work | None by default. |
| Network | None required by the shipped popup. |

## Project Layout

| Path | Purpose |
|------|---------|
| `lib/main.dart` | Flutter popup UI and release checklist. |
| `web/manifest.json` | Chrome Manifest V3 metadata, action popup, icons, and CSP. |
| `web/index.html` | Fixed popup shell that loads the compiled Flutter script. |
| `tool/build_extension.sh` | Repeatable extension build command. |
| `tool/verify_extension_build.dart` | Artifact checks for manifest, icons, CSP, local assets, and source maps. |
| `.github/workflows/extension.yml` | CI for formatting, analysis, tests, build, and artifact verification. |

## Checks

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
./tool/build_extension.sh
dart run tool/verify_extension_build.dart
```
