//Options to update on settings
enum SettingsPrivacyOptions { public, restricted, anonymous }
enum WeightMeasures { kilograms, pounds }
enum SettingsPrivacyOptionsSubtitle { publicSubtitle, restrictedSubtitle, anonymousSubtitle }

Map<SettingsPrivacyOptions, String> privacySubtitles = {
  SettingsPrivacyOptions.public: 'publicSubtitle',
  SettingsPrivacyOptions.restricted: 'restrictedSubtitle',
  SettingsPrivacyOptions.anonymous: 'anonymousSubtitle',
};
enum EmailTemplateEnum { contactUs }
Map<EmailTemplateEnum, String> emailTemplates = {
  EmailTemplateEnum.contactUs: 'ContactUs',
};
enum MailEnum { support }
Map<MailEnum, String> mailsEnum = {
  MailEnum.support: 'hello@mvtfitnessapp.com',
};

enum ProgressArea { courses, classes, challenges }

//Enum for modal, to update images
enum UploadFrom { profileImage, transformationJourney, profileCoverImage, segmentDetail }
//Enum to share route where data for user is Requested on Profile views
enum ActualProfileRoute { rootProfile, userProfile, userAssessmentVideos, transformationJourney, homePage }
//Enum of options for upload content
enum DeviceContentFrom { camera, gallery, microphone }

enum ProfileOptionsTitle { myAccount, assessmentVideos, transformationPhotos, transformationJourney, subscription, settings, helpAndSupport, logout }

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
  recommendedVideo,
  introductionVideo,
  welcomeVideo,
  messageVideo
}

enum StoriesItemFrom { friends, friendsModal, home, neumorphicHome, longPressHome }

enum CoachAssignmentStatusEnum { requested, approved, rejected }

enum IntroductionMediaTypeEnum { introVideo, homeVideo, completedCourseVideo, coachTabCorePlan, coachTabWelcomeVideo }

Map<IntroductionMediaTypeEnum, String> introductionMediaType = {
  IntroductionMediaTypeEnum.introVideo: 'intro video',
  IntroductionMediaTypeEnum.homeVideo: 'home video',
  IntroductionMediaTypeEnum.completedCourseVideo: 'completed course video',
  IntroductionMediaTypeEnum.coachTabCorePlan: 'coach tab core plan',
  IntroductionMediaTypeEnum.coachTabWelcomeVideo: 'coach tab welcome video',
};

enum TimelineInteractionType { course, classes, segment, movement, mentoredVideo, sentVideo, recommendedVideo, introductionVideo, messageVideo, welcomeVideo }

enum ExceptionTypeEnum { uploadFailed, appFailed, permissionsFailed, loadFileFailed }

enum ExceptionTypeSourceEnum { invalidFormat, invalidDuration, invalidValue, noFileSelected }

enum MediaType { video, image, audio }

enum NoInternetContentEnum { fullscreen, widget }

enum FAQCategoriesEnum { myAccount, memberships, about }

Map<FAQCategoriesEnum, String> fAQCategories = {
  FAQCategoriesEnum.myAccount: 'myAccount',
  FAQCategoriesEnum.memberships: 'memberships',
  FAQCategoriesEnum.about: 'about',
};

enum EntityTypeEnum { course, classes, segment, movement, mentoredVideo, sentVideo }

enum UserInteractionEnum { login, firstAppInteraction }
