# oluko_app

A Flutter project for Android and iOS app Oluko

[![style: lint](https://img.shields.io/badge/style-lint-4BC0F5.svg)](https://pub.dev/packages/lint)

## Getting Started

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Setup Development Environment

1. Install Git
    1. <https://git-scm.com/>  
2. Install Flutter
    1. <https://flutter.dev/docs/get-started/install> (This guide installs everything needed to run app)
    2. After running flutter doctor you'll need to install to android studio this: <https://pineapplelabcom.sharepoint.com/sites/41891282-MichaelChaney/Shared%20Documents/MichaelChaney/installAndroid.png>

3. Install VS Code
    1. <https://code.visualstudio.com/download>
    2. add Flutter plugin
    3. add Dart plugin
4. Ready!

## Add languages

main.dart file you need to add the extra language
assets/lang u need to create the resource file.
use: OlukoLocalizations.get(context, translationKey)

## Date Formatting

<https://pub.dev/documentation/intl/latest/intl/DateFormat-class.html>

## Create new appbundle build (Android)

```unix
flutter build appbundle
```

## iOS Testflight

### Install Ruby

<https://www.ruby-lang.org/en/documentation/installation/>

### Setup Fastlane

<https://docs.fastlane.tools/#:~:text=Getting%20Started-,Installing,-fastlane>

(request access to repo with certificates to project owner / tech lead / architect)

### Deploy to App Store (Testflight)

*only when fastlane is setup correctly

```unix
cd ios
bundle exec fastlane beta
```

(this builds app and deploys to app store testflight)

## Complete Build Scripts

scripts.sh contains scripts to build for different environments

```unix
    sh scripts.sh dev
```

this will build development environment

```unix
    sh scripts.sh qa
```

this will build qa environment

```unix
    sh scripts.sh prod
```

this will build production environment

to deploy:

```unix
    sh scripts.sh deploy dev
```

this will deploy to both android and ios for dev env

```unix
    sh scripts.sh dev ios
```

this will deploy to both ios for dev env

```unix
    sh scripts.sh dev android
```

this will deploy to both android for dev env


## Setup Google Sign In for Debug

To get the debug certificate fingerprint:

Mac/Linux
```unix
    keytool -list -v \
    -alias androiddebugkey -keystore ~/.android/debug.keystore
```

Windows
```unix
    keytool -list -v \
    -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore
```

The keytool utility prompts you to enter a password for the keystore. The default password for the debug keystore is android. The keytool then prints the fingerprint to the terminal.

Add the SHA-1 to Firease: ![Screenshot for Firebase section to add SHA-1](./README/Screen%20Shot%202022-02-18%20at%2011.26.25%20AM.png?raw=true)
