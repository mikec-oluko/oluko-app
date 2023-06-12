import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/blocs/amrap_round_bloc.dart';
import 'package:oluko_app/blocs/assessment_assignment_bloc.dart';
import 'package:oluko_app/blocs/assessment_bloc.dart';
import 'package:oluko_app/blocs/assessment_visibility_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/carrousel_bloc.dart';
import 'package:oluko_app/blocs/challenge/challenge_audio_bloc.dart';
import 'package:oluko_app/blocs/challenge/challenge_bloc.dart';
import 'package:oluko_app/blocs/challenge/challenge_completed_before_bloc.dart';
import 'package:oluko_app/blocs/challenge/challenge_segment_bloc.dart';
import 'package:oluko_app/blocs/challenge/panel_audio_bloc.dart';
import 'package:oluko_app/blocs/challenge/upcoming_challenge_bloc.dart';
import 'package:oluko_app/blocs/chat_slider_bloc.dart';
import 'package:oluko_app/blocs/chat_slider_messages_bloc.dart';
import 'package:oluko_app/blocs/class/class_subscription_bloc.dart';
import 'package:oluko_app/blocs/clocks_timer_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_audio_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_audio_messages_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_audio_panel_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_introduction_video_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_request_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_user_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_video_message_bloc.dart';
import 'package:oluko_app/blocs/community_tab_friend_notification_bloc.dart';
import 'package:oluko_app/blocs/course/course_friend_recommended_bloc.dart';
import 'package:oluko_app/blocs/course/course_home_bloc.dart';
import 'package:oluko_app/blocs/course/course_liked_courses_bloc.dart';
import 'package:oluko_app/blocs/course/course_subscription_bloc.dart';
import 'package:oluko_app/blocs/course/course_user_interaction_bloc.dart';
import 'package:oluko_app/blocs/course_category_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_audio_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_chat_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_update_bloc.dart';
import 'package:oluko_app/blocs/course_panel_bloc.dart';
import 'package:oluko_app/blocs/done_challenge_users_bloc.dart';
import 'package:oluko_app/blocs/download_assets_bloc.dart';
import 'package:oluko_app/blocs/enrollment_audio_bloc.dart';
import 'package:oluko_app/blocs/feedback_bloc.dart';
import 'package:oluko_app/blocs/friends/chat_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_request_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_received_bloc.dart';
import 'package:oluko_app/blocs/friends/message_bloc.dart';
import 'package:oluko_app/blocs/friends_weight_records_bloc.dart';
import 'package:oluko_app/blocs/gallery_video_bloc.dart';
import 'package:oluko_app/blocs/inside_class_content_bloc.dart';
import 'package:oluko_app/blocs/internet_connection_bloc.dart';
import 'package:oluko_app/blocs/introduction_media_bloc.dart';
import 'package:oluko_app/blocs/movement_weight_bloc.dart';
import 'package:oluko_app/blocs/notification_bloc.dart';
import 'package:oluko_app/blocs/notification_settings_bloc.dart';
import 'package:oluko_app/blocs/personal_record_bloc.dart';
import 'package:oluko_app/blocs/points_card_bloc.dart';
import 'package:oluko_app/blocs/profile/mail_bloc.dart';
import 'package:oluko_app/blocs/profile/max_weights_bloc.dart';
import 'package:oluko_app/blocs/profile/my_account_bloc.dart';
import 'package:oluko_app/blocs/project_configuration_bloc.dart';
import 'package:oluko_app/blocs/push_notification_bloc.dart';
import 'package:oluko_app/blocs/remain_selected_tags_bloc.dart';
import 'package:oluko_app/blocs/segment_detail_content_bloc.dart';
import 'package:oluko_app/blocs/segment_submission_bloc.dart';
import 'package:oluko_app/blocs/segments/current_time_bloc.dart';
import 'package:oluko_app/blocs/selected_tags_bloc.dart';
import 'package:oluko_app/blocs/sign_up_bloc.dart';
import 'package:oluko_app/blocs/statistics/statistics_subscription_bloc.dart';
import 'package:oluko_app/blocs/stopwatch_bloc.dart';
import 'package:oluko_app/blocs/subscribed_course_users_bloc.dart';
import 'package:oluko_app/blocs/subscription_content_bloc.dart';
import 'package:oluko_app/blocs/task_card_bloc.dart';
import 'package:oluko_app/blocs/task_review_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_list_bloc.dart';
import 'package:oluko_app/blocs/class/class_bloc.dart';
import 'package:oluko_app/blocs/course/course_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/favorite_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/blocs/friends/ignore_friend_request_bloc.dart';
import 'package:oluko_app/blocs/movement_bloc.dart';
import 'package:oluko_app/blocs/plan_bloc.dart';
import 'package:oluko_app/blocs/profile/profile_bloc.dart';
import 'package:oluko_app/blocs/recommendation_bloc.dart';
import 'package:oluko_app/blocs/segment_bloc.dart';
import 'package:oluko_app/blocs/statistics/statistics_bloc.dart';
import 'package:oluko_app/blocs/story_bloc.dart';
import 'package:oluko_app/blocs/story_list_bloc.dart';
import 'package:oluko_app/blocs/tag_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_bloc.dart';
import 'package:oluko_app/blocs/timer_task_bloc.dart';
import 'package:oluko_app/blocs/transformation_journey_bloc.dart';
import 'package:oluko_app/blocs/user/user_information_bloc.dart';
import 'package:oluko_app/blocs/user/user_plan_subscription_bloc.dart';
import 'package:oluko_app/blocs/user_audio_bloc.dart';
import 'package:oluko_app/blocs/user_bloc.dart';
import 'package:oluko_app/blocs/user_list_bloc.dart';
import 'package:oluko_app/blocs/user_progress_bloc.dart';
import 'package:oluko_app/blocs/user_progress_list_bloc.dart';
import 'package:oluko_app/blocs/user_progress_stream_bloc.dart';
import 'package:oluko_app/blocs/users_selfies_bloc.dart';
import 'package:oluko_app/blocs/video_bloc.dart';
import 'package:oluko_app/blocs/views_bloc/faq_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_recommendation_default.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/coach_media.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/coach_user.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/event.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/screens/app_plans.dart';
import 'package:oluko_app/ui/screens/assessments/assessment_neumorphic_done_screen.dart';
import 'package:oluko_app/ui/screens/assessments/assessment_videos.dart';
import 'package:oluko_app/ui/screens/assessments/self_recording.dart';
import 'package:oluko_app/ui/screens/assessments/self_recording_preview.dart';
import 'package:oluko_app/ui/screens/assessments/task_details.dart';
import 'package:oluko_app/ui/screens/assessments/task_submission_recorded_video.dart';
import 'package:oluko_app/ui/screens/assessments/task_submission_review_preview.dart';
import 'package:oluko_app/ui/screens/authentication/introduction_video.dart';
import 'package:oluko_app/ui/screens/authentication/login.dart';
import 'package:oluko_app/ui/screens/authentication/loginWithSteps/login_password.dart';
import 'package:oluko_app/ui/screens/authentication/loginWithSteps/login_username.dart';
import 'package:oluko_app/ui/screens/authentication/login_neumorphic.dart';
import 'package:oluko_app/ui/screens/authentication/register.dart';
import 'package:oluko_app/ui/screens/authentication/sign_up.dart';
import 'package:oluko_app/ui/screens/authentication/sign_up_with_email.dart';
import 'package:oluko_app/ui/screens/choose_plan_payment.dart';
import 'package:oluko_app/ui/screens/coach/about_coach_page.dart';
import 'package:oluko_app/ui/screens/coach/coach_page.dart';
import 'package:oluko_app/ui/screens/coach/coach_profile.dart';
import 'package:oluko_app/ui/screens/coach/coach_recommended_content_list.dart';
import 'package:oluko_app/ui/screens/coach/coach_show_video.dart';
import 'package:oluko_app/ui/screens/coach/mentored_videos.dart';
import 'package:oluko_app/ui/screens/coach/sent_videos.dart';
import 'package:oluko_app/ui/screens/courses/chat.dart';
import 'package:oluko_app/ui/screens/courses/completed_class.dart';
import 'package:oluko_app/ui/screens/courses/course_marketing.dart';
import 'package:oluko_app/ui/screens/courses/course_share_view.dart';
import 'package:oluko_app/ui/screens/courses/courses.dart';
import 'package:oluko_app/ui/screens/courses/enrolled_class.dart';
import 'package:oluko_app/ui/screens/courses/enrolled_course.dart';
import 'package:oluko_app/ui/screens/courses/explore_subscribed_users.dart';
import 'package:oluko_app/ui/screens/courses/inside_class.dart';
import 'package:oluko_app/ui/screens/courses/movement_intro.dart';
import 'package:oluko_app/ui/screens/courses/segment_camera_preview.dart.dart';
import 'package:oluko_app/ui/screens/courses/segment_detail.dart';
import 'package:oluko_app/ui/screens/courses/user_challenge_detail.dart';
import 'package:oluko_app/ui/screens/friends/friends_page.dart';
import 'package:oluko_app/ui/screens/hi_five_page.dart';
import 'package:oluko_app/ui/screens/home_long_press.dart';
import 'package:oluko_app/ui/screens/home_neumorphic_content.dart';
import 'package:oluko_app/ui/screens/home_neumorphic_latest_design.dart';
import 'package:oluko_app/ui/screens/main_page.dart';
import 'package:oluko_app/ui/screens/oluko_no_internet_connection.dart';
import 'package:oluko_app/ui/screens/profile/profile.dart';
import 'package:oluko_app/ui/screens/profile/profile_assessment_videos_page.dart';
import 'package:oluko_app/ui/screens/profile/profile_challenges_page.dart';
import 'package:oluko_app/ui/screens/profile/profile_help_and_support_contact_us.dart';
import 'package:oluko_app/ui/screens/profile/profile_help_and_support_page.dart';
import 'package:oluko_app/ui/screens/profile/profile_max_weights_page.dart';
import 'package:oluko_app/ui/screens/profile/profile_my_account_page.dart';
import 'package:oluko_app/ui/screens/profile/profile_settings_page.dart';
import 'package:oluko_app/ui/screens/profile/profile_subscription_page.dart';
import 'package:oluko_app/ui/screens/profile/profile_transformation_journey_page.dart';
import 'package:oluko_app/ui/screens/profile/transformation_journey_content_detail.dart';
import 'package:oluko_app/ui/screens/profile/transformation_journey_post.dart';
import 'package:oluko_app/ui/screens/profile/user_profile_page.dart';
import 'package:oluko_app/ui/screens/story/story_page.dart';
import 'package:oluko_app/ui/screens/welcome_video_first_time_login.dart';
import 'package:oluko_app/utils/segment_clocks_utils.dart';
import 'blocs/audio_bloc.dart';
import 'blocs/coach/coach_assignment_bloc.dart';
import 'blocs/coach/coach_interaction_timeline_bloc.dart';
import 'blocs/coach/coach_media_bloc.dart';
import 'blocs/coach/coach_mentored_videos_bloc.dart';
import 'blocs/coach/coach_recommendations_bloc.dart';
import 'blocs/coach/coach_request_stream_bloc.dart';
import 'blocs/coach/coach_review_pending_bloc.dart';
import 'blocs/coach/coach_sent_videos_bloc.dart';
import 'blocs/coach/coach_timeline_bloc.dart';
import 'blocs/course_enrollment/course_enrollment_list_stream_bloc.dart';
import 'blocs/movement_info_bloc.dart';
import 'blocs/friends/hi_five_send_bloc.dart';
import 'blocs/points_card_panel_bloc.dart';
import 'blocs/recording_alert_bloc.dart';
import 'blocs/views_bloc/hi_five_bloc.dart';
import 'models/annotation.dart';
import 'models/coach_media_message.dart';
import 'models/recommendation_media.dart';
import 'models/segment_submission.dart';
import 'models/task.dart';
import 'ui/screens/coach/coach_main_page.dart';
import 'package:oluko_app/ui/screens/courses/segment_clocks.dart';
import 'package:oluko_app/ui/screens/view_all.dart';
import 'blocs/friends/confirm_friend_bloc.dart';
import 'blocs/friends/favorite_friend_bloc.dart';
import 'blocs/oluko_panel_bloc.dart';
import 'blocs/profile/profile_avatar_bloc.dart';
import 'blocs/profile/profile_cover_image_bloc.dart';
import 'blocs/profile/upload_transformation_journey_content_bloc.dart';
import 'blocs/user_statistics_bloc.dart';
import 'models/course.dart';
import 'models/dto/story_dto.dart';
import 'models/transformation_journey_uploads.dart';
import 'package:oluko_app/blocs/country_bloc.dart';
import 'blocs/coach_tab_notification.dart';

