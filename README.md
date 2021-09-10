[![style: lint](https://img.shields.io/badge/style-lint-4BC0F5.svg)](https://pub.dev/packages/lint)

# oluko_app

A Flutter project for Android and iOS app Oluko

## Getting Started

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Add languages

main.dart file you need to add the extra language
assets/lang u need to create the resource file.
use: OlukoLocalizations.of(context).find('writeText')

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
