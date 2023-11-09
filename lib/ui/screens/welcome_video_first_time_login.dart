import 'package:chewie/chewie.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_stream_bloc.dart';
import 'package:oluko_app/blocs/introduction_media_bloc.dart';
import 'package:oluko_app/blocs/users_selfies_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/selfies_grid.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_custom_video_player.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class WelcomeVideoFirstTimeLogin extends StatefulWidget {
  final Function(bool) videoSeen;
  const WelcomeVideoFirstTimeLogin({this.videoSeen}) : super();

  @override
  State<WelcomeVideoFirstTimeLogin> createState() => _WelcomeVideoFirstTimeLoginState();
}

class _WelcomeVideoFirstTimeLoginState extends State<WelcomeVideoFirstTimeLogin> {
  bool isVideoVisible = false;
  String mediaURL;
  bool _isVideoPlaying = false;
  bool _isBottomTabActive = true;
  ChewieController _controller;
  UserResponse _currentUser;
  AuthSuccess _authState;
  List<CourseEnrollment> _courseEnrollments;

  @override
  void initState() {
    BlocProvider.of<UsersSelfiesBloc>(context).get();

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthSuccess) {
          _authState = authState;
          _currentUser = authState.user;
          BlocProvider.of<CourseEnrollmentListStreamBloc>(context).getStream(_currentUser.id);
        }

        return BlocBuilder<CourseEnrollmentListStreamBloc, CourseEnrollmentListStreamState>(
          builder: (context, state) {
            if (state is CourseEnrollmentsByUserStreamSuccess) {
              _courseEnrollments = state.courseEnrollments;
            }
            return Scaffold(
              appBar: OlukoAppBar(
                showLogo: true,
                showBackButton: false,
                reduceHeight: true,
              ),
              body: Container(
                height: ScreenUtils.height(context),
                width: ScreenUtils.width(context),
                child: ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    if (isVideoVisible)
                      Container(
                        width: ScreenUtils.width(context),
                        color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: isVideoVisible ? 0 : 16),
                          child:
                              //  Stack(
                              //   children: [
                              showVideoPlayer(mediaURL, false),
                          //   ],
                          // ),
                        ),
                      )
                    else
                      Stack(
                        children: [
                          ShaderMask(
                            shaderCallback: (rect) {
                              return const LinearGradient(
                                stops: [
                                  0.2,
                                  0.5,
                                  0.8,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: OlukoNeumorphismColors.homeGradientColorList,
                              ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                            },
                            child: SizedBox(
                              height: ScreenUtils.height(context),
                              width: ScreenUtils.width(context),
                              child: BlocBuilder<UsersSelfiesBloc, UsersSelfiesState>(
                                builder: (context, state) {
                                  if (state is UsersSelfiesSuccess) {
                                    return SelfiesGrid(images: state.usersSelfies.selfies);
                                  } else {
                                    return OlukoCircularProgressIndicator();
                                  }
                                },
                              ),
                            ),
                          ),
                          Center(child: notErolledContent(false))
                        ],
                      )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget notErolledContent(bool showStories) {
    return Column(
      children: [
        SizedBox(
          height: ScreenUtils.height(context) * 0.05,
        ),
        Text(
          OlukoLocalizations.get(context, 'welcomeTo'),
          style: OlukoFonts.olukoSubtitleFont(customFontWeight: FontWeight.bold, customColor: OlukoColors.white),
        ),
        const SizedBox(height: 15),
        Image.asset(
          OlukoNeumorphism.mvtLogo,
          scale: 2.5,
        ),
        SizedBox(height: showStories ? ScreenUtils.height(context) * 0.1 : ScreenUtils.height(context) * 0.15),
        GestureDetector(
          onTap: () async {
            final videoUrl = await BlocProvider.of<IntroductionMediaBloc>(context).getVideo(IntroductionMediaTypeEnum.homeVideo, useStreamVideo: true);
            if (videoUrl != null) {
              setState(() {
                mediaURL = videoUrl;
                isVideoVisible = true;
              });
            }
          },
          child: SizedBox(
            width: 65,
            height: 65,
            child: OlukoBlurredButton(
              childContent: Image.asset('assets/courses/play_arrow.png', scale: 3.5, color: OlukoColors.white),
            ),
          ),
        ),
        SizedBox(height: showStories ? ScreenUtils.height(context) * 0.1 : ScreenUtils.height(context) * 0.15),
        enrollButton()
      ],
    );
  }

  Widget enrollButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 90),
      child: Row(
        children: [
          OlukoNeumorphicPrimaryButton(
            useBorder: true,
            title: OlukoLocalizations.get(context, 'enrollInACourse'),
            onPressed: () {
              if (_currentUser.firstAppInteractionAt == null) {
                BlocProvider.of<AuthBloc>(context).storeFirstsUserInteraction(userInteraction: UserInteractionEnum.firstAppInteraction);
              }
              Navigator.popAndPushNamed(
                context,
                routeLabels[RouteEnum.courses],
                arguments: {
                  'homeEnrollTocourse': true,
                  'firstTimeEnroll': true,
                  'showBottomTab': () => setState(() {
                        _isBottomTabActive = !_isBottomTabActive;
                      })
                },
              );
            },
          )
        ],
      ),
    );
  }

  Widget showVideoPlayer(String videoUrl, bool showStories) {
    return SizedBox(
      width: ScreenUtils.width(context),
      height: ScreenUtils.height(context) * 0.77,
      child: OlukoCustomVideoPlayer(
        videoUrl: videoUrl,
        storiesGap: showStories,
        useOverlay: true,
        isOlukoControls: true,
        closeVideoPlayer: () {
          setState(() {
            _controller = null;
            isVideoVisible = !isVideoVisible;
          });
          navigateToHomePage();
        },
        onVideoFinished: () {
          setState(() {
            _controller = null;
            isVideoVisible = !isVideoVisible;
          });
          navigateToHomePage();
        },
        whenInitialized: (ChewieController chewieController) => setState(() {
          _controller = chewieController;
        }),
      ),
    );
  }

  void navigateToHomePage() {
    widget.videoSeen(true);
  }
}
