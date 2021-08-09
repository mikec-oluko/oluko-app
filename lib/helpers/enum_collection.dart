//Options to update on settings
enum SettingsPrivacyOptions { public, restricted, anonymous }
enum SettingsPrivacyOptionsSubtitle {
  publicSubtitle,
  restrictedSubtitle,
  anonymousSubtitle
}

Map<SettingsPrivacyOptions, String> privacySubtitles = {
  SettingsPrivacyOptions.public: 'publicSubtitle',
  SettingsPrivacyOptions.restricted: 'restrictedSubtitle',
  SettingsPrivacyOptions.anonymous: 'anonymousSubtitle',
};

//Enum for modal, to update images
enum UploadFrom { profileImage, transformationJourney, profileCoverImage }
//Enum to share route where data for user is Requested on Profile views
enum ActualProfileRoute {
  rootProfile,
  userProfile,
  userAssessmentVideos,
  transformationJourney
}
//Enum of options for upload content
enum DeviceContentFrom { camera, gallery }

enum ProfileOptionsTitle {
  myAccount,
  assessmentVideos,
  transformationJourney,
  subscription,
  settings,
  helpAndSupport
}
