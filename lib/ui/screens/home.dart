import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/class_bloc.dart';
import 'package:oluko_app/blocs/course_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/services/course_enrollment_service.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/carousel_section.dart';
import 'package:oluko_app/ui/components/class_card.dart';
import 'package:oluko_app/ui/components/course_progress_bar.dart';
import 'package:oluko_app/ui/components/course_step_section.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/utils/app_navigator.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  User _user;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        _user = authState.firebaseUser;
        BlocProvider.of<CourseBloc>(context)..getUserEnrolled(_user.uid);
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
                return ListView(
                  shrinkWrap: true,
                  children: [
                    BlocBuilder<CourseBloc, CourseState>(
                        builder: (context, courseState) {
                      if (courseState is UserEnrolledCoursesSuccess) {
                        return homeContainer(_user, courseState.courses);
                      } else {
                        return Container(
                            alignment: Alignment.center,
                            child: Column(children: [
                              SizedBox(height: 230),
                              OlukoCircularProgressIndicator()
                            ]));
                      }
                    })
                  ],
                );
              }),
            ));
      } else {
        return SizedBox();
      }
    });
  }

  Widget homeContainer(User user, List<Course> courses) {
    if (courses.length > 0) {
      return enrolled(user, courses);
    } else {
      return notEnrolled();
    }
  }

  Widget enrolled(User user, List<Course> courses) {
    Course actualCourse = courses[0];
    BlocProvider.of<ClassBloc>(context)..getAll(actualCourse);
    BlocProvider.of<CourseEnrollmentBloc>(context)..get(user, actualCourse);
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: NetworkImage(actualCourse.image),
          fit: BoxFit.cover,
        )),
        height: ScreenUtils.height(context),
        width: ScreenUtils.width(context),
        child: Column(children: [
          //TODO: Put here the real course progress
          CourseProgressBar(value: 0.5),
          SizedBox(height: 10),
          Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.share, color: OlukoColors.white),
                onPressed: () {
                  //TODO: Add action
                },
              )),
          SizedBox(height: 120),
          Text(actualCourse.name,
              style: OlukoFonts.olukoSuperBigFont(
                  custoFontWeight: FontWeight.bold,
                  customColor: OlukoColors.white)),
          SizedBox(height: 15),
          Text(
            //TODO: change weeks number
            TimeConverter.toCourseDuration(
                3,
                actualCourse.classes != null ? actualCourse.classes.length : 0,
                context),
            style: OlukoFonts.olukoMediumFont(
                custoFontWeight: FontWeight.normal,
                customColor: OlukoColors.grayColor),
          ),
          SizedBox(height: 2),
          CourseStepSection(
              totalCourseSteps: actualCourse.classes.length,
              currentCourseStep: 1),
          SizedBox(height: 10),
          BlocBuilder<ClassBloc, ClassState>(builder: (context, classState) {
            return BlocBuilder<CourseEnrollmentBloc, CourseEnrollmentState>(
                builder: (context, courseEnrollmentState) {
              if (classState is GetSuccess &&
                  courseEnrollmentState is GetEnrollmentSuccess) {
                return carousel(
                    classState.classes, courseEnrollmentState.courseEnrollment);
              } else {
                return SizedBox();
              }
            });
          })
        ]));
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

  Widget carousel(List<Class> classes, CourseEnrollment courseEnrollment) {
    int selectedClass =
        CourseEnrollmentService.getFirstUncompletedClassIndex(courseEnrollment);
    List<Widget> classCards = [];
    for (var i = 0; i < classes.length; i++) {
      bool isSelected = i == selectedClass;
      classCards.add(ClassCard(
        classObj: classes[i],
        classIndex: i,
        courseEnrollment: courseEnrollment,
        selected: isSelected,
      ));
    }
    return CarouselSection(height: 225, children: classCards);
  }
}
