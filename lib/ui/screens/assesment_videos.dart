import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/plan_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_helper.dart';
import 'package:oluko_app/models/info_dialog.dart';
import 'package:oluko_app/models/plan.dart';
import 'package:oluko_app/models/sign_up_response.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/ui/components/subscription_card.dart';
import 'package:oluko_app/ui/components/task_card.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/components/title_header.dart';
import 'package:oluko_app/ui/components/video_player.dart';

class AsessmentVideos extends StatefulWidget {
  AsessmentVideos({Key key}) : super(key: key);

  @override
  _AsessmentVideosState createState() => _AsessmentVideosState();
}

class _AsessmentVideosState extends State<AsessmentVideos> {
  final _formKey = GlobalKey<FormState>();
  SignUpResponse profileInfo;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlanBloc()..getPlans(),
      child: loginForm(),
    );
  }

  Widget loginForm() {
    return Form(
        key: _formKey,
        child: Scaffold(
            body: Container(
                color: Colors.black,
                child: ListView(children: [
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(children: [
                            SizedBox(height: 20),
                            SizedBox(height: 20),
                            Stack(children: [
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () => Navigator.pop(context),
                                    child: Icon(
                                      Icons.chevron_left,
                                      size: 30,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: TitleHeader(
                                        'Assessment',
                                        bold: true,
                                      )),
                                ],
                              ),
                              Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Text(
                                      'Skip',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                  )),
                            ]),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 25),
                              child: OlukoVideoPlayer(),
                            ),
                            TitleBody(
                              'Complete the below tasks to get a coach assigned',
                              bold: true,
                            ),
                            Column(
                              children: [
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15.0),
                                    child: TaskCard(
                                      task: Task(
                                          name: 'Introduction of myself',
                                          description:
                                              'Who I am, what are my goals with exercising, if I have any injuries and where I am from. Long: 30 seg - 1 min',
                                          image:
                                              'https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/tasks%2FRectangle%2057.png?alt=media&token=7aa49ef8-4414-4ccc-bc00-e1443a9a9b42'),
                                    )),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15.0),
                                  child: TaskCard(
                                      task: Task(
                                          name: 'Place to workout',
                                          description:
                                              'I want to show the place I have chosen to workout.',
                                          image:
                                              'https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/tasks%2FRectangle%2057%20(1).png?alt=media&token=b0e8fe90-eda7-4656-8b3b-70caef9b5fa8')),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15.0),
                                  child: TaskCard(
                                    task: Task(
                                        name: 'Excercise 1',
                                        description: 'Air Squat',
                                        image:
                                            'https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/tasks%2Fairsquat.jpg?alt=media&token=2baadd24-8f42-4870-a3c6-3fb9272b9487'),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15.0),
                                  child: TaskCard(
                                    task: Task(
                                        name: 'Excercise 2',
                                        description: 'Hinge',
                                        image:
                                            'https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/tasks%2Fhinge.jpg?alt=media&token=5b5a1078-e024-4de6-9b3c-fd913f4e6780'),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15.0),
                                  child: TaskCard(
                                    task: Task(
                                        name: 'Excercise 3',
                                        description: 'Push Up',
                                        image:
                                            'https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/tasks%2Fpushups.jpg?alt=media&token=962b5a86-cdcd-4329-8706-37227f3b05be'),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 100,
                            )
                          ])))
                ]))));
  }

  Widget formSection() {
    return Container(
        width: MediaQuery.of(context).size.width,
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          BlocBuilder<PlanBloc, PlanState>(builder: (context, state) {
            return Column(children: formFields(state));
          }),
        ]));
  }

  List<Widget> formFields(PlanState state) {
    if (state is PlansSuccess) {
      return [
        Column(
          children: showSubscriptionCards(state.plans),
        ),
        Padding(
            padding: EdgeInsets.only(top: 30, bottom: 100),
            child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(primary: OlukoColors.primary),
                    onPressed: () {},
                    child: Stack(children: [
                      Align(
                        child: Text('Get Started'),
                      )
                    ])))),
      ];
    } else {
      return [];
    }
  }

  showWaitlist(context, InfoDialog infoDialog) {
    showDialog(
        context: context,
        builder: (context2) {
          return AlertDialog(
            insetPadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.zero,
            backgroundColor: Colors.transparent,
            content: Container(
                height: 200,
                child: Stack(children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                                padding: EdgeInsets.only(bottom: 15),
                                child: Text(
                                  infoDialog.title,
                                  style: TextStyle(fontSize: 25),
                                  textAlign: TextAlign.left,
                                )),
                            Text(infoDialog.content)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0.0,
                    top: 0.0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          decoration: BoxDecoration(
                              boxShadow: [BoxShadow(blurRadius: 5)],
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                          child: CircleAvatar(
                            radius: 14.0,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.close, color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                  )
                ])),
          );
        });
  }

  List<SubscriptionCard> showSubscriptionCards(List<Plan> plans) {
    return plans.map((Plan plan) {
      SubscriptionCard subscriptionCard = SubscriptionCard();
      subscriptionCard.priceLabel =
          '\$${plan.price}/${durationLabel[plan.duration].toLowerCase()}';
      subscriptionCard.priceSubtitle = plan.recurrent
          ? 'Renews every ${durationLabel[plan.duration].toLowerCase()}'
          : '';
      subscriptionCard.title = plan.title;
      subscriptionCard.subtitles = plan.features
          .map((PlanFeature feature) => EnumHelper.enumToString(feature))
          .toList();
      subscriptionCard.selected = false;
      subscriptionCard.showHint = plan.infoDialog != null;
      subscriptionCard.backgroundImage = plan.backgroundImage;
      subscriptionCard.onHintPressed = plan.infoDialog != null
          ? () => showWaitlist(context, plan.infoDialog)
          : null;
      return subscriptionCard;
    }).toList();
  }
}
