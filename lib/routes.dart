import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/assessment_assignment_bloc.dart';
import 'package:oluko_app/blocs/assessment_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_update_bloc.dart';
import 'package:oluko_app/blocs/gallery_video_bloc.dart';
import 'package:oluko_app/blocs/movement_submission_bloc.dart';
import 'package:oluko_app/blocs/segment_submission_bloc.dart';
import 'package:oluko_app/blocs/subscribed_course_users_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_list_bloc.dart';
import 'package:oluko_app/blocs/class_bloc.dart';
import 'package:oluko_app/blocs/course_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/favorite_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/blocs/friends/ignore_friend_request_bloc.dart';
import 'package:oluko_app/blocs/movement_bloc.dart';
import 'package:oluko_app/blocs/plan_bloc.dart';
import 'package:oluko_app/blocs/profile/profile_bloc.dart';
import 'package:oluko_app/blocs/recommendation_bloc.dart';
import 'package:oluko_app/blocs/segment_bloc.dart';
import 'package:oluko_app/blocs/statistics_bloc.dart';
import 'package:oluko_app/blocs/tag_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_bloc.dart';
import 'package:oluko_app/blocs/transformation_journey_bloc.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/blocs/video_bloc.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/screens/app_plans.dart';
import 'package:oluko_app/ui/screens/assessments/assessment_videos.dart';
import 'package:oluko_app/ui/screens/assessments/self_recording.dart';
import 'package:oluko_app/ui/screens/assessments/self_recording_preview.dart';
import 'package:oluko_app/ui/screens/assessments/task_submission_recorded_video.dart';
import 'package:oluko_app/ui/screens/choose_plan_payment.dart';
import 'package:oluko_app/ui/screens/coach/coach_no_assigned_timer_page.dart';
import 'package:oluko_app/ui/screens/coach/coach_page.dart';
import 'package:oluko_app/ui/screens/coach/coach_profile.dart';
import 'package:oluko_app/ui/screens/coach/coach_show_video.dart';
import 'package:oluko_app/ui/screens/coach/mentored_videos.dart';
import 'package:oluko_app/ui/screens/coach/sent_videos.dart';
import 'package:oluko_app/ui/screens/courses/course_marketing.dart';
import 'package:oluko_app/ui/screens/courses/courses.dart';
import 'package:oluko_app/ui/screens/courses/enrolled_class.dart';
import 'package:oluko_app/ui/screens/courses/explore_subscribed_users.dart';
import 'package:oluko_app/ui/screens/courses/inside_class.dart';
import 'package:oluko_app/ui/screens/courses/segment_camera_preview.dart.dart';
import 'package:oluko_app/ui/screens/friends/friends_page.dart';
import 'package:oluko_app/ui/screens/authentication/login.dart';
import 'package:oluko_app/ui/screens/main_page.dart';
import 'package:oluko_app/ui/screens/courses/movement_intro.dart';
import 'package:oluko_app/ui/screens/profile/profile.dart';
import 'package:oluko_app/ui/screens/profile/profile_assessment_videos_page.dart';
import 'package:oluko_app/ui/screens/profile/profile_challenges_page.dart';
import 'package:oluko_app/ui/screens/profile/profile_help_and_support_contact_us.dart';
import 'package:oluko_app/ui/screens/profile/profile_help_and_support_page.dart';
import 'package:oluko_app/ui/screens/profile/profile_my_account_page.dart';
import 'package:oluko_app/ui/screens/profile/transformation_journey_content_detail.dart';
import 'package:oluko_app/ui/screens/profile/user_profile_page.dart';
import 'package:oluko_app/ui/screens/profile/profile_settings_page.dart';
import 'package:oluko_app/ui/screens/profile/profile_subscription_page.dart';
import 'package:oluko_app/ui/screens/profile/profile_transformation_journey_page.dart';
import 'package:oluko_app/ui/screens/profile/transformation_journey_post.dart';
import 'package:oluko_app/ui/screens/courses/segment_detail.dart';
import 'blocs/movement_info_bloc.dart';
import 'ui/screens/courses/segment_clocks.dart';
import 'package:oluko_app/ui/screens/authentication/sign_up.dart';
import 'package:oluko_app/ui/screens/authentication/sign_up_with_email.dart';
import 'package:oluko_app/ui/screens/assessments/task_details.dart';
import 'package:oluko_app/ui/screens/videos/videos_home.dart';
import 'package:oluko_app/ui/screens/view_all.dart';
import 'blocs/friends/confirm_friend_bloc.dart';
import 'blocs/oluko_panel_bloc.dart';
import 'blocs/profile/upload_avatar_bloc.dart';
import 'blocs/profile/upload_cover_image_bloc.dart';
import 'blocs/profile/upload_transformation_journey_content_bloc.dart';
import 'blocs/friends/favorite_friend_bloc.dart';
import 'blocs/user_statistics_bloc.dart';
import 'models/course.dart';
import 'models/transformation_journey_uploads.dart';

