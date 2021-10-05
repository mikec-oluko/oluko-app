if [ -z "$1" ]
  then
    echo "No argument supplied"
fi
if [ "$1" = "dev" ]
    then echo "Setting up development environment" && flutter clean && \
    cp ios/Flutter/src/development/GoogleService-Info.plist ios/Flutter && \
    cp android/app/src/development/google-services.json android/app && \
    cp lib/config/src/development/project_settings.dart lib/config/src/development/s3_settings.dart lib/config && \
    flutter pub get && cd ios && pod install && cd ..
fi
if [ "$1" = "prod" ]
    then echo "Setting up production environment" && flutter clean && \
    cp ios/Flutter/src/production/GoogleService-Info.plist ios/Flutter && \
    cp ios/Flutter/src/production/google-services.json android/app && \
    cp lib/config/src/production/project_settings.dart lib/config/src/production/s3_settings.dart lib/config && \
    flutter pub get && cd ios && pod install && cd ..
fi
if [ "$1" = "qa" ]
    then echo "Setting up qa environment" && flutter clean && \
    cp ios/Flutter/src/qa/GoogleService-Info.plist ios/Flutter && \
    cp android/app/src/qa/google-services.json android/app && \
    cp lib/config/src/qa/project_settings.dart lib/config/src/qa/s3_settings.dart lib/config && \
    flutter pub get && cd ios && pod install && cd ..
fi
if [ "$1" = "appbundle" ]
    then flutter build appbundle
fi
if [ "$1" = "increment_build" ]
    then perl -i -pe 's/^(version:\s+\d+\.\d+\.)(\d+)(\+)(\d+)$/$1.($2).$3.($4+1)/e' pubspec.yaml
fi
if [[ "$1" != "qa" ]] && [[ "$1" != "dev" ]] && [[ "$1" != "prod" ]] && [[ "$1" != "appbundle" ]] && [[ "$1" != "increment_build" ]] && [[ "$1" != "deploy" ]]
    then echo "Arguments allowed qa / dev / prod / appbundle / increment_build"
fi
if [ "$1" = "deploy" ]
    then
    if [ -z "$2" ] 
    then echo "No 2nd argument supplied"
    else
        if [ "$2" = "dev" ]
            then echo "Setting up development environment" && flutter clean && \
            cp ios/Flutter/src/development/GoogleService-Info.plist ios/Flutter && \
            cp android/app/src/development/google-services.json android/app && \
            cp lib/config/src/development/project_settings.dart lib/config/src/development/s3_settings.dart lib/config && \
            flutter pub get && cd ios && pod install && cd ..
        fi
        if [ "$2" = "prod" ]
            then echo "Setting up production environment" && flutter clean && \
            cp ios/Flutter/src/production/GoogleService-Info.plist ios/Flutter && \
            cp ios/Flutter/src/production/google-services.json android/app && \
            cp lib/config/src/production/project_settings.dart lib/config/src/production/s3_settings.dart lib/config && \
            flutter pub get && cd ios && pod install && cd ..
        fi
        if [ "$2" = "qa" ]
            then echo "Setting up qa environment" && flutter clean && \
            cp ios/Flutter/src/qa/GoogleService-Info.plist ios/Flutter && \
            cp android/app/src/qa/google-services.json android/app && \
            cp lib/config/src/qa/project_settings.dart lib/config/src/qa/s3_settings.dart lib/config && \
            flutter pub get && cd ios && pod install && cd ..
        fi
        echo "Starting deploy..." && \
        cd android && bundle exec fastlane beta && \
        cd .. && cd ios && bundle exec fastlane beta
    fi
fi