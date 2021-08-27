import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/container_grediant.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class CoachPage extends StatefulWidget {
  const CoachPage();

  @override
  _CoachPageState createState() => _CoachPageState();
}

bool selected = false;
final PanelController _panelController = new PanelController();

class _CoachPageState extends State<CoachPage> {
  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );
    return Scaffold(
      appBar: OlukoAppBar(
        title: "Coach Section",
        showSearchBar: false,
      ),
      body: SlidingUpPanel(
        header: Text("My Timeline"),
        borderRadius: radius,
        backdropEnabled: true,
        isDraggable: true,
        margin: const EdgeInsets.all(0),
        backdropTapClosesPanel: true,
        padding: EdgeInsets.zero,
        color: OlukoColors.black,
        minHeight: 50.0,
        maxHeight: 500,
        panel: Container(
          decoration: BoxDecoration(
            color: OlukoColors.grayColor,
            borderRadius: radius,
            gradient: LinearGradient(colors: [
              OlukoColors.grayColorFadeTop,
              OlukoColors.grayColorFadeBottom
            ], stops: [
              0.0,
              1
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
          width: MediaQuery.of(context).size.width,
          height: 300,
        ),
        defaultPanelState: PanelState.CLOSED,
        controller: _panelController,
        body: Container(
          color: Colors.black,
          child: ListView(
            children: [
              Container(
                color: Colors.black,
                width: MediaQuery.of(context).size.width,
                height: 300,
              ),
              userProgressComponent(context),
              Container(
                color: Colors.black,
                width: MediaQuery.of(context).size.width,
                height: 150,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          contentSection(title: "Mentored Videos"),
                          contentSection(title: "Pending Review"),
                          contentSection(title: "Recomended Videos"),
                          contentSection(title: "Voice Messages"),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Text(
                "To Do",
                style: OlukoFonts.olukoMediumFont(
                    customColor: OlukoColors.white,
                    custoFontWeight: FontWeight.w500),
              ),
              toDoSection(context),
              assessmentSection(context),
              SizedBox(
                height: 200,
              )
            ],
          ),
        ),
      ),
    );
  }

  Container toDoSection(BuildContext context) {
    return Container(
        color: Colors.black,
        width: MediaQuery.of(context).size.width,
        height: 120,
        child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: [
              Wrap(
                children: [
                  challengeCard(),
                  segmentCard(),
                  challengeCard(),
                  segmentCard(),
                ],
              ),
            ]));
  }

  Container assessmentSection(BuildContext context) {
    return Container(
        color: Colors.black,
        width: MediaQuery.of(context).size.width,
        height: 200,
        child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: [
              Wrap(
                children: [
                  assessmentCard(),
                  assessmentCard(),
                  assessmentCard(),
                ],
              ),
            ]));
  }

  Padding assessmentCard() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        width: 250,
        height: 150,
        color: OlukoColors.challengesGreyBackground,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Introduce Yourself",
                    style: OlukoFonts.olukoBigFont(
                        customColor: OlukoColors.white,
                        custoFontWeight: FontWeight.w500),
                  ),
                  Image.asset(
                    'assets/assessment/check_ellipse.png',
                    scale: 4,
                  ),
                ],
              ),
              Wrap(
                children: [
                  Text(
                    "Contrary to popular belief, Lor em Ipsum is not sim ply ran...",
                    style: OlukoFonts.olukoMediumFont(
                        customColor: OlukoColors.grayColor,
                        custoFontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Public",
                    style: OlukoFonts.olukoBigFont(
                        customColor: OlukoColors.grayColor,
                        custoFontWeight: FontWeight.w500),
                  ),
                  Stack(alignment: Alignment.center, children: [
                    Image.asset(
                      'assets/assessment/green_ellipse.png',
                      scale: 4,
                    ),
                    Image.asset(
                      'assets/home/right_icon.png',
                      scale: 4,
                    )
                  ])
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding challengeCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Container(
        height: 100,
        width: 150,
        color: OlukoColors.challengesGreyBackground,
        child: Wrap(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10))),
                    width: 60,
                    height: 90,
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                "Challenge",
                                style: OlukoFonts.olukoSmallFont(
                                    customColor: OlukoColors.grayColor,
                                    custoFontWeight: FontWeight.w500),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                "Workout ABS",
                                overflow: TextOverflow.ellipsis,
                                style: OlukoFonts.olukoMediumFont(
                                    customColor: OlukoColors.white,
                                    custoFontWeight: FontWeight.w500),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                "Challenge by:",
                                style: OlukoFonts.olukoSmallFont(
                                    customColor: OlukoColors.grayColor,
                                    custoFontWeight: FontWeight.w500),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                "Coach",
                                style: OlukoFonts.olukoMediumFont(
                                    customColor: OlukoColors.white,
                                    custoFontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Padding segmentCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Container(
        height: 100,
        width: 150,
        color: OlukoColors.challengesGreyBackground,
        child: Wrap(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Container(
                    color: Colors.white,
                    width: 60,
                    height: 90,
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                "Segment 2/5",
                                style: OlukoFonts.olukoSmallFont(
                                    customColor: OlukoColors.grayColor,
                                    custoFontWeight: FontWeight.w500),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                "Killer ABS",
                                overflow: TextOverflow.ellipsis,
                                style: OlukoFonts.olukoMediumFont(
                                    customColor: OlukoColors.white,
                                    custoFontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  AnimatedContainer userProgressComponent(BuildContext context) {
    return AnimatedContainer(
      decoration: ContainerGradient.getContainerGradientDecoration(),
      width: MediaQuery.of(context).size.width,
      clipBehavior: Clip.none,
      height: selected ? 180 : 100,
      duration: const Duration(seconds: 1),
      child: Stack(
        children: [
          Positioned(top: 0, right: 0, child: SizedBox()),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                progressComponent(value: 2, title: "Classes Completed"),
                progressComponent(value: 3, title: "Challenges Completed"),
                TextButton(
                    onPressed: () {
                      setState(() {
                        selected = !selected;
                      });
                    },
                    child: selected
                        ? Icon(Icons.arrow_drop_up)
                        : Icon(Icons.arrow_drop_down)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                progressComponent(value: 5, title: "Course Completed"),
                progressComponent(
                    value: 20, title: "App Completed", needPercent: true),
                Container(
                  width: 70,
                  height: 50,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Row progressComponent({int value, String title, bool needPercent = false}) {
    return Row(
      children: [
        Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                image: DecorationImage(
              image: Image.asset(
                'assets/assessment/check_ellipse.png',
                scale: 4,
              ).image,
            )),
            child: Center(
                child: Text(
              needPercent ? value.toString() + "%" : value.toString(),
              style: OlukoFonts.olukoMediumFont(
                  customColor: OlukoColors.white,
                  custoFontWeight: FontWeight.w500),
            ))),
        Container(
            width: 80,
            child: Text(
              title,
              style: OlukoFonts.olukoMediumFont(
                  customColor: OlukoColors.grayColor,
                  custoFontWeight: FontWeight.w500),
            )),
      ],
    );
  }

  Row contentSection({String title}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(
                title,
                style: OlukoFonts.olukoMediumFont(
                    customColor: OlukoColors.grayColor,
                    custoFontWeight: FontWeight.w500),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                width: 150,
                height: 100,
                color: Colors.blue,
              ),
            )
          ],
        )
      ],
    );
  }
}