enum RouteEnum {
  root,
  introVideo,
  signUp,
  loginNeumorphic,
  signUpWithEmail,
  login,
  friends,
  profile,
  profileSettings,
  profileMyAccount,
  profileSubscription,
  profileHelpAndSupport,
  profileContactUs,
  profileViewOwnProfile,
  profileChallenges,
  profileTransformationJourney,
  profileAssessmentVideos,
  transformationJourneyPost,
  transformationJournetContentDetails,
  transformationJourneyPostView,
  logInUsername,
  logInPassword,
  appPlans,
  segmentDetail,
  movementIntro,
  segmentClocks,
  courseMarketing,
  enrolledCourse,
  assessmentVideos,
  taskDetails,
  choosePlanPayment,
  courses,
  videos,
  viewAll,
  insideClass,
  selfRecording,
  selfRecordingPreview,
  enrolledClass,
  taskSubmissionVideo,
  taskSubmissionReviewPreview,
  exploreSubscribedUsers,
  segmentCameraPreview,
  coach,
  coach2,
  sentVideos,
  mentoredVideos,
  coachShowVideo,
  coachProfile,
  completedClass,
  story,
  hiFivePage,
  userChallengeDetail,
  homeLongPress,
  assessmentNeumorphicDone,
  coachRecommendedContentGallery,
  aboutCoach,
  noInternetConnection,
  courseShareView,
  registerUser,
  homeLatestDesign,
  courseHomePage,
  welcomeVideoFirstTimeLogin,
  courseChat,
  maxWeights
}

Map<RouteEnum, String> routeLabels = {
  RouteEnum.root: '/',
  RouteEnum.introVideo: '/intro_video',
  RouteEnum.signUp: '/sign-up',
  RouteEnum.loginNeumorphic: '/login-neumorphic',
  RouteEnum.signUpWithEmail: '/sign-up-with-email',
  RouteEnum.login: '/login',
  RouteEnum.friends: '/friends',
  RouteEnum.profile: '/profile',
  RouteEnum.profileSettings: '/profile-settings',
  RouteEnum.profileMyAccount: '/profile-my-account',
  RouteEnum.profileSubscription: '/profile-subscription',
  RouteEnum.profileHelpAndSupport: '/profile-help-and-support',
  RouteEnum.profileContactUs: '/profile-help-and-support-contact-us',
  RouteEnum.profileViewOwnProfile: '/profile-view-user-profile',
  RouteEnum.profileChallenges: '/profile-challenges',
  RouteEnum.profileTransformationJourney: '/profile-transformation-journey',
  RouteEnum.profileAssessmentVideos: '/profile-assessment-videos',
  RouteEnum.transformationJourneyPost: '/transformation-journey-post',
  RouteEnum.transformationJournetContentDetails: '/transformation-journey-content-details',
  RouteEnum.transformationJourneyPostView: '/transformation-journey-post-view',
  RouteEnum.logInUsername: '/log-in-username',
  RouteEnum.logInPassword: '/log-in-password',
  RouteEnum.appPlans: '/app-plans',
  RouteEnum.segmentDetail: '/segment-detail',
  RouteEnum.movementIntro: '/movement-intro',
  RouteEnum.segmentClocks: '/segment-clocks',
  RouteEnum.courseMarketing: '/course-marketing',
  RouteEnum.enrolledCourse: '/enrolled-course',
  RouteEnum.assessmentVideos: '/assessment-videos',
  RouteEnum.taskDetails: '/task-details',
  RouteEnum.choosePlanPayment: '/choose-plan-payment',
  RouteEnum.courses: '/courses',
  RouteEnum.videos: '/videos',
  RouteEnum.viewAll: '/view-all',
  RouteEnum.insideClass: '/inside-class',
  RouteEnum.selfRecording: '/self-recording',
  RouteEnum.selfRecordingPreview: '/self-recording-preview',
  RouteEnum.enrolledClass: '/enrolled-class',
  RouteEnum.taskSubmissionVideo: '/task-submission-video',
  RouteEnum.taskSubmissionReviewPreview: "/task-submission-review-preview",
  RouteEnum.exploreSubscribedUsers: '/explore-subscribed-users',
  RouteEnum.segmentCameraPreview: '/segment-camera-preview',
  RouteEnum.coach: '/coach',
  RouteEnum.coach2: '/coach2',
  RouteEnum.sentVideos: '/coach-sent-videos',
  RouteEnum.mentoredVideos: '/coach-mentored-videos',
  RouteEnum.coachShowVideo: '/coach-show-video',
  RouteEnum.coachProfile: '/coach-profile',
  RouteEnum.completedClass: '/completed-class',
  RouteEnum.story: '/story',
  RouteEnum.hiFivePage: '/hi-five-page',
  RouteEnum.userChallengeDetail: '/user-challenge-detail',
  RouteEnum.homeLongPress: 'home_long_press',
  RouteEnum.assessmentNeumorphicDone: '/assessment_neumorphic_done',
  RouteEnum.coachRecommendedContentGallery: '/coach-recommended-content-gallery',
  RouteEnum.aboutCoach: '/coach-about-coach-view',
  RouteEnum.noInternetConnection: '/no-internet-connection',
  RouteEnum.courseShareView: '/course-share-view',
  RouteEnum.registerUser: '/register-user',
  RouteEnum.homeLatestDesign: '/home-view',
  RouteEnum.courseHomePage: '/course-home-page',
  RouteEnum.welcomeVideoFirstTimeLogin: '/welcome-video-home-page',
  RouteEnum.courseChat: '/course-chat',
  RouteEnum.maxWeights: '/max-weights',
};

RouteEnum getEnumFromRouteString(String route) {
  final routeIndex = routeLabels.values.toList().indexOf(route);
  return routeIndex != -1 ? routeLabels.keys.toList()[routeIndex] : null;
}

class Routes {
  final OlukoPanelBloc _olukoPanelBloc = OlukoPanelBloc();
  final AuthBloc _authBloc = AuthBloc();
  final IntroductionMediaBloc _introductionMediaBloc = IntroductionMediaBloc();
  final ProfileBloc _profileBloc = ProfileBloc();
  final CourseBloc _courseBloc = CourseBloc();
  final CourseHomeBloc _courseHomeBloc = CourseHomeBloc();
  final TagBloc _tagBloc = TagBloc();
  final FriendBloc _friendBloc = FriendBloc();
  final FriendRequestBloc _friendRequestBloc = FriendRequestBloc();
  final ConfirmFriendBloc _confirmFriendBloc = ConfirmFriendBloc();
  final IgnoreFriendRequestBloc _ignoreFriendRequestBloc = IgnoreFriendRequestBloc();
  final FavoriteFriendBloc _favoriteFriendBloc = FavoriteFriendBloc();
  final AssessmentBloc _assessmentBloc = AssessmentBloc();
  final AssessmentAssignmentBloc _assessmentAssignmentBloc = AssessmentAssignmentBloc();
  final AssessmentVisibilityBloc _assessmentVisibilityBloc = AssessmentVisibilityBloc();
  final TaskSubmissionBloc _taskSubmissionBloc = TaskSubmissionBloc();
  final CourseEnrollmentBloc _courseEnrollmentBloc = CourseEnrollmentBloc();
  final TransformationJourneyBloc _transformationJourneyBloc = TransformationJourneyBloc();
  final ClassBloc _classBloc = ClassBloc();
  final SubscribedCourseUsersBloc _subscribedCourseUsersBloc = SubscribedCourseUsersBloc();
  final StatisticsBloc _statisticsBloc = StatisticsBloc();
  final StatisticsSubscriptionBloc _statisticsSubscriptionBloc = StatisticsSubscriptionBloc();
  final MovementBloc _movementBloc = MovementBloc();
  final MovementInfoBloc _movementInfoBloc = MovementInfoBloc();
  final SegmentBloc _segmentBloc = SegmentBloc();
  final TaskBloc _taskBloc = TaskBloc();
  final VideoBloc _videoBloc = VideoBloc();
  final FavoriteBloc _favoriteBloc = FavoriteBloc();
  final RecommendationBloc _recommendationBloc = RecommendationBloc();
  final PlanBloc _planBloc = PlanBloc();
  final TaskSubmissionListBloc _taskSubmissionListBloc = TaskSubmissionListBloc();
  final GalleryVideoBloc _galleryVideoBloc = GalleryVideoBloc();
  final CourseEnrollmentListBloc _courseEnrollmentListBloc = CourseEnrollmentListBloc();
  final CourseEnrollmentListStreamBloc _courseEnrollmentListStreamBloc = CourseEnrollmentListStreamBloc();
  final SegmentSubmissionBloc _segmentSubmissionBloc = SegmentSubmissionBloc();
  final TransformationJourneyContentBloc _transformationJourneyContentBloc = TransformationJourneyContentBloc();
  final ProfileAvatarBloc _profileAvatarBloc = ProfileAvatarBloc();
  final ProfileCoverImageBloc _profileCoverImageBloc = ProfileCoverImageBloc();
  final UserStatisticsBloc _userStatisticsBloc = UserStatisticsBloc();
  final CourseEnrollmentUpdateBloc _courseEnrollmentUpdateBloc = CourseEnrollmentUpdateBloc();
  final UserListBloc _userListBloc = UserListBloc();
  final UserBloc _userBloc = UserBloc();
  final StoryBloc _storyBloc = StoryBloc();
  final StoryListBloc _storyListBloc = StoryListBloc();
  final CoachAssignmentBloc _coachAssignmentBloc = CoachAssignmentBloc();
  final CoachSentVideosBloc _coachSentVideosBloc = CoachSentVideosBloc();
  final CoachMentoredVideosBloc _coachMentoredVideosBloc = CoachMentoredVideosBloc();
  final CoachTimelineItemsBloc _coachTimelineItemsBloc = CoachTimelineItemsBloc();
  final ChatBloc _chatBloc = ChatBloc();
  final MessageBloc _messageBloc = MessageBloc();
  final HiFiveReceivedBloc _hiFiveReceivedBloc = HiFiveReceivedBloc();
  final HiFiveSendBloc _hiFiveSendBloc = HiFiveSendBloc();
  final HiFiveBloc _hiFiveBloc = HiFiveBloc();
  final CoachRequestBloc _coachRequestBloc = CoachRequestBloc();
  final CoachRequestStreamBloc _coachRequestStreamBloc = CoachRequestStreamBloc();
  final CoachUserBloc _coachUserBloc = CoachUserBloc();
  final SegmentDetailContentBloc _segmentDetailContentBloc = SegmentDetailContentBloc();
  final DoneChallengeUsersBloc _doneChallengeUsersBloc = DoneChallengeUsersBloc();
  final PersonalRecordBloc _personalRecordBloc = PersonalRecordBloc();
  final CoachAudioBloc _coachAudioBloc = CoachAudioBloc();
  final ChallengeStreamBloc _challengeBloc = ChallengeStreamBloc();
  final CoachRecommendationsBloc _coachRecommendationsBloc = CoachRecommendationsBloc();
  final CoachTimelineBloc _coachTimelineBloc = CoachTimelineBloc();
  final AudioBloc _audioBloc = AudioBloc();
  final CoachIntroductionVideoBloc _coachIntroductionVideo = CoachIntroductionVideoBloc();
  final CoachReviewPendingBloc _coachReviewPendingBloc = CoachReviewPendingBloc();
  final RecordingAlertBloc _recordingAlertBloc = RecordingAlertBloc();
  final InsideClassContentBloc _insideClassContentBloc = InsideClassContentBloc();
  final CourseCategoryBloc _courseCategoryBloc = CourseCategoryBloc();
  final CourseSubscriptionBloc _courseSubscriptionBloc = CourseSubscriptionBloc();
  final ClassSubscriptionBloc _classSubscriptionBloc = ClassSubscriptionBloc();
  final UserAudioBloc _userAudioBloc = UserAudioBloc();
  final ChallengeSegmentBloc _challengeSegmentBloc = ChallengeSegmentBloc();
  final CourseEnrollmentAudioBloc _courseEnrollmentAudioBloc = CourseEnrollmentAudioBloc();
  final ChallengeAudioBloc _challengeAudioBloc = ChallengeAudioBloc();
  final EnrollmentAudioBloc _enrollmentAudioBloc = EnrollmentAudioBloc();
  final PanelAudioBloc _panelAudioBloc = PanelAudioBloc();
  final TaskReviewBloc _taskReviewBloc = TaskReviewBloc();
  final TaskCardBloc _taskCardBloc = TaskCardBloc();
  final NotificationBloc _notificationBloc = NotificationBloc();
  final NotificationSettingsBloc _notificationSettingsBloc = NotificationSettingsBloc();
  final FeedbackBloc _feedbackBloc = FeedbackBloc();
  final CoachMediaBloc _coachMediaBloc = CoachMediaBloc();
  final GenericAudioPanelBloc _coachAudioPanelBloc = GenericAudioPanelBloc();
  final CoachAudioMessageBloc _coachAudioMessageBloc = CoachAudioMessageBloc();
  final ClocksTimerBloc _clocksTimerBloc = ClocksTimerBloc();
  final TimerTaskBloc _timerTaskBloc = TimerTaskBloc();
  final SelectedTagsBloc _selectedTagsBloc = SelectedTagsBloc();
  final ProjectConfigurationBloc _projectConfigurationBloc = ProjectConfigurationBloc();
  final PushNotificationBloc _pushNotificationBloc = PushNotificationBloc();
  final DownloadAssetBloc _downloadAssetBloc = DownloadAssetBloc();
  final StopwatchBloc _stopwatchBloc = StopwatchBloc();
  final CurrentTimeBloc _currentTimeBloc = CurrentTimeBloc();
  final AmrapRoundBloc _amrapRoundBloc = AmrapRoundBloc();
  final InternetConnectionBloc _internetConnectionBloc = InternetConnectionBloc();
  final CarouselBloc _carouselBloc = CarouselBloc();
  final RemainSelectedTagsBloc _remainSelectedTagsBloc = RemainSelectedTagsBloc();
  final UserProgressBloc _userProgressBloc = UserProgressBloc();
  final UserProgressStreamBloc _userProgressStreamBloc = UserProgressStreamBloc();
  final UserInformationBloc _userInformationBloc = UserInformationBloc();
  final ChallengeCompletedBeforeBloc _challengeCompletedBeforeBloc = ChallengeCompletedBeforeBloc();
  final UserProgressListBloc _userProgressListBloc = UserProgressListBloc();
  final FAQBloc _fAQBloc = FAQBloc();
  final CourseUserIteractionBloc _courseInteractionBloc = CourseUserIteractionBloc();
  final CourseRecommendedByFriendBloc _courseRecommendedByFriendBloc = CourseRecommendedByFriendBloc();
  final LikedCoursesBloc _courseLikedBloc = LikedCoursesBloc();
  final MailBloc _mailBloc = MailBloc();
  final CoursePanelBloc _coursePanelBloc = CoursePanelBloc();
  final UpcomingChallengesBloc _upcomingChallengesBloc = UpcomingChallengesBloc();
  final CoachVideoMessageBloc _coachVideoMessageBloc = CoachVideoMessageBloc();
  final UsersSelfiesBloc _usersSelfiesBloc = UsersSelfiesBloc();
  final MyAccountBloc _myAccountBloc = MyAccountBloc();
  final CountryBloc _countryBloc = CountryBloc();
  final SignupBloc _signUpBloc = SignupBloc();
  final UserPlanSubscriptionBloc _userPlanSubscriptionBloc = UserPlanSubscriptionBloc();
  final CourseEnrollmentChatBloc _courseEnrollmentChatBloc = CourseEnrollmentChatBloc();
  final ChatSliderMessagesBloc _chatSliderMessagesBloc = ChatSliderMessagesBloc();
  final WorkoutWeightBloc _workoutWeightBloc = WorkoutWeightBloc();
  final PointsCardBloc _pointsCardBloc = PointsCardBloc();
  final PointsCardPanelBloc _pointsCardPanelBloc = PointsCardPanelBloc();
  final FriendsWeightRecordsBloc _friendsWeightRecordsBloc = FriendsWeightRecordsBloc();
  final CommunityTabFriendNotificationBloc _communityTabFriendNotificationBloc = CommunityTabFriendNotificationBloc();
  final ChatSliderBloc _chatSliderBloc = ChatSliderBloc();
  final MaxWeightsBloc _maxWeightsBloc = MaxWeightsBloc();
  final CoachTabNotificationBloc _coachTabNotificationBloc = CoachTabNotificationBloc();

