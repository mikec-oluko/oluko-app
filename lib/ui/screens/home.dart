import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/course_bloc.dart';
import 'package:oluko_app/blocs/tag_bloc.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/course_step_section.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/utils/app_navigator.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  User profile;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        return BlocBuilder<CourseBloc, CourseState>(
            bloc: BlocProvider.of<CourseBloc>(context)..getByCategories(),
            builder: (context, courseState) {
              return BlocBuilder<TagBloc, TagState>(
                  bloc: BlocProvider.of<TagBloc>(context)..getByCategories(),
                  builder: (context, tagState) {
                    return Scaffold(
                        backgroundColor: Colors.black,
                        appBar: OlukoAppBar(
                          title: OlukoLocalizations.of(context).find('home'),
                          showLogo: true,
                          showBackButton: false,
                          actions: [_handWidget()],
                        ),
                        body: courseState is CourseSuccess &&
                                tagState is TagSuccess
                            ? WillPopScope(
                                onWillPop: () =>
                                    AppNavigator.onWillPop(context),
                                child: OrientationBuilder(
                                    builder: (context, orientation) {
                                  return ListView(
                                    shrinkWrap: true,
                                    children: [
                                      Container(
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                            image: AssetImage(
                                                "assets/home/rectangle.png"),
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
                                                  style: OlukoFonts
                                                      .olukoSuperBigFont(
                                                          custoFontWeight:
                                                              FontWeight.bold,
                                                          customColor:
                                                              OlukoColors
                                                                  .white)),
                                              Text(OlukoLocalizations.of(context).find('toACourse'),
                                                  style: OlukoFonts
                                                      .olukoSuperBigFont(
                                                          custoFontWeight:
                                                              FontWeight.bold,
                                                          customColor:
                                                              OlukoColors
                                                                  .white)),
                                              SizedBox(height: 10),
                                              CourseStepSection(
                                                  totalCourseSteps: 4,
                                                  currentCourseStep: 4),
                                              SizedBox(height: 15),
                                              Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Image.asset(
                                                      'assets/home/ellipse.png',
                                                      scale: 4,
                                                    ),
                                                    Image.asset(
                                                      'assets/home/+.png',
                                                      scale: 4,
                                                    )
                                                  ]),
                                            ],
                                          ))
                                    ],
                                  );
                                }),
                              )
                            : OlukoCircularProgressIndicator());
                  });
            });
      } else {
        return SizedBox();
      }
    });
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
