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
if [[ "$1" != "qa" ]] && [[ "$1" != "dev" ]] && [[ "$1" != "prod" ]]
    then echo "Arguments allowed qa / dev / prod"
fi