enum RouteEnum {
  root,
  signUp,
  signUpWithEmail,
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
  logIn,
  appPlans,
  segmentDetail,
  movementIntro,
  segmentClocks,
  courseMarketing,
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
  exploreSubscribedUsers,
  segmentCameraPreview,
  coach,
  coach2,
  sentVideos,
  mentoredVideos,
  coachShowVideo,
  coachProfile
}

Map<RouteEnum, String> routeLabels = {
  RouteEnum.root: '/',
  RouteEnum.signUp: '/sign-up',
  RouteEnum.signUpWithEmail: '/sign-up-with-email',
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
  RouteEnum.transformationJournetContentDetails:
      '/transformation-journey-content-details',
  RouteEnum.transformationJourneyPostView: '/transformation-journey-post-view',
  RouteEnum.logIn: '/log-in',
  RouteEnum.appPlans: '/app-plans',
  RouteEnum.segmentDetail: '/segment-detail',
  RouteEnum.movementIntro: '/movement-intro',
  RouteEnum.segmentClocks: '/segment-clocks',
  RouteEnum.courseMarketing: '/course-marketing',
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
  RouteEnum.exploreSubscribedUsers: '/explore-subscribed-users',
  RouteEnum.segmentCameraPreview: '/segment-camera-preview',
  RouteEnum.coach: '/coach',
  RouteEnum.coach2: '/coach2',
  RouteEnum.sentVideos: '/coach-sent-videos',
  RouteEnum.mentoredVideos: '/coach-mentored-videos',
  RouteEnum.coachShowVideo: '/coach-show-video',
  RouteEnum.coachProfile: '/coach-profile'
};

RouteEnum getEnumFromRouteString(String route) {
  final routeIndex = routeLabels.values.toList().indexOf(route);
  return routeIndex != -1 ? routeLabels.keys.toList()[routeIndex] : null;
}