  Route<dynamic> getRouteView(String route, Object arguments) {
    //View for the new route.
    Widget newRouteView;
    //Providers used for the new route.
    List<BlocProvider> providers = [];
    //Providers used across the whole app.
    final List<BlocProvider> commonProviders = [
      BlocProvider<AuthBloc>.value(value: _authBloc),
      BlocProvider<FAQBloc>.value(value: _fAQBloc),
      BlocProvider<UserInformationBloc>.value(value: _userInformationBloc),
    ];

    if (Platform.isIOS || Platform.isMacOS) {
      commonProviders.add(BlocProvider<SubscriptionContentBloc>.value(value: SubscriptionContentBloc()));
    }

    final RouteEnum routeEnum = getEnumFromRouteString(route);
    switch (routeEnum) {
      case RouteEnum.root:
        providers = [
          BlocProvider<PointsCardPanelBloc>.value(value: _pointsCardPanelBloc),
          BlocProvider<PointsCardBloc>.value(value: _pointsCardBloc),
          BlocProvider<UsersSelfiesBloc>.value(value: _usersSelfiesBloc),
          BlocProvider<UserProgressListBloc>.value(value: _userProgressListBloc),
          BlocProvider<UserProgressStreamBloc>.value(value: _userProgressStreamBloc),
          BlocProvider<RemainSelectedTagsBloc>.value(value: _remainSelectedTagsBloc),
          BlocProvider<SelectedTagsBloc>.value(value: _selectedTagsBloc),
          BlocProvider<TaskCardBloc>.value(value: _taskCardBloc),
          BlocProvider<SegmentSubmissionBloc>.value(value: _segmentSubmissionBloc),
          BlocProvider<VideoBloc>.value(value: _videoBloc),
          BlocProvider<TaskSubmissionListBloc>.value(value: _taskSubmissionListBloc),
          BlocProvider<HiFiveReceivedBloc>.value(
            value: _hiFiveReceivedBloc,
          ),
          BlocProvider<ChallengeStreamBloc>.value(value: _challengeBloc),
          BlocProvider<CourseHomeBloc>.value(value: _courseHomeBloc),
          BlocProvider<CourseSubscriptionBloc>.value(value: _courseSubscriptionBloc),
          BlocProvider<ClassBloc>.value(value: _classBloc),
          BlocProvider<CourseEnrollmentListStreamBloc>.value(value: _courseEnrollmentListStreamBloc),
          BlocProvider<TagBloc>.value(value: _tagBloc),
          BlocProvider<CourseEnrollmentBloc>.value(value: _courseEnrollmentBloc),
          BlocProvider<FavoriteBloc>.value(value: _favoriteBloc),
          BlocProvider<RecommendationBloc>.value(value: _recommendationBloc),
          BlocProvider<TransformationJourneyBloc>.value(value: _transformationJourneyBloc),
          BlocProvider<FriendBloc>.value(value: _friendBloc),
          BlocProvider<FriendRequestBloc>.value(value: _friendRequestBloc),
          BlocProvider<ConfirmFriendBloc>.value(value: _confirmFriendBloc),
          BlocProvider<IgnoreFriendRequestBloc>.value(value: _ignoreFriendRequestBloc),
          BlocProvider<FavoriteFriendBloc>.value(value: _favoriteFriendBloc),
          BlocProvider<TaskSubmissionBloc>.value(value: _taskSubmissionBloc),
          BlocProvider<UserStatisticsBloc>.value(value: _userStatisticsBloc),
          BlocProvider<TaskBloc>.value(value: _taskBloc),
          BlocProvider<AssessmentBloc>.value(value: _assessmentBloc),
          BlocProvider<UserListBloc>.value(value: _userListBloc),
          BlocProvider<ProfileBloc>.value(value: _profileBloc),
          BlocProvider<StoryListBloc>.value(value: _storyListBloc),
          BlocProvider<CoachAssignmentBloc>.value(value: _coachAssignmentBloc),
          BlocProvider<CoachUserBloc>.value(value: _coachUserBloc),
          BlocProvider<CoachSentVideosBloc>.value(value: _coachSentVideosBloc),
          BlocProvider<CoachMentoredVideosBloc>.value(value: _coachMentoredVideosBloc),
          BlocProvider<CoachTimelineItemsBloc>.value(value: _coachTimelineItemsBloc),
          BlocProvider<HiFiveBloc>.value(value: _hiFiveBloc),
          BlocProvider<CourseCategoryBloc>.value(value: _courseCategoryBloc),
          BlocProvider<AssessmentAssignmentBloc>.value(value: _assessmentAssignmentBloc),
          BlocProvider<AssessmentVisibilityBloc>.value(value: _assessmentVisibilityBloc),
          BlocProvider<TaskSubmissionListBloc>.value(value: _taskSubmissionListBloc),
          BlocProvider<UpcomingChallengesBloc>.value(value: _upcomingChallengesBloc),
          BlocProvider<CourseEnrollmentListStreamBloc>.value(value: _courseEnrollmentListStreamBloc),
          BlocProvider<CourseEnrollmentListBloc>.value(value: _courseEnrollmentListBloc),
          BlocProvider<HiFiveSendBloc>.value(
            value: _hiFiveSendBloc,
          ),
          BlocProvider<CoachRequestBloc>.value(value: _coachRequestBloc),
          BlocProvider<CoachRequestStreamBloc>.value(value: _coachRequestStreamBloc),
          BlocProvider<CoachRecommendationsBloc>.value(value: _coachRecommendationsBloc),
          BlocProvider<CoachIntroductionVideoBloc>.value(value: _coachIntroductionVideo),
          BlocProvider<CoachReviewPendingBloc>.value(value: _coachReviewPendingBloc),
          BlocProvider<IntroductionMediaBloc>.value(value: _introductionMediaBloc),
          BlocProvider<CoachMediaBloc>.value(value: _coachMediaBloc),
          BlocProvider<GenericAudioPanelBloc>.value(value: _coachAudioPanelBloc),
          BlocProvider<CoachAudioMessageBloc>.value(value: _coachAudioMessageBloc),
          BlocProvider<ProjectConfigurationBloc>.value(value: _projectConfigurationBloc),
          BlocProvider<PushNotificationBloc>.value(value: _pushNotificationBloc),
          BlocProvider<NotificationSettingsBloc>.value(value: _notificationSettingsBloc),
          BlocProvider<CarouselBloc>.value(value: _carouselBloc),
          BlocProvider<InternetConnectionBloc>.value(value: _internetConnectionBloc),
          BlocProvider<ChallengeCompletedBeforeBloc>.value(value: _challengeCompletedBeforeBloc),
          BlocProvider<CourseUserIteractionBloc>.value(value: _courseInteractionBloc),
          BlocProvider<CourseRecommendedByFriendBloc>.value(value: _courseRecommendedByFriendBloc),
          BlocProvider<LikedCoursesBloc>.value(value: _courseLikedBloc),
          BlocProvider<CoachVideoMessageBloc>.value(value: _coachVideoMessageBloc),
          BlocProvider<UserPlanSubscriptionBloc>.value(value: _userPlanSubscriptionBloc),
          BlocProvider<UserBloc>.value(value: _userBloc),
          BlocProvider<SubscribedCourseUsersBloc>.value(value: _subscribedCourseUsersBloc),
          BlocProvider<CoursePanelBloc>.value(value: _coursePanelBloc),
          BlocProvider<GalleryVideoBloc>.value(value: _galleryVideoBloc),
          BlocProvider<ProfileAvatarBloc>.value(value: _profileAvatarBloc),
          BlocProvider<ProfileCoverImageBloc>.value(value: _profileCoverImageBloc),
          BlocProvider<ChatSliderMessagesBloc>.value(value: _chatSliderMessagesBloc),
          BlocProvider<WorkoutWeightBloc>.value(value: _workoutWeightBloc),
          BlocProvider<SegmentBloc>.value(value: _segmentBloc),
          BlocProvider<EnrollmentAudioBloc>.value(value: _enrollmentAudioBloc),
          BlocProvider<FriendsWeightRecordsBloc>.value(value: _friendsWeightRecordsBloc),
          BlocProvider<CommunityTabFriendNotificationBloc>.value(value: _communityTabFriendNotificationBloc),
          BlocProvider<ChatSliderBloc>.value(value: _chatSliderBloc),
          BlocProvider<CoachTimelineBloc>.value(value: _coachTimelineBloc),
          BlocProvider<CoachTabNotificationBloc>.value(value: _coachTabNotificationBloc),
        ];
        if (OlukoNeumorphism.isNeumorphismDesign) {
          providers.addAll([
            BlocProvider<MovementBloc>.value(value: _movementBloc),
            BlocProvider<ClassSubscriptionBloc>.value(value: _classSubscriptionBloc),
            BlocProvider<StatisticsSubscriptionBloc>.value(value: _statisticsSubscriptionBloc),
            BlocProvider<StoryBloc>.value(value: _storyBloc),
          ]);
        }

        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        newRouteView = MainPage(
          index: argumentsToAdd == null || argumentsToAdd['index'] == null ? null : argumentsToAdd['index'] as int,
          classIndex: argumentsToAdd == null || argumentsToAdd['classIndex'] == null ? null : argumentsToAdd['classIndex'] as int,
          tab: argumentsToAdd == null || argumentsToAdd['tab'] == null ? null : argumentsToAdd['tab'] as int,
        );

        break;
      case RouteEnum.introVideo:
        providers = [BlocProvider<IntroductionMediaBloc>.value(value: _introductionMediaBloc)];
        newRouteView = IntroductionVideo();
        break;
      case RouteEnum.signUp:
        providers = [BlocProvider<UserBloc>.value(value: _userBloc)];
        newRouteView = SignUpPage();
        break;
      case RouteEnum.loginNeumorphic:
        providers = [BlocProvider<UserBloc>.value(value: _userBloc), BlocProvider<InternetConnectionBloc>.value(value: _internetConnectionBloc)];
        final Map<String, bool> argumentsToAdd = arguments as Map<String, bool>;
        newRouteView = LoginNeumorphicPage(
            dontShowWelcomeTest: argumentsToAdd != null ? argumentsToAdd['dontShowWelcomeTest'] : null,
            userDeleted: argumentsToAdd != null && argumentsToAdd['userDeleted'] != null ? argumentsToAdd['userDeleted'] : false);
        break;
      case RouteEnum.completedClass:
        providers = [
          BlocProvider<CourseEnrollmentUpdateBloc>.value(value: _courseEnrollmentUpdateBloc),
          BlocProvider<TransformationJourneyBloc>.value(value: _transformationJourneyBloc),
          BlocProvider<DownloadAssetBloc>.value(value: _downloadAssetBloc),
        ];
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        newRouteView = CompletedClass(
            courseEnrollment: argumentsToAdd['courseEnrollment'] as CourseEnrollment,
            classIndex: argumentsToAdd['classIndex'] as int,
            courseIndex: argumentsToAdd['courseIndex'] as int,
            selfie: argumentsToAdd['selfie'] as XFile);
        break;
      case RouteEnum.story:
        providers = [
          BlocProvider<StoryBloc>.value(value: _storyBloc),
          BlocProvider<StoryListBloc>.value(value: _storyListBloc),
          BlocProvider<HiFiveSendBloc>.value(value: _hiFiveSendBloc),
          BlocProvider<CarouselBloc>.value(value: _carouselBloc)
        ];
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        newRouteView = StoryPage(
            stories: argumentsToAdd['stories'] as List<Story>,
            userId: argumentsToAdd['userId'] as String,
            name: argumentsToAdd['name'] as String,
            lastname: argumentsToAdd['lastname'] as String,
            avatarThumbnail: argumentsToAdd['avatarThumbnail'] as String,
            userStoriesId: argumentsToAdd['userStoriesId'] as String);
        break;
      case RouteEnum.signUpWithEmail:
        providers = [BlocProvider<UserBloc>.value(value: _userBloc)];
        newRouteView = SignUpWithMailPage();
        break;
      case RouteEnum.login:
        providers = [BlocProvider<UserBloc>.value(value: _userBloc)];
        newRouteView = LoginPage();
        break;
      case RouteEnum.friends:
        providers = [
          BlocProvider<PointsCardPanelBloc>.value(value: _pointsCardPanelBloc),
          BlocProvider<PointsCardBloc>.value(value: _pointsCardBloc),
          BlocProvider<UserProgressListBloc>.value(value: _userProgressListBloc),
          BlocProvider<UserProgressStreamBloc>.value(value: _userProgressStreamBloc),
          BlocProvider<FriendBloc>.value(value: _friendBloc),
          BlocProvider<FriendRequestBloc>.value(value: _friendRequestBloc),
          BlocProvider<UserListBloc>.value(value: _userListBloc),
          BlocProvider<TaskSubmissionBloc>.value(value: _taskSubmissionBloc),
          BlocProvider<TransformationJourneyBloc>.value(value: _transformationJourneyBloc),
          BlocProvider<CourseEnrollmentBloc>.value(value: _courseEnrollmentBloc),
          BlocProvider<ConfirmFriendBloc>.value(value: _confirmFriendBloc),
          BlocProvider<StoryListBloc>.value(value: _storyListBloc),
          BlocProvider<CourseEnrollmentListBloc>.value(value: _courseEnrollmentListBloc),
        ];
        newRouteView = FriendsPage();
        break;
      case RouteEnum.profile:
        providers = [
          BlocProvider<PointsCardBloc>.value(value: _pointsCardBloc),
          BlocProvider<PointsCardPanelBloc>.value(value: _pointsCardPanelBloc),
          BlocProvider<UserProgressStreamBloc>.value(value: _userProgressStreamBloc),
          BlocProvider<UserProgressListBloc>.value(value: _userProgressListBloc),
          BlocProvider<FriendRequestBloc>.value(value: _friendRequestBloc),
          BlocProvider<UserStatisticsBloc>.value(value: _userStatisticsBloc),
          BlocProvider<FriendRequestBloc>.value(value: _friendRequestBloc),
          BlocProvider<HiFiveReceivedBloc>.value(
            value: _hiFiveReceivedBloc,
          ),
          BlocProvider<CoachMediaBloc>.value(value: _coachMediaBloc),
        ];
        newRouteView = ProfilePage();
        break;
      case RouteEnum.profileSettings:
        providers = [
          BlocProvider<ProfileBloc>.value(value: _profileBloc),
          BlocProvider<NotificationSettingsBloc>.value(value: _notificationSettingsBloc),
        ];
        final Map<String, UserResponse> argumentsToAdd = arguments as Map<String, UserResponse>;
        newRouteView = ProfileSettingsPage(profileInfo: argumentsToAdd['profileInfo']);
        break;
      case RouteEnum.profileMyAccount:
        providers = [
          BlocProvider<HiFiveReceivedBloc>.value(
            value: _hiFiveReceivedBloc,
          ),
          BlocProvider<PointsCardPanelBloc>.value(value: _pointsCardPanelBloc),
          BlocProvider<PointsCardBloc>.value(value: _pointsCardBloc),
          BlocProvider<ProfileBloc>.value(value: _profileBloc),
          BlocProvider<PlanBloc>.value(value: _planBloc),
          BlocProvider<TransformationJourneyBloc>.value(value: _transformationJourneyBloc),
          BlocProvider<UserInformationBloc>.value(value: _userInformationBloc),
          BlocProvider<AuthBloc>.value(value: _authBloc),
          BlocProvider<CoachMentoredVideosBloc>.value(value: _coachMentoredVideosBloc),
          BlocProvider<CoachRecommendationsBloc>.value(value: _coachRecommendationsBloc),
          BlocProvider<CoachTimelineItemsBloc>.value(value: _coachTimelineItemsBloc),
          BlocProvider<StoryListBloc>.value(value: _storyListBloc),
          BlocProvider<CoachSentVideosBloc>.value(value: _coachSentVideosBloc),
          BlocProvider<CoachReviewPendingBloc>.value(value: _coachReviewPendingBloc),
          BlocProvider<CourseEnrollmentListStreamBloc>.value(value: _courseEnrollmentListStreamBloc),
          BlocProvider<ChallengeStreamBloc>.value(value: _challengeBloc),
          BlocProvider<CourseSubscriptionBloc>.value(value: _courseSubscriptionBloc),
          BlocProvider<CourseCategoryBloc>.value(value: _courseCategoryBloc),
          BlocProvider<CoachRequestStreamBloc>.value(value: _coachRequestStreamBloc),
          BlocProvider<NotificationBloc>.value(value: _notificationBloc),
          BlocProvider<CoachMediaBloc>.value(value: _coachMediaBloc),
          BlocProvider<CoachAudioMessageBloc>.value(value: _coachAudioMessageBloc),
          BlocProvider<ProjectConfigurationBloc>.value(value: _projectConfigurationBloc),
          BlocProvider<MyAccountBloc>.value(value: _myAccountBloc),
          BlocProvider<UserProgressStreamBloc>.value(value: _userProgressStreamBloc),
          BlocProvider<CoachVideoMessageBloc>.value(value: _coachVideoMessageBloc),
          BlocProvider<CourseRecommendedByFriendBloc>.value(value: _courseRecommendedByFriendBloc),
          BlocProvider<LikedCoursesBloc>.value(value: _courseLikedBloc),
          BlocProvider<CountryBloc>.value(value: _countryBloc),
          BlocProvider<CoachAssignmentBloc>.value(value: _coachAssignmentBloc)
        ];
        newRouteView = ProfileMyAccountPage();
        break;
      case RouteEnum.profileSubscription:
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        providers = [
          BlocProvider<PlanBloc>.value(value: _planBloc),
          BlocProvider<UserBloc>.value(value: _userBloc),
        ];
        newRouteView = ProfileSubscriptionPage(
            fromRegister: argumentsToAdd == null || argumentsToAdd['fromRegister'] == null ? true : argumentsToAdd['fromRegister'] as bool);
        break;
      case RouteEnum.profileHelpAndSupport:
        providers = [
          BlocProvider<FAQBloc>.value(value: _fAQBloc),
        ];
        newRouteView = ProfileHelpAndSupportPage();
        break;
      case RouteEnum.profileContactUs:
        providers = [
          BlocProvider<MailBloc>.value(value: _mailBloc),
        ];
        newRouteView = ProfileContacUsPage();
        break;
      case RouteEnum.profileViewOwnProfile:
        providers = [
          BlocProvider<PointsCardPanelBloc>.value(value: _pointsCardPanelBloc),
          BlocProvider<PointsCardBloc>.value(value: _pointsCardBloc),
          BlocProvider<UpcomingChallengesBloc>.value(value: _upcomingChallengesBloc),
          BlocProvider<CoursePanelBloc>.value(value: _coursePanelBloc),
          BlocProvider<UserProgressStreamBloc>.value(value: _userProgressStreamBloc),
          BlocProvider<UserProgressListBloc>.value(value: _userProgressListBloc),
          BlocProvider<FriendRequestBloc>.value(value: _friendRequestBloc),
          BlocProvider<CourseBloc>.value(value: _courseBloc),
          BlocProvider<FriendBloc>.value(value: _friendBloc),
          BlocProvider<OlukoPanelBloc>.value(value: OlukoPanelBloc()),
          BlocProvider<ProfileBloc>.value(value: _profileBloc),
          BlocProvider<AssessmentBloc>.value(value: _assessmentBloc),
          BlocProvider<TaskSubmissionBloc>.value(value: _taskSubmissionBloc),
          BlocProvider<ChallengeStreamBloc>.value(value: _challengeBloc),
          BlocProvider<CourseEnrollmentListBloc>.value(value: _courseEnrollmentListBloc),
          BlocProvider<CourseEnrollmentListStreamBloc>.value(value: _courseEnrollmentListStreamBloc),
          BlocProvider<TransformationJourneyBloc>.value(value: _transformationJourneyBloc),
          BlocProvider<ProfileCoverImageBloc>.value(value: _profileCoverImageBloc),
          BlocProvider<ProfileAvatarBloc>.value(value: _profileAvatarBloc),
          BlocProvider<UserStatisticsBloc>.value(value: _userStatisticsBloc),
          BlocProvider<FavoriteFriendBloc>.value(value: _favoriteFriendBloc),
          BlocProvider<GalleryVideoBloc>.value(value: _galleryVideoBloc),
          BlocProvider<FriendRequestBloc>.value(value: _friendRequestBloc),
          BlocProvider<ChatBloc>.value(
            value: _chatBloc,
          ),
          BlocProvider<MessageBloc>.value(
            value: _messageBloc,
          ),
          BlocProvider<HiFiveReceivedBloc>.value(
            value: _hiFiveReceivedBloc,
          ),
          BlocProvider<HiFiveSendBloc>.value(
            value: _hiFiveSendBloc,
          ),
          BlocProvider<ChallengeCompletedBeforeBloc>.value(value: _challengeCompletedBeforeBloc)
        ];
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        newRouteView = UserProfilePage(userRequested: argumentsToAdd['userRequested'] as UserResponse, isFriend: argumentsToAdd['isFriend'] as bool);
        break;
      case RouteEnum.profileChallenges:
        providers = [
          BlocProvider<UpcomingChallengesBloc>.value(value: _upcomingChallengesBloc),
          BlocProvider<CoursePanelBloc>.value(value: _coursePanelBloc),
          BlocProvider<ChallengeStreamBloc>.value(value: _challengeBloc),
          BlocProvider<ChallengeCompletedBeforeBloc>.value(value: _challengeCompletedBeforeBloc)
        ];
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        newRouteView = ProfileChallengesPage(
          challengesCardsState: argumentsToAdd['challengesCardsState'] as UniqueChallengesSuccess,
          isCurrentUser: argumentsToAdd == null || argumentsToAdd['isCurrentUser'] == null ? false : argumentsToAdd['isCurrentUser'] as bool,
          userRequested: argumentsToAdd['userRequested'] as UserResponse,
          isUpcomingChallenge: argumentsToAdd['isUpcomingChallenge'] != null ? argumentsToAdd['isUpcomingChallenge'] as bool : false,
          isCompletedChallenges: argumentsToAdd['isCompletedChallenges'] != null ? argumentsToAdd['isCompletedChallenges'] as bool : false,
        );
        break;
      case RouteEnum.profileTransformationJourney:
        providers = [
          BlocProvider<ProfileBloc>.value(value: _profileBloc),
          BlocProvider<OlukoPanelBloc>.value(value: _olukoPanelBloc),
          BlocProvider<CourseBloc>.value(value: _courseBloc),
          BlocProvider<AssessmentBloc>.value(value: _assessmentBloc),
          BlocProvider<TaskSubmissionBloc>.value(value: _taskSubmissionBloc),
          BlocProvider<CourseEnrollmentBloc>.value(value: _courseEnrollmentBloc),
          BlocProvider<TransformationJourneyBloc>.value(value: _transformationJourneyBloc),
          BlocProvider<TransformationJourneyContentBloc>.value(value: _transformationJourneyContentBloc),
          BlocProvider<GalleryVideoBloc>.value(value: _galleryVideoBloc),
        ];
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        newRouteView = ProfileTransformationJourneyPage(
          userRequested: argumentsToAdd['profileInfo'] as UserResponse,
          viewAllPage: argumentsToAdd['viewAllPage'] as bool,
        );
        break;
      case RouteEnum.profileAssessmentVideos:
        providers = [
          BlocProvider<ProfileBloc>.value(value: _profileBloc),
          BlocProvider<TaskSubmissionBloc>.value(value: _taskSubmissionBloc),
          BlocProvider<TransformationJourneyBloc>.value(value: _transformationJourneyBloc),
        ];
        final Map<String, UserResponse> argumentsToAdd = arguments as Map<String, UserResponse>;
        newRouteView = ProfileAssessmentVideosPage(userRequested: argumentsToAdd['profileInfo']);
        break;
      case RouteEnum.transformationJourneyPost:
        providers = [
          BlocProvider<TransformationJourneyBloc>.value(value: _transformationJourneyBloc),
        ];
        newRouteView = TransformationJourneyPostPage();
        break;
      case RouteEnum.transformationJourneyPostView:
        providers = [
          BlocProvider<TransformationJourneyBloc>.value(value: _transformationJourneyBloc),
        ];
        newRouteView = TransformationJourneyPostPage();
        break;
      case RouteEnum.transformationJournetContentDetails:
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        newRouteView = TransformationJourneyContentDetail(
            contentToShow: argumentsToAdd['TransformationJourneyUpload'] as TransformationJourneyUpload,
            coachMedia: argumentsToAdd['coachMedia'] as CoachMedia);
        break;
      case RouteEnum.logInUsername:
        newRouteView = LoginUsernamePage();
        break;
      case RouteEnum.logInPassword:
        providers = [BlocProvider<UserBloc>.value(value: _userBloc)];
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        newRouteView = LoginPasswordPage(requestData: argumentsToAdd['requestData'] as String);
        break;
      case RouteEnum.appPlans:
        newRouteView = AppPlans();
        break;
      case RouteEnum.segmentDetail:
        providers = [
          BlocProvider<UserProgressListBloc>.value(value: _userProgressListBloc),
          BlocProvider<UserProgressStreamBloc>.value(value: _userProgressStreamBloc),
          BlocProvider<CurrentTimeBloc>.value(value: _currentTimeBloc),
          BlocProvider<ClassBloc>.value(value: _classBloc),
          BlocProvider<CourseEnrollmentAudioBloc>.value(value: _courseEnrollmentAudioBloc),
          BlocProvider<ChallengeAudioBloc>.value(value: _challengeAudioBloc),
          BlocProvider<SegmentBloc>.value(value: _segmentBloc),
          BlocProvider<MovementBloc>.value(value: _movementBloc),
          BlocProvider<CoachRequestBloc>.value(value: _coachRequestBloc),
          BlocProvider<CoachRequestStreamBloc>.value(value: _coachRequestStreamBloc),
          BlocProvider<CoachUserBloc>.value(value: _coachUserBloc),
          BlocProvider<ChallengeSegmentBloc>.value(value: _challengeSegmentBloc),
          BlocProvider<SegmentDetailContentBloc>.value(value: _segmentDetailContentBloc),
          BlocProvider<DoneChallengeUsersBloc>.value(value: _doneChallengeUsersBloc),
          BlocProvider<PersonalRecordBloc>.value(value: _personalRecordBloc),
          BlocProvider<CoachAssignmentBloc>.value(value: _coachAssignmentBloc),
          BlocProvider<StoryListBloc>.value(value: _storyListBloc),
          BlocProvider<FriendBloc>.value(value: _friendBloc),
          BlocProvider<FriendRequestBloc>.value(value: _friendRequestBloc),
          BlocProvider<HiFiveSendBloc>.value(value: _hiFiveSendBloc),
          BlocProvider<HiFiveReceivedBloc>.value(value: _hiFiveReceivedBloc),
          BlocProvider<UserStatisticsBloc>.value(value: _userStatisticsBloc),
          BlocProvider<FavoriteFriendBloc>.value(value: _favoriteFriendBloc),
          BlocProvider<ChallengeCompletedBeforeBloc>.value(value: _challengeCompletedBeforeBloc),
          BlocProvider<VideoBloc>.value(value: _videoBloc),
          BlocProvider<WorkoutWeightBloc>.value(value: _workoutWeightBloc),
          BlocProvider<FriendsWeightRecordsBloc>.value(value: _friendsWeightRecordsBloc),
          BlocProvider<MaxWeightsBloc>.value(value: _maxWeightsBloc),
        ];
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        newRouteView = SegmentDetail(
            classSegments: argumentsToAdd['classSegments'] as List<Segment>,
            courseEnrollment: argumentsToAdd['courseEnrollment'] as CourseEnrollment,
            classIndex: argumentsToAdd['classIndex'] as int,
            segmentIndex: argumentsToAdd['segmentIndex'] as int,
            courseIndex: argumentsToAdd['courseIndex'] as int,
            fromChallenge: argumentsToAdd['fromChallenge'] as bool,
            actualCourse: argumentsToAdd['actualCourse'] as Course,
            favoriteUsers: argumentsToAdd['favoriteUsers'] as List<UserResponse>);
        break;
      case RouteEnum.movementIntro:
        providers = [BlocProvider<MovementInfoBloc>.value(value: _movementInfoBloc), BlocProvider<StoryListBloc>.value(value: _storyListBloc)];
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        newRouteView = MovementIntro(
          movement: argumentsToAdd['movement'] as Movement,
          movementSubmodel: argumentsToAdd['movementSubmodel'] as MovementSubmodel,
        );
        break;
      case RouteEnum.segmentClocks:
        providers = [
          BlocProvider<FriendBloc>.value(value: _friendBloc),
          BlocProvider<UserProgressBloc>.value(value: _userProgressBloc),
          BlocProvider<AmrapRoundBloc>.value(value: _amrapRoundBloc),
          BlocProvider<StopwatchBloc>.value(value: _stopwatchBloc),
          BlocProvider<PersonalRecordBloc>.value(value: _personalRecordBloc),
          BlocProvider<TimerTaskBloc>.value(value: _timerTaskBloc),
          BlocProvider<ClocksTimerBloc>.value(value: _clocksTimerBloc),
          BlocProvider<SegmentBloc>.value(value: _segmentBloc),
          BlocProvider<MovementBloc>.value(value: _movementBloc),
          BlocProvider<SegmentSubmissionBloc>.value(value: _segmentSubmissionBloc),
          BlocProvider<VideoBloc>.value(value: _videoBloc),
          BlocProvider<PointsCardBloc>.value(value: _pointsCardBloc),
          BlocProvider<CourseEnrollmentUpdateBloc>.value(value: _courseEnrollmentUpdateBloc),
          BlocProvider<StoryBloc>.value(value: _storyBloc),
          BlocProvider<CoachRequestBloc>.value(value: _coachRequestBloc),
          BlocProvider<CoachRequestStreamBloc>.value(value: _coachRequestStreamBloc),
          BlocProvider<StoryListBloc>.value(value: _storyListBloc),
          BlocProvider<ChallengeSegmentBloc>.value(value: _challengeSegmentBloc),
          BlocProvider<FeedbackBloc>.value(value: _feedbackBloc),
          BlocProvider<CurrentTimeBloc>.value(value: _currentTimeBloc),
          BlocProvider<NotificationSettingsBloc>.value(value: _notificationSettingsBloc),
          BlocProvider<WorkoutWeightBloc>.value(value: _workoutWeightBloc),
          BlocProvider<FriendsWeightRecordsBloc>.value(value: _friendsWeightRecordsBloc),
          BlocProvider<MaxWeightsBloc>.value(value: _maxWeightsBloc),
        ];
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        newRouteView = SegmentClocks(
          courseEnrollment: argumentsToAdd['courseEnrollment'] as CourseEnrollment,
          classIndex: argumentsToAdd['classIndex'] as int,
          courseIndex: argumentsToAdd['courseIndex'] as int,
          segmentIndex: argumentsToAdd['segmentIndex'] as int,
          coach: argumentsToAdd['coach'] as UserResponse,
          workoutType: argumentsToAdd['workoutType'] as WorkoutType,
          segments: argumentsToAdd['segments'] as List<Segment>,
          fromChallenge: argumentsToAdd['fromChallenge'] as bool,
          showPanel: argumentsToAdd['showPanel'] as bool,
          onShowAgainPressed: argumentsToAdd['onShowAgainPressed'] as Function(),
          coachRequest: argumentsToAdd['coachRequest'] as CoachRequest,
          currentTaskIndex: argumentsToAdd['currentTaskIndex'] as int,
        );
        break;
      case RouteEnum.segmentCameraPreview:
        providers = [
          BlocProvider<RecordingAlertBloc>.value(value: _recordingAlertBloc),
          BlocProvider<SegmentBloc>.value(value: _segmentBloc),
          BlocProvider<SegmentSubmissionBloc>.value(value: _segmentSubmissionBloc),
          BlocProvider<CourseEnrollmentBloc>.value(value: _courseEnrollmentBloc),
        ];
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        newRouteView = SegmentCameraPreview(
          courseEnrollment: argumentsToAdd['courseEnrollment'] as CourseEnrollment,
          classIndex: argumentsToAdd['classIndex'] as int,
          coach: argumentsToAdd['coach'] as UserResponse,
          segmentIndex: argumentsToAdd['segmentIndex'] as int,
          courseIndex: argumentsToAdd['courseIndex'] as int,
          segments: argumentsToAdd['segments'] as List<Segment>,
          currentTaskIndex: argumentsToAdd['currentTaskIndex'] as int,
        );
        break;
      case RouteEnum.courseMarketing:
        providers = [
          BlocProvider<ClassSubscriptionBloc>.value(value: _classSubscriptionBloc),
          BlocProvider<StatisticsSubscriptionBloc>.value(value: _statisticsSubscriptionBloc),
          BlocProvider<CourseEnrollmentBloc>.value(value: _courseEnrollmentBloc),
          BlocProvider<MovementBloc>.value(value: _movementBloc),
          BlocProvider<CourseEnrollmentListStreamBloc>.value(value: _courseEnrollmentListStreamBloc),
          BlocProvider<CourseHomeBloc>.value(value: _courseHomeBloc),
          BlocProvider<StoryListBloc>.value(value: _storyListBloc),
          BlocProvider<SubscribedCourseUsersBloc>.value(value: _subscribedCourseUsersBloc),
          BlocProvider<StoryListBloc>.value(value: _storyListBloc),
          BlocProvider<RecommendationBloc>.value(value: _recommendationBloc),
          BlocProvider<CoachAssignmentBloc>.value(value: _coachAssignmentBloc),
          BlocProvider<InsideClassContentBloc>.value(value: _insideClassContentBloc),
          BlocProvider<SegmentBloc>.value(value: _segmentBloc),
          BlocProvider<FriendBloc>.value(value: _friendBloc),
          BlocProvider<FriendRequestBloc>.value(value: _friendRequestBloc),
          BlocProvider<HiFiveSendBloc>.value(value: _hiFiveSendBloc),
          BlocProvider<HiFiveReceivedBloc>.value(value: _hiFiveReceivedBloc),
          BlocProvider<UserStatisticsBloc>.value(value: _userStatisticsBloc),
          BlocProvider<FavoriteFriendBloc>.value(value: _favoriteFriendBloc),
          BlocProvider<VideoBloc>.value(value: _videoBloc),
          BlocProvider<CourseUserIteractionBloc>.value(value: _courseInteractionBloc),
          BlocProvider<WorkoutWeightBloc>.value(value: _workoutWeightBloc),
          BlocProvider<FriendsWeightRecordsBloc>.value(value: _friendsWeightRecordsBloc),
          BlocProvider<MaxWeightsBloc>.value(value: _maxWeightsBloc),
        ];
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        newRouteView = CourseMarketing(
          course: argumentsToAdd['course'] as Course,
          fromCoach: argumentsToAdd['fromCoach'] as bool,
          isCoachRecommendation: argumentsToAdd['isCoachRecommendation'] as bool,
          courseEnrollment: argumentsToAdd['courseEnrollment'] as CourseEnrollment,
          courseIndex: argumentsToAdd['courseIndex'] as int,
        );
        break;
      case RouteEnum.enrolledCourse:
        providers = [
          BlocProvider<ClassSubscriptionBloc>.value(value: _classSubscriptionBloc),
          BlocProvider<StatisticsSubscriptionBloc>.value(value: _statisticsSubscriptionBloc),
          BlocProvider<CourseEnrollmentBloc>.value(value: _courseEnrollmentBloc),
          BlocProvider<MovementBloc>.value(value: _movementBloc),
          BlocProvider<CourseEnrollmentListBloc>.value(value: _courseEnrollmentListBloc),
          BlocProvider<SubscribedCourseUsersBloc>.value(value: _subscribedCourseUsersBloc),
          BlocProvider<RecommendationBloc>.value(value: _recommendationBloc),
          BlocProvider<VideoBloc>.value(value: _videoBloc),
          BlocProvider<CourseUserIteractionBloc>.value(value: _courseInteractionBloc),
          BlocProvider<WorkoutWeightBloc>.value(value: _workoutWeightBloc),
          BlocProvider<FriendsWeightRecordsBloc>.value(value: _friendsWeightRecordsBloc),
          BlocProvider<MaxWeightsBloc>.value(value: _maxWeightsBloc),
        ];
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        newRouteView = EnrolledCourse(
          course: argumentsToAdd['course'] as Course,
          fromCoach: argumentsToAdd['fromCoach'] as bool,
          isCoachRecommendation: argumentsToAdd['isCoachRecommendation'] as bool,
          courseEnrollment: argumentsToAdd['courseEnrollment'] as CourseEnrollment,
          courseIndex: argumentsToAdd['courseIndex'] as int,
        );
        break;
      case RouteEnum.enrolledClass:
        providers = [
          BlocProvider<ClassBloc>.value(value: _classBloc),
          BlocProvider<CourseEnrollmentBloc>.value(value: _courseEnrollmentBloc),
          BlocProvider<MovementBloc>.value(value: _movementBloc),
          BlocProvider<WorkoutWeightBloc>.value(value: _workoutWeightBloc),
          BlocProvider<FriendsWeightRecordsBloc>.value(value: _friendsWeightRecordsBloc),
          BlocProvider<MaxWeightsBloc>.value(value: _maxWeightsBloc),
        ];
        final Map<String, Course> argumentsToAdd = arguments as Map<String, Course>;
        newRouteView = EnrolledClass(course: argumentsToAdd['course']);
        break;
      case RouteEnum.insideClass:
        providers = [
          BlocProvider<UserProgressListBloc>.value(value: _userProgressListBloc),
          BlocProvider<UserProgressStreamBloc>.value(value: _userProgressStreamBloc),
          BlocProvider<ChallengeAudioBloc>.value(value: _challengeAudioBloc),
          BlocProvider<CourseEnrollmentAudioBloc>.value(value: _courseEnrollmentAudioBloc),
          BlocProvider<EnrollmentAudioBloc>.value(value: _enrollmentAudioBloc),
          BlocProvider<ClassBloc>.value(value: _classBloc),
          BlocProvider<SegmentBloc>.value(value: _segmentBloc),
          BlocProvider<MovementBloc>.value(value: _movementBloc),
          BlocProvider<CoachAudioBloc>.value(value: _coachAudioBloc),
          BlocProvider<CoachAssignmentBloc>.value(value: _coachAssignmentBloc),
          BlocProvider<StoryListBloc>.value(value: _storyListBloc),
          BlocProvider<SubscribedCourseUsersBloc>.value(value: _subscribedCourseUsersBloc),
          BlocProvider<InsideClassContentBloc>.value(value: _insideClassContentBloc),
          BlocProvider<DownloadAssetBloc>.value(value: _downloadAssetBloc),
          BlocProvider<FriendBloc>.value(value: _friendBloc),
          BlocProvider<FriendRequestBloc>.value(value: _friendRequestBloc),
          BlocProvider<HiFiveSendBloc>.value(value: _hiFiveSendBloc),
          BlocProvider<HiFiveReceivedBloc>.value(value: _hiFiveReceivedBloc),
          BlocProvider<UserStatisticsBloc>.value(value: _userStatisticsBloc),
          BlocProvider<FavoriteFriendBloc>.value(value: _favoriteFriendBloc),
          BlocProvider<ChallengeCompletedBeforeBloc>.value(value: _challengeCompletedBeforeBloc),
          BlocProvider<VideoBloc>.value(value: _videoBloc),
          BlocProvider<CourseHomeBloc>.value(value: _courseHomeBloc),
          BlocProvider<WorkoutWeightBloc>.value(value: _workoutWeightBloc),
          BlocProvider<FriendsWeightRecordsBloc>.value(value: _friendsWeightRecordsBloc),
          BlocProvider<StatisticsBloc>.value(value: _statisticsBloc),
          BlocProvider<MaxWeightsBloc>.value(value: _maxWeightsBloc),
        ];
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        newRouteView = InsideClass(
          courseEnrollment: argumentsToAdd['courseEnrollment'] as CourseEnrollment,
          classIndex: argumentsToAdd['classIndex'] as int,
          courseIndex: argumentsToAdd['courseIndex'] as int,
          actualCourse: argumentsToAdd['actualCourse'] as Course,
        );
        break;
      case RouteEnum.userChallengeDetail:
        providers = [
          BlocProvider<UserProgressListBloc>.value(value: _userProgressListBloc),
          BlocProvider<UserProgressStreamBloc>.value(value: _userProgressStreamBloc),
          BlocProvider<PanelAudioBloc>.value(value: _panelAudioBloc),
          BlocProvider<ClassBloc>.value(value: _classBloc),
          BlocProvider<SegmentBloc>.value(value: _segmentBloc),
          BlocProvider<CourseEnrollmentBloc>.value(value: _courseEnrollmentBloc),
          BlocProvider<AudioBloc>.value(value: _audioBloc),
          BlocProvider<DoneChallengeUsersBloc>.value(value: _doneChallengeUsersBloc),
          BlocProvider<SegmentDetailContentBloc>.value(value: _segmentDetailContentBloc),
          BlocProvider<PersonalRecordBloc>.value(value: _personalRecordBloc),
          BlocProvider<SubscribedCourseUsersBloc>.value(value: _subscribedCourseUsersBloc),
          BlocProvider<DoneChallengeUsersBloc>.value(value: _doneChallengeUsersBloc),
          BlocProvider<FriendBloc>.value(value: _friendBloc),
          BlocProvider<FriendRequestBloc>.value(value: _friendRequestBloc),
          BlocProvider<HiFiveSendBloc>.value(value: _hiFiveSendBloc),
          BlocProvider<HiFiveReceivedBloc>.value(value: _hiFiveReceivedBloc),
          BlocProvider<UserStatisticsBloc>.value(value: _userStatisticsBloc),
          BlocProvider<FavoriteFriendBloc>.value(value: _favoriteFriendBloc),
          BlocProvider<ChallengeCompletedBeforeBloc>.value(value: _challengeCompletedBeforeBloc),
          BlocProvider<WorkoutWeightBloc>.value(value: _workoutWeightBloc),
          BlocProvider<FriendsWeightRecordsBloc>.value(value: _friendsWeightRecordsBloc),
        ];
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        newRouteView = UserChallengeDetail(
          challenge: argumentsToAdd['challenge'] as Challenge,
          userRequested: argumentsToAdd['userRequested'] as UserResponse,
        );
        break;
      case RouteEnum.assessmentVideos:
        providers = [
          BlocProvider<GalleryVideoBloc>.value(value: _galleryVideoBloc),
          BlocProvider<TaskCardBloc>.value(value: _taskCardBloc),
          BlocProvider<TaskSubmissionListBloc>.value(value: _taskSubmissionListBloc),
          BlocProvider<TaskSubmissionBloc>.value(value: _taskSubmissionBloc),
          BlocProvider<AssessmentAssignmentBloc>.value(value: _assessmentAssignmentBloc),
          BlocProvider<AssessmentVisibilityBloc>.value(value: _assessmentVisibilityBloc),
          BlocProvider<AssessmentBloc>.value(value: _assessmentBloc),
          BlocProvider<TaskBloc>.value(value: _taskBloc),
          BlocProvider<SubscribedCourseUsersBloc>.value(value: _subscribedCourseUsersBloc)
        ];
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        newRouteView = AssessmentVideos(
          isFirstTime: argumentsToAdd == null || argumentsToAdd['isFirstTime'] == null ? true : argumentsToAdd['isFirstTime'] as bool,
          assessmentsDone: argumentsToAdd == null || argumentsToAdd['assessmentsDone'] == null ? false : argumentsToAdd['assessmentsDone'] as bool,
        );
        break;
      case RouteEnum.taskDetails:
        providers = [
          BlocProvider<TaskCardBloc>.value(value: _taskCardBloc),
          BlocProvider<AssessmentAssignmentBloc>.value(value: _assessmentAssignmentBloc),
          BlocProvider<AssessmentVisibilityBloc>.value(value: _assessmentVisibilityBloc),
          BlocProvider<TaskSubmissionBloc>.value(value: _taskSubmissionBloc),
          BlocProvider<TaskBloc>.value(value: _taskBloc),
          BlocProvider<GalleryVideoBloc>.value(value: _galleryVideoBloc),
          BlocProvider<WorkoutWeightBloc>.value(value: _workoutWeightBloc),
          BlocProvider<FriendsWeightRecordsBloc>.value(value: _friendsWeightRecordsBloc),
        ];
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        newRouteView = TaskDetails(
            taskIndex: argumentsToAdd['taskIndex'] as int,
            isLastTask: argumentsToAdd['isLastTask'] as bool,
            taskCompleted: argumentsToAdd['taskCompleted'] as bool);
        break;
      case RouteEnum.selfRecording:
        //TODO: Pass flag for last assessments

        providers = [
          BlocProvider<TaskBloc>.value(value: _taskBloc),
          BlocProvider<GalleryVideoBloc>.value(value: _galleryVideoBloc),
          BlocProvider<CourseEnrollmentUpdateBloc>.value(value: _courseEnrollmentUpdateBloc),
        ];
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        newRouteView = SelfRecording(
          taskId: argumentsToAdd['taskId'] as String,
          taskIndex: argumentsToAdd['taskIndex'] as int,
          isPublic: argumentsToAdd['isPublic'] as bool,
          isLastTask: argumentsToAdd['isLastTask'] as bool,
          fromCompletedClass: argumentsToAdd['fromCompletedClass'] as bool,
          courseEnrollment: argumentsToAdd['courseEnrollment'] as CourseEnrollment,
          classIndex: argumentsToAdd['classIndex'] as int,
          courseIndex: argumentsToAdd['courseIndex'] as int,
        );
        break;
      case RouteEnum.selfRecordingPreview:
        //TODO: Pass flag for last assessments

        providers = [
          BlocProvider<TaskSubmissionListBloc>.value(value: _taskSubmissionListBloc),
          BlocProvider<TaskCardBloc>.value(value: _taskCardBloc),
          BlocProvider<AssessmentAssignmentBloc>.value(value: _assessmentAssignmentBloc),
          BlocProvider<TaskSubmissionBloc>.value(value: _taskSubmissionBloc),
          BlocProvider<TaskBloc>.value(value: _taskBloc),
          BlocProvider<VideoBloc>.value(value: _videoBloc),
          BlocProvider<AssessmentBloc>.value(value: _assessmentBloc),
          BlocProvider<TaskSubmissionListBloc>.value(value: _taskSubmissionListBloc),
        ];
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        newRouteView = SelfRecordingPreview(
          taskId: argumentsToAdd['taskId'] as String,
          filePath: argumentsToAdd['filePath'].toString(),
          taskIndex: argumentsToAdd['taskIndex'] as int,
          isPublic: argumentsToAdd['isPublic'] as bool,
          isLastTask: argumentsToAdd['isLastTask'] as bool,
        );
        break;
      case RouteEnum.taskSubmissionVideo:
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        newRouteView = TaskSubmissionRecordedVideo(
          videoUrl: argumentsToAdd['videoUrl'].toString(),
          task: argumentsToAdd['task'] as Task,
        );
        break;
      case RouteEnum.taskSubmissionReviewPreview:
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        providers = [
          BlocProvider<TaskReviewBloc>.value(value: _taskReviewBloc),
          BlocProvider<VideoBloc>.value(value: _videoBloc),
        ];
        newRouteView = TaskSubmissionReviewPreview(
          taskSubmission: argumentsToAdd['taskSubmission'] as TaskSubmission,
          filePath: argumentsToAdd['filePath'].toString(),
          videoEvents: argumentsToAdd['videoEvents'] as List<Event>,
        );
        break;
      case RouteEnum.choosePlanPayment:
        newRouteView = ChoosePlayPayments();
        break;
      case RouteEnum.courses:
        providers = [
          BlocProvider<RemainSelectedTagsBloc>.value(value: _remainSelectedTagsBloc),
          BlocProvider<SelectedTagsBloc>.value(value: _selectedTagsBloc),
          BlocProvider<CoachAssignmentBloc>.value(value: _coachAssignmentBloc),
          BlocProvider<FavoriteBloc>.value(value: _favoriteBloc),
          BlocProvider<CourseBloc>.value(value: _courseBloc),
          BlocProvider<CourseCategoryBloc>.value(value: _courseCategoryBloc),
          BlocProvider<CourseEnrollmentBloc>.value(value: _courseEnrollmentBloc),
          BlocProvider<TagBloc>.value(value: _tagBloc),
          BlocProvider<RecommendationBloc>.value(value: _recommendationBloc),
          BlocProvider<CourseEnrollmentListStreamBloc>.value(value: _courseEnrollmentListStreamBloc),
          BlocProvider<CourseSubscriptionBloc>.value(value: _courseSubscriptionBloc),
          BlocProvider<CourseUserIteractionBloc>.value(value: _courseInteractionBloc),
          BlocProvider<CourseRecommendedByFriendBloc>.value(value: _courseRecommendedByFriendBloc),
          BlocProvider<LikedCoursesBloc>.value(value: _courseLikedBloc),
        ];
        final Map<String, dynamic> args = arguments as Map<String, dynamic>;
        newRouteView = Courses(
            homeEnrollTocourse: args['homeEnrollTocourse'] as bool,
            showBottomTab: args['showBottomTab'] as Function(),
            firstTimeEnroll: args['firstTimeEnroll'] as bool,
            backButtonWithFilters: args['backButtonWithFilters'] as bool);
        break;

      case RouteEnum.viewAll:
        Map<String, dynamic> args = arguments as Map<String, dynamic>;
        List<Course> courses = args['courses'] as List<Course>;
        String title = args['title'].toString();
        providers = [
          BlocProvider<FavoriteBloc>.value(value: _favoriteBloc),
          BlocProvider<CourseBloc>.value(value: _courseBloc),
          BlocProvider<TagBloc>.value(value: _tagBloc),
        ];
        newRouteView = ViewAll(
          courses: courses,
          title: title,
        );
        break;
      //TODO: obsolete - first version of drawings and pointers
      // case RouteEnum.videos:
      //   newRouteView = VideosHome(
      //     title: "Videos",
      //     parentVideoInfo: null,
      //     parentVideoReference: FirebaseFirestore.instance.collection("videosInfo"),
      //   );
      //   break;
      case RouteEnum.exploreSubscribedUsers:
        Map<String, dynamic> args = arguments as Map<String, dynamic>;
        String courseId = args['courseId'].toString();
        providers = [
          BlocProvider<UserProgressListBloc>.value(value: _userProgressListBloc),
          BlocProvider<UserProgressStreamBloc>.value(value: _userProgressStreamBloc),
          BlocProvider<SubscribedCourseUsersBloc>.value(value: _subscribedCourseUsersBloc),
          BlocProvider<StoryListBloc>.value(value: _storyListBloc),
          BlocProvider<FriendBloc>.value(value: _friendBloc),
          BlocProvider<FriendRequestBloc>.value(value: _friendRequestBloc),
          BlocProvider<HiFiveSendBloc>.value(value: _hiFiveSendBloc),
          BlocProvider<HiFiveReceivedBloc>.value(value: _hiFiveReceivedBloc),
          BlocProvider<UserStatisticsBloc>.value(value: _userStatisticsBloc),
          BlocProvider<FavoriteFriendBloc>.value(value: _favoriteFriendBloc),
        ];
        newRouteView = ExploreSubscribedUsers(courseId: courseId);
        break;
      case RouteEnum.coach:
        providers = [
          BlocProvider<TaskCardBloc>.value(value: _taskCardBloc),
          BlocProvider<CoachIntroductionVideoBloc>.value(value: _coachIntroductionVideo),
          BlocProvider<CoachReviewPendingBloc>.value(value: _coachReviewPendingBloc),
          BlocProvider<ProfileBloc>.value(value: _profileBloc),
          BlocProvider<TaskSubmissionBloc>.value(value: _taskSubmissionBloc),
          BlocProvider<TransformationJourneyBloc>.value(value: _transformationJourneyBloc),
          BlocProvider<CourseEnrollmentListStreamBloc>.value(value: _courseEnrollmentListStreamBloc),
          BlocProvider<TaskBloc>.value(value: _taskBloc),
          BlocProvider<AssessmentBloc>.value(value: _assessmentBloc),
          BlocProvider<UserStatisticsBloc>.value(value: _userStatisticsBloc),
          BlocProvider<CourseEnrollmentBloc>.value(value: _courseEnrollmentBloc),
          BlocProvider<CoachAssignmentBloc>.value(value: _coachAssignmentBloc),
          BlocProvider<CoachUserBloc>.value(value: _coachUserBloc),
          BlocProvider<CoachSentVideosBloc>.value(value: _coachSentVideosBloc),
          BlocProvider<CoachMentoredVideosBloc>.value(value: _coachMentoredVideosBloc),
          BlocProvider<CoachTimelineItemsBloc>.value(value: _coachTimelineItemsBloc),
          BlocProvider<CoachRequestBloc>.value(value: _coachRequestBloc),
          BlocProvider<CoachRequestStreamBloc>.value(value: _coachRequestStreamBloc),
          BlocProvider<CoachRecommendationsBloc>.value(value: _coachRecommendationsBloc),
          BlocProvider<ChallengeCompletedBeforeBloc>.value(value: _challengeCompletedBeforeBloc),
          BlocProvider<IntroductionMediaBloc>.value(value: _introductionMediaBloc),
          BlocProvider<CoachVideoMessageBloc>.value(value: _coachVideoMessageBloc),
          BlocProvider<FriendBloc>.value(value: _friendBloc),
          BlocProvider<CoachTimelineBloc>.value(value: _coachTimelineBloc),
        ];
        newRouteView = CoachMainPage();
        break;
      case RouteEnum.coach2:
        providers = [
          BlocProvider<TaskCardBloc>.value(value: _taskCardBloc),
          BlocProvider<CoachIntroductionVideoBloc>.value(value: _coachIntroductionVideo),
          BlocProvider<CoachReviewPendingBloc>.value(value: _coachReviewPendingBloc),
          BlocProvider<ProfileBloc>.value(value: _profileBloc),
          BlocProvider<TaskSubmissionBloc>.value(value: _taskSubmissionBloc),
          BlocProvider<TransformationJourneyBloc>.value(value: _transformationJourneyBloc),
          BlocProvider<CourseEnrollmentListStreamBloc>.value(value: _courseEnrollmentListStreamBloc),
          BlocProvider<TaskBloc>.value(value: _taskBloc),
          BlocProvider<AssessmentBloc>.value(value: _assessmentBloc),
          BlocProvider<UserStatisticsBloc>.value(value: _userStatisticsBloc),
          BlocProvider<CoachAssignmentBloc>.value(value: _coachAssignmentBloc),
          BlocProvider<CoachUserBloc>.value(value: _coachUserBloc),
          BlocProvider<CoachSentVideosBloc>.value(value: _coachSentVideosBloc),
          BlocProvider<CoachMentoredVideosBloc>.value(value: _coachMentoredVideosBloc),
          BlocProvider<CoachTimelineItemsBloc>.value(value: _coachTimelineItemsBloc),
          BlocProvider<CoachRequestBloc>.value(value: _coachRequestBloc),
          BlocProvider<CoachRequestStreamBloc>.value(value: _coachRequestStreamBloc),
          BlocProvider<ChallengeStreamBloc>.value(value: _challengeBloc),
          BlocProvider<CoachRecommendationsBloc>.value(value: _coachRecommendationsBloc),
          BlocProvider<CoachTimelineBloc>.value(value: _coachTimelineBloc),
          BlocProvider<ChallengeCompletedBeforeBloc>.value(value: _challengeCompletedBeforeBloc),
          BlocProvider<CoachVideoMessageBloc>.value(value: _coachVideoMessageBloc),
          BlocProvider<FriendBloc>.value(value: _friendBloc),
          BlocProvider<IntroductionMediaBloc>.value(value: _introductionMediaBloc),
        ];
        newRouteView = CoachPage();
        break;
      case RouteEnum.sentVideos:
        providers = [
          BlocProvider<CoachSentVideosBloc>.value(value: _coachSentVideosBloc),
        ];
        final Map<String, List<SegmentSubmission>> argumentsToAdd = arguments as Map<String, List<SegmentSubmission>>;
        newRouteView = SentVideosPage(segmentSubmissions: argumentsToAdd['sentVideosContent']);
        break;
      case RouteEnum.mentoredVideos:
        providers = [
          BlocProvider<CoachMentoredVideosBloc>.value(value: _coachMentoredVideosBloc),
          BlocProvider<CoachVideoMessageBloc>.value(value: _coachVideoMessageBloc),
        ];
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        newRouteView = MentoredVideosPage(
            coachAnnotation: argumentsToAdd['coachAnnotation'] as List<Annotation>,
            coachVideoMessage: argumentsToAdd['coachVideoMessages'] as List<CoachMediaMessage>);
        break;
      case RouteEnum.coachShowVideo:
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;

        newRouteView = CoachShowVideo(
          videoUrl: argumentsToAdd['videoUrl'].toString(),
          titleForContent: argumentsToAdd['titleForContent'].toString(),
          aspectRatio: argumentsToAdd['aspectRatio'] != null ? double.parse(argumentsToAdd['aspectRatio'].toString()) : null,
        );
        break;
      case RouteEnum.coachProfile:
        providers = [
          BlocProvider<CoachMediaBloc>.value(value: _coachMediaBloc),
          BlocProvider<GenericAudioPanelBloc>.value(value: _coachAudioPanelBloc),
          BlocProvider<CoachAudioMessageBloc>.value(value: _coachAudioMessageBloc),
          BlocProvider<VideoBloc>.value(value: _videoBloc),
          BlocProvider<CoachAssignmentBloc>.value(value: _coachAssignmentBloc),
          BlocProvider<CoachUserBloc>.value(value: _coachUserBloc),
        ];
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        newRouteView = CoachProfile(coachUser: argumentsToAdd['coachUser'] as CoachUser, currentUser: argumentsToAdd['currentUser'] as UserResponse);
        break;
      case RouteEnum.hiFivePage:
        providers = [
          BlocProvider<UserProgressListBloc>.value(value: _userProgressListBloc),
          BlocProvider<UserProgressStreamBloc>.value(value: _userProgressStreamBloc),
          BlocProvider<HiFiveBloc>.value(value: _hiFiveBloc),
          BlocProvider<StoryListBloc>.value(value: _storyListBloc),
          BlocProvider<CarouselBloc>.value(value: _carouselBloc),
        ];
        newRouteView = const HiFivePage();
        break;
      case RouteEnum.homeLongPress:
        providers = [
          BlocProvider<UserProgressListBloc>.value(value: _userProgressListBloc),
          BlocProvider<UserProgressStreamBloc>.value(value: _userProgressStreamBloc),
          BlocProvider<SubscribedCourseUsersBloc>.value(value: _subscribedCourseUsersBloc),
          BlocProvider<CourseEnrollmentListBloc>.value(value: _courseEnrollmentListBloc),
          BlocProvider<FriendBloc>.value(value: _friendBloc),
          BlocProvider<FriendRequestBloc>.value(value: _friendRequestBloc),
          BlocProvider<HiFiveSendBloc>.value(value: _hiFiveSendBloc),
          BlocProvider<HiFiveReceivedBloc>.value(value: _hiFiveReceivedBloc),
          BlocProvider<UserStatisticsBloc>.value(value: _userStatisticsBloc),
          BlocProvider<FavoriteFriendBloc>.value(value: _favoriteFriendBloc),
        ];
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        newRouteView = HomeLongPress(
          argumentsToAdd['currentUser'] as UserResponse,
          argumentsToAdd['courseEnrollments'] as List<CourseEnrollment>,
          argumentsToAdd['index'] != null ? argumentsToAdd['index'] as int : 0,
        );
        break;
      case RouteEnum.assessmentNeumorphicDone:
        newRouteView = const AssessmentNeumorphicDoneScreen();
        break;
      case RouteEnum.coachRecommendedContentGallery:
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        newRouteView = CoachRecommendedContentList(
          recommendedVideoContent: argumentsToAdd['recommendedVideoContent'] as List<RecommendationMedia>,
          recommendedContent: argumentsToAdd['recommendedContent'] as List<CoachRecommendationDefault>,
          titleForAppBar: argumentsToAdd['titleForAppBar'] as String,
        );
        break;
      case RouteEnum.aboutCoach:
        providers = [
          BlocProvider<CoachMediaBloc>.value(value: _coachMediaBloc),
        ];
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        newRouteView = AboutCoachPage(coachBannerVideo: argumentsToAdd['coachBannerVideo'] as String);
        break;
      case RouteEnum.noInternetConnection:
        newRouteView = const OlukoNoInternetConnectionPage();
        break;
      case RouteEnum.courseShareView:
        providers = [
          BlocProvider<StoryListBloc>.value(value: _storyListBloc),
          BlocProvider<UserProgressListBloc>.value(value: _userProgressListBloc),
          BlocProvider<FriendBloc>.value(value: _friendBloc),
          BlocProvider<FriendRequestBloc>.value(value: _friendRequestBloc),
          BlocProvider<HiFiveSendBloc>.value(value: _hiFiveSendBloc),
          BlocProvider<HiFiveReceivedBloc>.value(value: _hiFiveReceivedBloc),
          BlocProvider<UserStatisticsBloc>.value(value: _userStatisticsBloc),
          BlocProvider<FavoriteFriendBloc>.value(value: _favoriteFriendBloc),
          BlocProvider<UserProgressStreamBloc>.value(value: _userProgressStreamBloc),
          BlocProvider<CourseUserIteractionBloc>.value(value: _courseInteractionBloc),
        ];
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        newRouteView = CourseShareView(
          currentUser: argumentsToAdd['currentUser'] as UserResponse,
          courseToShare: argumentsToAdd['courseToShare'] as Course,
        );
        break;
      case RouteEnum.registerUser:
        providers = [
          BlocProvider<CountryBloc>.value(value: _countryBloc),
          BlocProvider<SignupBloc>.value(value: _signUpBloc),
          BlocProvider<AuthBloc>.value(value: _authBloc),
        ];
        newRouteView = const RegisterPage();
        break;
      case RouteEnum.homeLatestDesign:
        providers = [
          BlocProvider<PointsCardPanelBloc>.value(value: _pointsCardPanelBloc),
          BlocProvider<PointsCardBloc>.value(value: _pointsCardBloc),
          BlocProvider<UsersSelfiesBloc>.value(value: _usersSelfiesBloc),
          BlocProvider<TransformationJourneyBloc>.value(value: _transformationJourneyBloc),
          BlocProvider<SubscribedCourseUsersBloc>.value(value: _subscribedCourseUsersBloc),
          BlocProvider<UpcomingChallengesBloc>.value(value: _upcomingChallengesBloc),
          BlocProvider<CourseEnrollmentListStreamBloc>.value(value: _courseEnrollmentListStreamBloc),
          BlocProvider<CourseEnrollmentListBloc>.value(value: _courseEnrollmentListBloc),
          BlocProvider<AuthBloc>.value(value: _authBloc),
          BlocProvider<CoursePanelBloc>.value(value: _coursePanelBloc),
          BlocProvider<GalleryVideoBloc>.value(value: _galleryVideoBloc),
          BlocProvider<ProfileAvatarBloc>.value(value: _profileAvatarBloc),
          BlocProvider<ProfileCoverImageBloc>.value(value: _profileCoverImageBloc),
          BlocProvider<CourseRecommendedByFriendBloc>.value(value: _courseRecommendedByFriendBloc),
          BlocProvider<LikedCoursesBloc>.value(value: _courseLikedBloc),
          BlocProvider<StoryBloc>.value(value: _storyBloc),
          BlocProvider<TaskSubmissionBloc>.value(value: _taskSubmissionBloc),
          BlocProvider<ProfileBloc>.value(value: _profileBloc),
          BlocProvider<UserStatisticsBloc>.value(value: _userStatisticsBloc),
          BlocProvider<UserProgressListBloc>.value(value: _userProgressListBloc),
          BlocProvider<HiFiveReceivedBloc>.value(
            value: _hiFiveReceivedBloc,
          ),
          BlocProvider<SegmentBloc>.value(value: _segmentBloc),
          BlocProvider<EnrollmentAudioBloc>.value(value: _enrollmentAudioBloc),
          BlocProvider<UserProgressStreamBloc>.value(value: _userProgressStreamBloc),
          BlocProvider<CourseSubscriptionBloc>.value(value: _courseSubscriptionBloc),
          BlocProvider<ChallengeStreamBloc>.value(value: _challengeBloc),
          BlocProvider<CourseUserIteractionBloc>.value(value: _courseInteractionBloc),
          BlocProvider<WorkoutWeightBloc>.value(value: _workoutWeightBloc),
        ];
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        newRouteView = HomeNeumorphicLatestDesign(
          currentUser: argumentsToAdd['currentUser'] as UserResponse,
          courseEnrollments: argumentsToAdd['courseEnrollments'] as List<CourseEnrollment>,
          authState: argumentsToAdd['authState'] as AuthSuccess,
        );
        break;
      case RouteEnum.courseHomePage:
        providers = [
          BlocProvider<UsersSelfiesBloc>.value(value: _usersSelfiesBloc),
          BlocProvider<VideoBloc>.value(value: _videoBloc),
          BlocProvider<CourseHomeBloc>.value(value: _courseHomeBloc),
          BlocProvider<StoryBloc>.value(value: _storyBloc),
          BlocProvider<ClassSubscriptionBloc>.value(value: _classSubscriptionBloc),
          BlocProvider<CarouselBloc>.value(value: _carouselBloc),
          BlocProvider<SubscribedCourseUsersBloc>.value(value: _subscribedCourseUsersBloc),
          BlocProvider<AuthBloc>.value(value: _authBloc),
          BlocProvider<CourseEnrollmentBloc>.value(value: _courseEnrollmentBloc),
          BlocProvider<StoryListBloc>.value(value: _storyListBloc),
        ];
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        newRouteView = HomeNeumorphicContent(
          courseEnrollments: argumentsToAdd['courseEnrollments'] as List<CourseEnrollment>,
          authState: argumentsToAdd['authState'] as AuthSuccess,
          courses: argumentsToAdd['courses'] as List<Course>,
          user: argumentsToAdd['user'] as UserResponse,
          index: argumentsToAdd['index'] as int,
          isFromHome: argumentsToAdd['isFromHome'] as bool,
          openEditScheduleOnInit: argumentsToAdd['openEditScheduleOnInit'] as bool,
        );
        break;
      case RouteEnum.welcomeVideoFirstTimeLogin:
        providers = [
          BlocProvider<UsersSelfiesBloc>.value(value: _usersSelfiesBloc),
          BlocProvider<TransformationJourneyBloc>.value(value: _transformationJourneyBloc),
          BlocProvider<SubscribedCourseUsersBloc>.value(value: _subscribedCourseUsersBloc),
          BlocProvider<UpcomingChallengesBloc>.value(value: _upcomingChallengesBloc),
          BlocProvider<CourseEnrollmentListStreamBloc>.value(value: _courseEnrollmentListStreamBloc),
          BlocProvider<CourseEnrollmentListBloc>.value(value: _courseEnrollmentListBloc),
          BlocProvider<AuthBloc>.value(value: _authBloc),
          BlocProvider<CoursePanelBloc>.value(value: _coursePanelBloc),
          BlocProvider<GalleryVideoBloc>.value(value: _galleryVideoBloc),
          BlocProvider<ProfileAvatarBloc>.value(value: _profileAvatarBloc),
          BlocProvider<ProfileCoverImageBloc>.value(value: _profileCoverImageBloc),
          BlocProvider<UsersSelfiesBloc>.value(value: _usersSelfiesBloc),
          BlocProvider<TagBloc>.value(value: _tagBloc),
          BlocProvider<StoryBloc>.value(value: _storyBloc),
          BlocProvider<CourseRecommendedByFriendBloc>.value(value: _courseRecommendedByFriendBloc),
          BlocProvider<LikedCoursesBloc>.value(value: _courseLikedBloc),
          BlocProvider<TaskSubmissionBloc>.value(value: _taskSubmissionBloc),
          BlocProvider<ProfileBloc>.value(value: _profileBloc),
          BlocProvider<UserStatisticsBloc>.value(value: _userStatisticsBloc),
          BlocProvider<UserProgressListBloc>.value(value: _userProgressListBloc),
          BlocProvider<HiFiveReceivedBloc>.value(
            value: _hiFiveReceivedBloc,
          ),
          BlocProvider<ChallengeStreamBloc>.value(value: _challengeBloc),
          BlocProvider<CourseSubscriptionBloc>.value(value: _courseSubscriptionBloc),
          BlocProvider<UserProgressStreamBloc>.value(value: _userProgressStreamBloc),
        ];
        newRouteView = const WelcomeVideoFirstTimeLogin();
        break;

      case RouteEnum.courseChat:
        providers = [
          BlocProvider<CourseEnrollmentChatBloc>.value(value: _courseEnrollmentChatBloc),
          BlocProvider<FriendBloc>.value(value: _friendBloc),
          BlocProvider<FriendRequestBloc>.value(value: _friendRequestBloc),
          BlocProvider<HiFiveSendBloc>.value(value: _hiFiveSendBloc),
          BlocProvider<HiFiveReceivedBloc>.value(value: _hiFiveReceivedBloc),
          BlocProvider<UserStatisticsBloc>.value(value: _userStatisticsBloc),
          BlocProvider<FavoriteFriendBloc>.value(value: _favoriteFriendBloc),
          BlocProvider<UserProgressStreamBloc>.value(value: _userProgressStreamBloc),
          BlocProvider<ChatSliderMessagesBloc>.value(value: _chatSliderMessagesBloc),
          BlocProvider<GenericAudioPanelBloc>.value(value: _coachAudioPanelBloc),
          BlocProvider<PanelAudioBloc>.value(value: _panelAudioBloc),
          BlocProvider<ChatSliderBloc>.value(value: _chatSliderBloc),
        ];
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        newRouteView = Chat(
            courseEnrollment: argumentsToAdd['courseEnrollment'] as CourseEnrollment,
            currentUser: argumentsToAdd['currentUser'] as UserResponse,
            enrollments: argumentsToAdd['enrollments'] as List<CourseEnrollment>);
        break;
      case RouteEnum.maxWeights:
        providers = [
          BlocProvider<MaxWeightsBloc>.value(value: _maxWeightsBloc),
        ];
        final Map<String, dynamic> argumentsToAdd = arguments as Map<String, dynamic>;
        newRouteView = ProfileMaxWeightsPage(user: argumentsToAdd['user'] as UserResponse);
        break;
      default:
        newRouteView = MainPage();
        break;
    }

    //Merge common providers & route-specific ones into one List
    final List<BlocProvider> selectedProviders = providers..addAll(commonProviders);

    //Generate route with selected BLoCs
    return MaterialPageRoute(
        settings: RouteSettings(name: route),
        builder: (c) => MultiBlocProvider(
            providers: selectedProviders,
            child: Builder(builder: (context) {
              return newRouteView;
            })));
  }
}
