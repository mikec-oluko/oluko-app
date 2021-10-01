[![style: lint](https://img.shields.io/badge/style-lint-4BC0F5.svg)](https://pub.dev/packages/lint)

# oluko_app

A Flutter project for Android and iOS app Oluko

## Getting Started

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Setup Development Environment

1. Install Git
    1. https://git-scm.com/  
3. Install Flutter
    1. https://flutter.dev/docs/get-started/install (This guide installs everything needed to run app)
    2. After running flutter doctor you'll need to install to android studio this: https://pineapplelabcom.sharepoint.com/sites/41891282-MichaelChaney/Shared%20Documents/MichaelChaney/installAndroid.png

4. Install VS Code
    1. https://code.visualstudio.com/download
    2. add Flutter plugin 
    3. add Dart plugin
5. Ready! 

## Add languages

main.dart file you need to add the extra language
assets/lang u need to create the resource file.
use: OlukoLocalizations.get(context, translationKey)

## Date Formatting
https://pub.dev/documentation/intl/latest/intl/DateFormat-class.html

## Create new appbundle build (Android)

```unix
flutter build appbundle
```

## iOS Testflight

*only when fastlane is setup correctly

```unix
cd ios
bundle exec fastlane beta
```

(this builds app and deploys to app store testflight)

## Build Scritps

build_scripts.sh contains scripts to build for different environments

```unix
    sh build_scripts.sh dev
```

this will build development environment

```unix
    sh build_scripts.sh qa
```

this will build qa environment

```unix
    sh build_scripts.sh prod
```

this will build production environment