class Routes {
  final OlukoPanelBloc _olukoPanelBloc = OlukoPanelBloc();
  final AuthBloc _authBloc = AuthBloc();
  final ProfileBloc _profileBloc = ProfileBloc();
  final CourseBloc _courseBloc = CourseBloc();
  final TagBloc _tagBloc = TagBloc();
  final FriendBloc _friendBloc = FriendBloc();
  final ConfirmFriendBloc _confirmFriendBloc = ConfirmFriendBloc();
  final IgnoreFriendRequestBloc _ignoreFriendRequestBloc =
      IgnoreFriendRequestBloc();
  final FavoriteFriendBloc _favoriteFriendBloc = FavoriteFriendBloc();
  final AssessmentBloc _assessmentBloc = AssessmentBloc();
  final AssessmentAssignmentBloc _assessmentAssignmentBloc =
      AssessmentAssignmentBloc();
  final TaskSubmissionBloc _taskSubmissionBloc = TaskSubmissionBloc();
  final CourseEnrollmentBloc _courseEnrollmentBloc = CourseEnrollmentBloc();
  final TransformationJourneyBloc _transformationJourneyBloc =
      TransformationJourneyBloc();
  final ClassBloc _classBloc = ClassBloc();
  final SubscribedCourseUsersBloc _subscribedCourseUsersBloc =
      SubscribedCourseUsersBloc();
  final StatisticsBloc _statisticsBloc = StatisticsBloc();
  final MovementBloc _movementBloc = MovementBloc();
  final MovementInfoBloc _movementInfoBloc = MovementInfoBloc();
  final SegmentBloc _segmentBloc = SegmentBloc();
  final TaskBloc _taskBloc = TaskBloc();
  final VideoBloc _videoBloc = VideoBloc();
  final FavoriteBloc _favoriteBloc = FavoriteBloc();
  final RecommendationBloc _recommendationBloc = RecommendationBloc();
  final PlanBloc _planBloc = PlanBloc();
  final TaskSubmissionListBloc _taskSubmissionListBloc =
      TaskSubmissionListBloc();
  final GalleryVideoBloc _galleryVideoBloc = GalleryVideoBloc();
  final CourseEnrollmentListBloc _courseEnrollmentListBloc =
      CourseEnrollmentListBloc();
  final MovementSubmissionBloc _movementSubmissionBloc =
      MovementSubmissionBloc();
  final SegmentSubmissionBloc _segmentSubmissionBloc = SegmentSubmissionBloc();
  final TransformationJourneyContentBloc _transformationJourneyContentBloc =
      TransformationJourneyContentBloc();
  final ProfileAvatarBloc _profileAvatarBloc = ProfileAvatarBloc();
  final ProfileCoverImageBloc _profileCoverImageBloc = ProfileCoverImageBloc();
  final UserStatisticsBloc _userStatisticsBloc = UserStatisticsBloc();
  final CourseEnrollmentUpdateBloc _courseEnrollmentUpdateBloc =
      CourseEnrollmentUpdateBloc();

