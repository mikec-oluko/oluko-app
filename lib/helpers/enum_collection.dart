//Options to update on settings
enum SettingsPrivacyOptions { public, restricted, anonymous }
enum SettingsPrivacyOptionsSubtitle { publicSubtitle, restrictedSubtitle, anonymousSubtitle }

Map<SettingsPrivacyOptions, String> privacySubtitles = {
  SettingsPrivacyOptions.public: 'publicSubtitle',
  SettingsPrivacyOptions.restricted: 'restrictedSubtitle',
  SettingsPrivacyOptions.anonymous: 'anonymousSubtitle',
};

enum ProgressArea { courses, classes, challenges }

//Enum for modal, to update images
enum UploadFrom { profileImage, transformationJourney, profileCoverImage, segmentDetail }
//Enum to share route where data for user is Requested on Profile views
enum ActualProfileRoute { rootProfile, userProfile, userAssessmentVideos, transformationJourney }
//Enum of options for upload content
enum DeviceContentFrom { camera, gallery }

enum ProfileOptionsTitle { myAccount, assessmentVideos, transformationJourney, subscription, settings, helpAndSupport, logout }

enum ErrorTypeOption { noConnection, noContent }

enum OlukoPanelAction { open, close, hide, show, loading, error, success }

enum UserConnectStatus { connected, notConnected, requestPending, requestReceived }

enum CoachContentSection { sentVideos, mentoredVideos, recomendedVideos, voiceMessages }

enum CoachFileTypeEnum {
  mentoredVideo,
  sentVideo,
  recommendedCourse,
  recommendedClass,
  recommendedMovement,
  recommendedSegment,
  faqVideo,
  recommendedVideo
}

enum StoriesItemFrom { friends, friendsModal, home, neumorphicHome, longPressHome }

enum CoachAssignmentStatusEnum { requested, approved, rejected }

enum IntroductionMediaTypeEnum { introVideo, homeVideo, completedCourseVideo,coachTabCorePlan }

Map<IntroductionMediaTypeEnum, String> introductionMediaType = {
  IntroductionMediaTypeEnum.introVideo: 'intro video',
  IntroductionMediaTypeEnum.homeVideo: 'home video',
  IntroductionMediaTypeEnum.completedCourseVideo: 'completed course video',
  IntroductionMediaTypeEnum.coachTabCorePlan: 'coach tab core plan',
};

enum TimelineInteractionType {
  course,
  classes,
  segment,
  movement,
  mentoredVideo,
  sentVideo,
  recommendedVideo,
}

enum ExceptionTypeEnum { uploadFailed, appFailed, permissionsFailed, loadFileFailed }

enum ExceptionTypeSourceEnum { invalidFormat, invalidDuration, invalidValue, noFileSelected }

enum NoInternetContentEnum { fullscreen, widget }

enum FAQCategoriesEnum { myAccount, memberships, about }

Map<FAQCategoriesEnum, String> fAQCategories = {
  FAQCategoriesEnum.myAccount: 'My Account',
  FAQCategoriesEnum.memberships: 'Memberships',
  FAQCategoriesEnum.about:'About',
};