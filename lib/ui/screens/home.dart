import 'package:badges/badges.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nil/nil.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/course/course_bloc.dart';
import 'package:oluko_app/blocs/course/course_home_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_bloc.dart';
import 'package:oluko_app/blocs/views_bloc/hi_five_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/course_section.dart';
import 'package:oluko_app/ui/components/course_step_section.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/stories_header.dart';
import 'package:oluko_app/ui/components/video_overlay.dart';
import 'package:oluko_app/utils/app_navigator.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  User _user;
  List<CourseEnrollment> _courseEnrollments;
  List<Course> _courses;
  AuthSuccess _authState;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        _authState ??= authState;
        _user = authState.firebaseUser;
        BlocProvider.of<CourseEnrollmentListBloc>(context)
            .getCourseEnrollmentsByUser(_user.uid);
        return BlocBuilder<CourseEnrollmentListBloc, CourseEnrollmentListState>(
            builder: (context, courseEnrollmentListState) {
          if (courseEnrollmentListState is CourseEnrollmentsByUserSuccess) {
            _courseEnrollments = courseEnrollmentListState.courseEnrollments;
            BlocProvider.of<CourseHomeBloc>(context)
              ..getByCourseEnrollments(_courseEnrollments);
            return form();
          } else {
            return Container(
                color: Colors.black,
                child: Center(child: CircularProgressIndicator()));
          }
        });
      } else {
        return Container(
            color: Colors.black,
            child: Center(child: CircularProgressIndicator()));
      }
    });
  }

  Widget form() {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: OlukoAppBar(
          title: OlukoLocalizations.get(context, 'home'),
          showLogo: true,
          showBackButton: false,
          actions: [_handWidget()],
        ),
        body: ListView(children: [
          Center(child: StoriesHeader(_user.uid)),
          WillPopScope(
            onWillPop: () => AppNavigator.onWillPop(context),
            child: OrientationBuilder(builder: (context, orientation) {
              return homeContainer();
            }),
          )
        ]));
  }

  Widget homeContainer() {
    if (_courseEnrollments.length > 0) {
      return BlocBuilder<CourseHomeBloc, CourseHomeState>(
          builder: (context, courseState) {
        if (courseState is GetByCourseEnrollmentsSuccess) {
          _courses = courseState.courses;
          if (_courses != null &&
              _courses.length > 0 &&
              _courses.any((element) => element != null)) {
            return enrolled();
          } else {
            return notEnrolled();
          }
        } else {
          return notEnrolled();
        }
      });
    } else {
      return notEnrolled();
    }
  }

  Widget enrolled() {
    return BlocBuilder<CourseHomeBloc, CourseHomeState>(
        builder: (context, courseHomeState) {
      if (courseHomeState is GetByCourseEnrollmentsSuccess) {
        _courses = courseHomeState.courses;
        return CarouselSlider(
          items: courseSectionList(),
          options: CarouselOptions(
              height: 600,
              autoPlay: false,
              enlargeCenterPage: false,
              disableCenter: true,
              enableInfiniteScroll: false,
              initialPage: 0,
              viewportFraction: 1),
        );
      } else {
        return SizedBox();
      }
    });
  }

  List<Widget> courseSectionList() {
    List<Widget> widgets = [];
    for (var i = 0; i < _courseEnrollments.length; i++) {
      if (_courses.length - 1 < i) {
        // do nothing
      } else {
        if (_courses[i] != null) {
          widgets.add(CourseSection(
              qtyCourses: _courses.length,
              courseIndex: i,
              course: _courses[i],
              courseEnrollment: _courseEnrollments[i]));
        }
      }
    }
    return widgets;
  }

  Widget notEnrolled() {
    return Stack(children: [
      ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.transparent],
            ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
          },
          blendMode: BlendMode.dstIn,
          child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: AssetImage("assets/courses/profile_photos.png"),
                fit: BoxFit.cover,
              )),
              height: ScreenUtils.height(context) - 200,
              width: ScreenUtils.width(context))),
      Image.asset(
        'assets/home/degraded.png',
        scale: 4,
      ),
      notErolledContent()
    ]);
  }

  Widget enrollButton() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Row(
          children: [
            OlukoPrimaryButton(
              title: OlukoLocalizations.get(context, 'enrollToACourse'),
              onPressed: () {
                Navigator.pushNamed(context, routeLabels[RouteEnum.courses],
                    arguments: {'homeEnrollTocourse': 'true'});
              },
            ),
          ],
        ));
  }

  Widget notErolledContent() {
    return Column(
      children: [
        SizedBox(height: 85),
        Text(OlukoLocalizations.get(context, 'welcomeTo'),
            style: OlukoFonts.olukoSubtitleFont(
                custoFontWeight: FontWeight.bold,
                customColor: OlukoColors.white)),
        SizedBox(height: 25),
        Image.asset(
          'assets/home/mvt.png',
          scale: 2,
        ),
        SizedBox(height: 50),
        Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (_, __, ___) => VideoOverlay(
                      videoUrl:
                          "https://firebasestorage.googleapis.com/v0/b/oluko-development.appspot.com/o/Welcome%20to%20MVT.mp4?alt=media&token=534ec64b-822b-44b6-a014-1c8efe733ff9"),
                ),
              ),
              child: Align(
                  alignment: Alignment.center,
                  child: Stack(alignment: Alignment.center, children: [
                    Image.asset(
                      'assets/courses/play_ellipse.png',
                      height: 85,
                      width: 85,
                    ),
                    Padding(
                        padding: const EdgeInsets.only(left: 3.5),
                        child: Image.asset(
                          'assets/courses/play_arrow.png',
                          height: 30,
                          width: 30,
                        )),
                  ])),
            )),
        SizedBox(height: 110),
        enrollButton()
      ],
    );
  }

  Widget _handWidget() {
    return BlocBuilder<HiFiveBloc, HiFiveState>(
        builder: (context, hiFiveState) {
      return hiFiveState is HiFiveSuccess && hiFiveState.users.isNotEmpty
          ? GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, routeLabels[RouteEnum.hiFivePage])
                    .then((value) => BlocProvider.of<HiFiveBloc>(context)
                        .get(_authState.user.id));
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 20.0, top: 5),
                child: Badge(
                    position: BadgePosition(top: 0, start: 10),
                    badgeContent: Text(hiFiveState.users.length.toString()),
                    child: Image.asset(
                      'assets/home/hand.png',
                      scale: 4,
                    )),
              ),
            )
          : SizedBox();
    });
  }
}
