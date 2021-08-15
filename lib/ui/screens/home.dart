import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/course_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_bloc.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/course_section.dart';
import 'package:oluko_app/ui/components/course_step_section.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        _user = authState.firebaseUser;
        BlocProvider.of<CourseEnrollmentListBloc>(context)
          ..getCourseEnrollmentsByUser(_user.uid);
        return BlocBuilder<CourseEnrollmentListBloc, CourseEnrollmentListState>(
            builder: (context, courseEnrollmentListState) {
          if (courseEnrollmentListState is CourseEnrollmentsByUserSuccess) {
            _courseEnrollments = courseEnrollmentListState.courseEnrollments;
            BlocProvider.of<CourseBloc>(context)
              ..getByCourseEnrollments(_courseEnrollments);
            return form();
          } else {
            return SizedBox();
          }
        });
      } else {
        return SizedBox();
      }
    });
  }

  Widget form() {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: OlukoAppBar(
          title: OlukoLocalizations.of(context).find('home'),
          showLogo: true,
          showBackButton: false,
          actions: [_handWidget()],
        ),
        body: WillPopScope(
          onWillPop: () => AppNavigator.onWillPop(context),
          child: OrientationBuilder(builder: (context, orientation) {
            return homeContainer();
          }),
        ));
  }

  Widget homeContainer() {
    if (_courseEnrollments.length > 0) {
      return BlocBuilder<CourseBloc, CourseState>(
          builder: (context, courseState) {
        if (courseState is GetByCourseEnrollmentsSuccess) {
          _courses = courseState.courses;
          if (_courses != null && _courses.length > 0) {
            return enrolled();
          } else {
            return SizedBox();
          }
        } else {
          return SizedBox();
        }
      });
    } else {
      return notEnrolled();
    }
  }

  Widget enrolled() {
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
  }

  List<Widget> courseSectionList() {
    List<Widget> widgets = [];
    for (var i = 0; i < _courseEnrollments.length; i++) {
      widgets.add(CourseSection(
          qtyCourses: _courses.length,
          courseIndex: i,
          course: _courses[i],
          courseEnrollment: _courseEnrollments[i]));
    }
    return widgets;
  }

  Widget notEnrolled() {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage("assets/home/rectangle.png"),
          fit: BoxFit.cover,
        )),
        height: ScreenUtils.height(context),
        width: ScreenUtils.width(context),
        child: Column(
          children: [
            SizedBox(height: 60),
            Image.asset(
              'assets/home/mvt.png',
              scale: 2,
            ),
            SizedBox(height: 70),
            Text(OlukoLocalizations.of(context).find('enroll'),
                style: OlukoFonts.olukoSuperBigFont(
                    custoFontWeight: FontWeight.bold,
                    customColor: OlukoColors.white)),
            Text(OlukoLocalizations.of(context).find('toACourse'),
                style: OlukoFonts.olukoSuperBigFont(
                    custoFontWeight: FontWeight.bold,
                    customColor: OlukoColors.white)),
            SizedBox(height: 10),
            CourseStepSection(totalCourseSteps: 4, currentCourseStep: 4),
            SizedBox(height: 30),
            GestureDetector(
                onTap: () => Navigator.pushNamed(
                    context, routeLabels[RouteEnum.courses]),
                child: Stack(alignment: Alignment.center, children: [
                  Image.asset(
                    'assets/home/ellipse.png',
                    scale: 4,
                  ),
                  Image.asset(
                    'assets/home/+.png',
                    scale: 4,
                  )
                ])),
          ],
        ));
  }

  Widget _handWidget() {
    return GestureDetector(
      onTap: () {
        //TODO: add action here.
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 20.0, top: 5),
        child: Image.asset(
          'assets/home/hand.png',
          scale: 4,
        ),
      ),
    );
  }
}
