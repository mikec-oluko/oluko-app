# oluko_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

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
