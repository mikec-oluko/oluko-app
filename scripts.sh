#----- Functions 

SetupDevEnv () {
    echo "Setting up development environment" && flutter clean && \
    cp environments/dev/icon.png assets/icon && \
    cp ios/Flutter/src/development/GoogleService-Info.plist ios/Flutter && \
    cp -a android/app/src/development/ android/app && \
    cp -a android/fastlane/src/dev/metadata android/fastlane && \
    cp lib/config/src/development/project_settings.dart lib/config && \
    cp lib/config/src/development/s3_settings.dart lib/config && \
    flutter pub get && cd ios && pod install && cd .. && \
    flutter pub run flutter_launcher_icons:main
}

SetupProdEnv () {
    echo "Setting up production environment" && flutter clean && \
    cp environments/prod/icon.png assets/icon && \
    cp ios/Flutter/src/production/GoogleService-Info.plist ios/Flutter && \
    cp -a android/app/src/production/ android/app && \
    cp -a android/fastlane/src/production/metadata android/fastlane && \
    cp lib/config/src/production/project_settings.dart lib/config && \
    cp lib/config/src/production/s3_settings.dart lib/config && \
    flutter pub get && cd ios && pod install && cd .. && \
    flutter pub run flutter_launcher_icons:main 
}

SetupStagingEnv () {
    echo "Setting up staging environment" && flutter clean && \
    cp environments/staging/icon.png assets/icon && \
    cp ios/Flutter/src/staging/GoogleService-Info.plist ios/Flutter && \
    cp -a android/app/src/staging/ android/app && \
    cp -a android/fastlane/src/staging/metadata android/fastlane && \
    cp lib/config/src/staging/project_settings.dart lib/config && \
    cp lib/config/src/staging/s3_settings.dart lib/config && \
    flutter pub get && cd ios && pod install && cd .. && \
    flutter pub run flutter_launcher_icons:main 
}

SetupQAEnv () {
    echo "Setting up qa environment" && flutter clean && \
    cp environments/qa/icon.png assets/icon && \
    cp ios/Flutter/src/qa/GoogleService-Info.plist ios/Flutter && \
    cp -a android/app/src/qa/ android/app  && \
    cp -a android/fastlane/src/qa/metadata android/fastlane && \
    cp lib/config/src/qa/project_settings.dart lib/config && \
    cp lib/config/src/qa/s3_settings.dart lib/config && \
    flutter pub get && cd ios && pod install && cd .. && \
    flutter pub run flutter_launcher_icons:main
}

# --------- Script Start
if [ -z "$1" ]
  then
    echo "No argument supplied"
fi
if [ "$1" = "dev" ]
    then
        SetupDevEnv
fi
if [ "$1" = "prod" ]
    then
        SetupProdEnv
fi
if [ "$1" = "staging" ]
    then
        SetupStagingEnv
fi
if [ "$1" = "qa" ]
    then 
        SetupQAEnv
fi
if [ "$1" = "appbundle" ]
    then flutter build appbundle
fi
if [ "$1" = "increment_build" ]
    then perl -i -pe 's/^(version:\s+\d+\.\d+\.)(\d+)(\+)(\d+)$/$1.($2).$3.($4+1)/e' pubspec.yaml
fi
if [[ "$1" != "qa" ]] && [[ "$1" != "dev" ]] && [[ "$1" != "prod" ]] && [[ "$1" != "staging" ]] && [[ "$1" != "appbundle" ]] && [[ "$1" != "increment_build" ]] && [[ "$1" != "deploy" ]] && [[ "$1" != "deepclean" ]]
    then
        echo "Invalid argument supplied"
        echo "Arguments allowed qa / dev / prod / staging / appbundle / increment_build / deploy / deepclean"
fi
if [ "$1" = "deploy" ]
    then
    if [ -z "$2" ] 
        then echo "No 2nd argument supplied"
    else
        if [ "$2" = "dev" ]
            then
                SetupDevEnv
        fi
        if [ "$2" = "prod" ]
            then
                SetupProdEnv
        fi
        if [ "$1" = "staging" ]
            then
                SetupStagingEnv
        fi
        if [ "$2" = "qa" ]
            then 
                SetupQAEnv
        fi
        if [ -z "$3" ] 
            then
                echo "Starting deploy..." && \
                cd android && bundle exec fastlane beta && \
                cd .. && cd ios && pod install && bundle exec fastlane beta
        fi
        if [ "$3" = "ios" ]
            then 
                echo "Starting iOS deploy..." && \
                cd ios && pod install && bundle exec fastlane beta
        fi
        if [ "$3" = "android" ]
            then 
                echo "Starting android deploy..." && \
                cd android && bundle exec fastlane beta
        fi
    fi
fi
if [ "$1" = "deepclean" ]
  then
    echo "🤖" && \
    echo "Deep cleaning bot started working" && \
    flutter clean && \
    echo "Flutter is clean" && \
    rm ios/Podfile.lock || true && \
    echo "Podfile.lock has been terminated" && \
    rm pubspec.lock || true&& \
    echo "pubspec.lock has been exterminated" && \
    flutter pub get && cd ios && pod install --repo-update && cd .. && \
    echo "Many pods were installed" && \
    echo "🤖 Deep cleaning bot finished"
fi