  getRouteView(String route, Object arguments) {
    //View for the new route.
    Widget newRouteView;
    //Providers used for the new route.
    List<BlocProvider> providers = [];
    //Providers used across the whole app.
    List<BlocProvider> commonProviders = [
      BlocProvider<AuthBloc>.value(value: _authBloc)
    ];

    final RouteEnum routeEnum = getEnumFromRouteString(route);
    switch (routeEnum) {
      case RouteEnum.root:
        providers = [
          BlocProvider<CourseBloc>.value(value: _courseBloc),
          BlocProvider<ClassBloc>.value(value: _classBloc),
          BlocProvider<CourseEnrollmentListBloc>.value(
              value: _courseEnrollmentListBloc),
          BlocProvider<TagBloc>.value(value: _tagBloc),
          BlocProvider<CourseEnrollmentBloc>.value(
              value: _courseEnrollmentBloc),
          BlocProvider<FavoriteBloc>.value(value: _favoriteBloc),
          BlocProvider<RecommendationBloc>.value(value: _recommendationBloc),
          BlocProvider<TransformationJourneyBloc>.value(
              value: _transformationJourneyBloc),
          BlocProvider<FriendBloc>.value(value: _friendBloc),
          BlocProvider<ConfirmFriendBloc>.value(value: _confirmFriendBloc),
          BlocProvider<IgnoreFriendRequestBloc>.value(
              value: _ignoreFriendRequestBloc),
          BlocProvider<FavoriteFriendBloc>.value(value: _favoriteFriendBloc),
          BlocProvider<TaskSubmissionBloc>.value(value: _taskSubmissionBloc),
          BlocProvider<UserStatisticsBloc>.value(value: _userStatisticsBloc),
          BlocProvider<TaskBloc>.value(value: _taskBloc),
          BlocProvider<AssessmentBloc>.value(value: _assessmentBloc),
          BlocProvider<ProfileBloc>.value(value: _profileBloc),
        ];
        newRouteView = MainPage();
        break;
      case RouteEnum.signUp:
        newRouteView = SignUpPage();
        break;
      case RouteEnum.signUpWithEmail:
        newRouteView = SignUpWithMailPage();
        break;
      case RouteEnum.friends:
        providers = [
          BlocProvider<FriendBloc>.value(value: _friendBloc),
          BlocProvider<ConfirmFriendBloc>.value(value: _confirmFriendBloc)
        ];
        newRouteView = FriendsPage();
        break;
      case RouteEnum.profile:
        providers = [
          BlocProvider<UserStatisticsBloc>.value(value: _userStatisticsBloc),
        ];
        newRouteView = ProfilePage();
        break;
      case RouteEnum.profileSettings:
        providers = [
          BlocProvider<ProfileBloc>.value(value: _profileBloc),
        ];
        final Map<String, UserResponse> argumentsToAdd = arguments;
        newRouteView =
            ProfileSettingsPage(profileInfo: argumentsToAdd['profileInfo']);
        break;
      case RouteEnum.profileMyAccount:
        providers = [
          BlocProvider<ProfileBloc>.value(value: _profileBloc),
          BlocProvider<PlanBloc>.value(value: _planBloc),
          BlocProvider<TransformationJourneyBloc>.value(
              value: _transformationJourneyBloc)
        ];
        newRouteView = ProfileMyAccountPage();
        break;
      case RouteEnum.profileSubscription:
        newRouteView = ProfileSubscriptionPage();
        break;
      case RouteEnum.profileHelpAndSupport:
        newRouteView = ProfileHelpAndSupportPage();
        break;
      case RouteEnum.profileContactUs:
        newRouteView = ProfileContacUsPage();
        break;
      case RouteEnum.profileViewOwnProfile:
        providers = [
          BlocProvider<CourseBloc>.value(value: _courseBloc),
          BlocProvider<FriendBloc>.value(value: _friendBloc),
          BlocProvider<OlukoPanelBloc>.value(value: OlukoPanelBloc()),
          BlocProvider<ProfileBloc>.value(value: _profileBloc),
          BlocProvider<AssessmentBloc>.value(value: _assessmentBloc),
          BlocProvider<TaskSubmissionBloc>.value(value: _taskSubmissionBloc),
          BlocProvider<CourseEnrollmentBloc>.value(
              value: _courseEnrollmentBloc),
          BlocProvider<CourseEnrollmentListBloc>.value(
              value: _courseEnrollmentListBloc),
          BlocProvider<TransformationJourneyBloc>.value(
              value: _transformationJourneyBloc),
          BlocProvider<ProfileCoverImageBloc>.value(
              value: _profileCoverImageBloc),
          BlocProvider<ProfileAvatarBloc>.value(value: _profileAvatarBloc),
          BlocProvider<UserStatisticsBloc>.value(value: _userStatisticsBloc),
        ];
        final Map<String, UserResponse> argumentsToAdd = arguments;
        newRouteView =
            UserProfilePage(userRequested: argumentsToAdd['userRequested']);
        break;
      case RouteEnum.profileChallenges:
        providers = [
          BlocProvider<CourseEnrollmentBloc>.value(value: _courseEnrollmentBloc)
        ];
        newRouteView = ProfileChallengesPage();
        break;
      case RouteEnum.profileTransformationJourney:
        providers = [
          BlocProvider<ProfileBloc>.value(value: _profileBloc),
          BlocProvider<OlukoPanelBloc>.value(value: _olukoPanelBloc),
          BlocProvider<CourseBloc>.value(value: _courseBloc),
          BlocProvider<AssessmentBloc>.value(value: _assessmentBloc),
          BlocProvider<TaskSubmissionBloc>.value(value: _taskSubmissionBloc),
          BlocProvider<CourseEnrollmentBloc>.value(
              value: _courseEnrollmentBloc),
          BlocProvider<TransformationJourneyBloc>.value(
              value: _transformationJourneyBloc),
          BlocProvider<TransformationJourneyContentBloc>.value(
              value: _transformationJourneyContentBloc),
        ];
        newRouteView = ProfileTransformationJourneyPage();
        break;
      case RouteEnum.profileAssessmentVideos:
        providers = [
          BlocProvider<ProfileBloc>.value(value: _profileBloc),
          BlocProvider<TaskSubmissionBloc>.value(value: _taskSubmissionBloc),
          BlocProvider<TransformationJourneyBloc>.value(
              value: _transformationJourneyBloc),
        ];
        newRouteView = ProfileAssessmentVideosPage();
        break;
      case RouteEnum.transformationJourneyPost:
        providers = [
          BlocProvider<TransformationJourneyBloc>.value(
              value: _transformationJourneyBloc),
        ];
        newRouteView = TransformationJourneyPostPage();
        break;
      case RouteEnum.transformationJourneyPostView:
        providers = [
          BlocProvider<TransformationJourneyBloc>.value(
              value: _transformationJourneyBloc),
        ];
        newRouteView = TransformationJourneyPostPage();
        break;
      case RouteEnum.transformationJournetContentDetails:
        final Map<String, TransformationJourneyUpload> argumentsToAdd =
            arguments;
        newRouteView = TransformationJourneyContentDetail(
            contentToShow: argumentsToAdd['TransformationJourneyUpload']);
        break;
      case RouteEnum.logIn:
        newRouteView = LoginPage();
        break;
      case RouteEnum.appPlans:
        newRouteView = AppPlans();
        break;
      case RouteEnum.segmentDetail:
        providers = [
          BlocProvider<SegmentBloc>.value(value: _segmentBloc),
          BlocProvider<MovementBloc>.value(value: _movementBloc),
        ];
        final Map<String, dynamic> argumentsToAdd = arguments;
        newRouteView = SegmentDetail(
            courseEnrollment: argumentsToAdd['courseEnrollment'],
            classIndex: argumentsToAdd['classIndex'],
            segmentIndex: argumentsToAdd['segmentIndex']);
        break;
      case RouteEnum.movementIntro:
        providers = [
          BlocProvider<MovementInfoBloc>.value(value: _movementInfoBloc)
        ];
        final Map<String, Movement> argumentsToAdd = arguments;
        newRouteView = MovementIntro(
          movement: argumentsToAdd['movement'],
        );
        break;
      case RouteEnum.segmentClocks:
        providers = [
          BlocProvider<SegmentBloc>.value(value: _segmentBloc),
          BlocProvider<MovementBloc>.value(value: _movementBloc),
          BlocProvider<SegmentSubmissionBloc>.value(
              value: _segmentSubmissionBloc),
          BlocProvider<MovementSubmissionBloc>.value(
              value: _movementSubmissionBloc),
          BlocProvider<VideoBloc>.value(value: _videoBloc),
          BlocProvider<CourseEnrollmentBloc>.value(
              value: _courseEnrollmentBloc),
          BlocProvider<CourseEnrollmentUpdateBloc>.value(
              value: _courseEnrollmentUpdateBloc)
        ];
        final Map<String, dynamic> argumentsToAdd = arguments;
        newRouteView = SegmentClocks(
            courseEnrollment: argumentsToAdd['courseEnrollment'],
            classIndex: argumentsToAdd['classIndex'],
            segmentIndex: argumentsToAdd['segmentIndex'],
            workoutType: argumentsToAdd['workoutType'],
            segments: argumentsToAdd['segments']);
        break;
      case RouteEnum.segmentCameraPreview:
        providers = [
          BlocProvider<SegmentBloc>.value(value: _segmentBloc),
          BlocProvider<SegmentSubmissionBloc>.value(
              value: _segmentSubmissionBloc),
          BlocProvider<MovementSubmissionBloc>.value(
              value: _movementSubmissionBloc),
          BlocProvider<CourseEnrollmentBloc>.value(value: _courseEnrollmentBloc)
        ];
        final Map<String, dynamic> argumentsToAdd = arguments;
        newRouteView = SegmentCameraPreview(
            courseEnrollment: argumentsToAdd['courseEnrollment'],
            classIndex: argumentsToAdd['classIndex'],
            segmentIndex: argumentsToAdd['segmentIndex'],
            segments: argumentsToAdd['segments']);
        break;
      case RouteEnum.courseMarketing:
        providers = [
          BlocProvider<ClassBloc>.value(value: _classBloc),
          BlocProvider<StatisticsBloc>.value(value: _statisticsBloc),
          BlocProvider<CourseEnrollmentBloc>.value(
              value: _courseEnrollmentBloc),
          BlocProvider<MovementBloc>.value(value: _movementBloc),
          BlocProvider<CourseEnrollmentListBloc>.value(
              value: _courseEnrollmentListBloc),
          BlocProvider<SubscribedCourseUsersBloc>.value(
              value: _subscribedCourseUsersBloc)
        ];
        final Map<String, Course> argumentsToAdd = arguments;
        newRouteView = CourseMarketing(course: argumentsToAdd['course']);
        break;
      case RouteEnum.enrolledClass:
        providers = [
          BlocProvider<ClassBloc>.value(value: _classBloc),
          BlocProvider<CourseEnrollmentBloc>.value(
              value: _courseEnrollmentBloc),
          BlocProvider<MovementBloc>.value(value: _movementBloc),
        ];
        final Map<String, Course> argumentsToAdd = arguments;
        newRouteView = EnrolledClass(course: argumentsToAdd['course']);
        break;
      case RouteEnum.insideClass:
        providers = [
          BlocProvider<ClassBloc>.value(value: _classBloc),
          BlocProvider<SegmentBloc>.value(value: _segmentBloc),
          BlocProvider<MovementBloc>.value(value: _movementBloc),
        ];
        final Map<String, dynamic> argumentsToAdd = arguments;
        newRouteView = InsideClass(
            courseEnrollment: argumentsToAdd['courseEnrollment'],
            classIndex: argumentsToAdd['classIndex']);
        break;
      case RouteEnum.assessmentVideos:
        providers = [
          BlocProvider<TaskSubmissionListBloc>.value(
              value: _taskSubmissionListBloc),
          BlocProvider<AssessmentAssignmentBloc>.value(
              value: _assessmentAssignmentBloc),
          BlocProvider<AssessmentBloc>.value(value: _assessmentBloc),
          BlocProvider<TaskBloc>.value(value: _taskBloc),
        ];
        newRouteView = AssessmentVideos();
        break;
      case RouteEnum.taskDetails:
        providers = [
          BlocProvider<AssessmentAssignmentBloc>.value(
              value: _assessmentAssignmentBloc),
          BlocProvider<TaskSubmissionBloc>.value(value: _taskSubmissionBloc),
          BlocProvider<TaskBloc>.value(value: _taskBloc),
        ];
        final Map<String, num> argumentsToAdd = arguments;
        newRouteView = TaskDetails(
          taskIndex: argumentsToAdd['taskIndex'],
        );
        break;
      case RouteEnum.selfRecording:
        providers = [
          BlocProvider<TaskBloc>.value(value: _taskBloc),
          BlocProvider<GalleryVideoBloc>.value(value: _galleryVideoBloc),
        ];
        final Map<String, dynamic> argumentsToAdd = arguments;
        newRouteView = SelfRecording(
          taskIndex: argumentsToAdd['taskIndex'],
          isPublic: argumentsToAdd['isPublic'],
        );
        break;
      case RouteEnum.selfRecordingPreview:
        providers = [
          BlocProvider<AssessmentAssignmentBloc>.value(
              value: _assessmentAssignmentBloc),
          BlocProvider<TaskSubmissionBloc>.value(value: _taskSubmissionBloc),
          BlocProvider<TaskBloc>.value(value: _taskBloc),
          BlocProvider<VideoBloc>.value(value: _videoBloc),
          BlocProvider<AssessmentBloc>.value(value: _assessmentBloc),
          BlocProvider<TaskSubmissionListBloc>.value(
              value: _taskSubmissionListBloc),
        ];
        final Map<String, dynamic> argumentsToAdd = arguments;
        newRouteView = SelfRecordingPreview(
          filePath: argumentsToAdd['filePath'],
          taskIndex: argumentsToAdd['taskIndex'],
          isPublic: argumentsToAdd['isPublic'],
        );
        break;
      case RouteEnum.taskSubmissionVideo:
        final Map<String, dynamic> argumentsToAdd = arguments;
        newRouteView = TaskSubmissionRecordedVideo(
          videoUrl: argumentsToAdd['videoUrl'],
          task: argumentsToAdd['task'],
        );
        break;
      case RouteEnum.choosePlanPayment:
        newRouteView = ChoosePlayPayments();
        break;
      case RouteEnum.courses:
        providers = [
          BlocProvider<FavoriteBloc>.value(value: _favoriteBloc),
          BlocProvider<CourseBloc>.value(value: _courseBloc),
          BlocProvider<CourseEnrollmentBloc>.value(
              value: _courseEnrollmentBloc),
          BlocProvider<TagBloc>.value(value: _tagBloc),
          BlocProvider<RecommendationBloc>.value(value: _recommendationBloc),
        ];
        newRouteView = Courses();
        break;
      case RouteEnum.viewAll:
        Map<String, dynamic> args = arguments;
        List<Course> courses = args['courses'];
        String title = args['title'];
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
      case RouteEnum.videos:
        newRouteView = VideosHome(
          title: "Videos",
          parentVideoInfo: null,
          parentVideoReference:
              FirebaseFirestore.instance.collection("videosInfo"),
        );
        break;
      case RouteEnum.exploreSubscribedUsers:
        Map<String, dynamic> args = arguments;
        String courseId = args['courseId'];
        providers = [
          BlocProvider<SubscribedCourseUsersBloc>.value(
              value: _subscribedCourseUsersBloc)
        ];
        newRouteView = ExploreSubscribedUsers(courseId: courseId);
        break;
      case RouteEnum.coach:
        providers = [
          BlocProvider<ProfileBloc>.value(value: _profileBloc),
          BlocProvider<TaskSubmissionBloc>.value(value: _taskSubmissionBloc),
          BlocProvider<TransformationJourneyBloc>.value(
              value: _transformationJourneyBloc),
          BlocProvider<CourseEnrollmentListBloc>.value(
              value: _courseEnrollmentListBloc),
          BlocProvider<TaskBloc>.value(value: _taskBloc),
          BlocProvider<AssessmentBloc>.value(value: _assessmentBloc),
          BlocProvider<UserStatisticsBloc>.value(value: _userStatisticsBloc),
          BlocProvider<CourseEnrollmentBloc>.value(
              value: _courseEnrollmentBloc),
        ];
        newRouteView = CoachAssignedCountDown();
        break;
      case RouteEnum.coach2:
        providers = [
          BlocProvider<ProfileBloc>.value(value: _profileBloc),
          BlocProvider<TaskSubmissionBloc>.value(value: _taskSubmissionBloc),
          BlocProvider<TransformationJourneyBloc>.value(
              value: _transformationJourneyBloc),
          BlocProvider<CourseEnrollmentListBloc>.value(
              value: _courseEnrollmentListBloc),
          BlocProvider<TaskBloc>.value(value: _taskBloc),
          BlocProvider<AssessmentBloc>.value(value: _assessmentBloc),
          BlocProvider<UserStatisticsBloc>.value(value: _userStatisticsBloc),
          BlocProvider<CourseEnrollmentBloc>.value(
              value: _courseEnrollmentBloc),
        ];
        newRouteView = CoachPage();
        break;
      case RouteEnum.sentVideos:
        final Map<String, List<TaskSubmission>> argumentsToAdd = arguments;
        newRouteView =
            SentVideosPage(taskSubmissions: argumentsToAdd['taskSubmissions']);
        break;
      case RouteEnum.mentoredVideos:
        final Map<String, List<TaskSubmission>> argumentsToAdd = arguments;
        newRouteView = MentoredVideosPage(
            taskSubmissions: argumentsToAdd['taskSubmissions']);
        break;
      case RouteEnum.coachShowVideo:
        final Map<String, dynamic> argumentsToAdd = arguments;

        newRouteView = CoachShowVideo(
          videoUrl: argumentsToAdd['videoUrl'],
          titleForContent: argumentsToAdd['titleForView'],
        );
        break;
      case RouteEnum.coachProfile:
        final Map<String, UserResponse> argumentsToAdd = arguments;
        newRouteView = CoachProfile(coachUser: argumentsToAdd['coachUser']);
        break;
      default:
        newRouteView = MainPage();
        break;
    }

    //Merge common providers & route-specific ones into one List
    List<BlocProvider> selectedProviders = providers..addAll(commonProviders);

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
