import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/plan_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_helper.dart';
import 'package:oluko_app/utils/info_dialog.dart';
import 'package:oluko_app/models/plan.dart';
import 'package:oluko_app/ui/components/subscription_card.dart';

class AppPlans extends StatefulWidget {
  AppPlans({Key key}) : super(key: key);

  @override
  _AppPlansState createState() => _AppPlansState();
}

class _AppPlansState extends State<AppPlans> {
  final _formKey = GlobalKey<FormState>();

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
                color: OlukoColors.black,
                child: ListView(physics: OlukoNeumorphism.listViewPhysicsEffect, addAutomaticKeepAlives: false, addRepaintBoundaries: false, children: [
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(children: [SizedBox(height: 20), SizedBox(height: 20), titleSection(), SizedBox(height: 50), formSection()])))
                ]))));
  }

  Widget formSection() {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          BlocBuilder<PlanBloc, PlanState>(builder: (context, state) {
            return Column(children: formFields(state));
          }),
        ]));
  }

  Widget titleSection() {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Text(
                'Choose ',
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w200, color: Colors.white),
              ),
              Text(
                'Your Plan',
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
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
                    style: ElevatedButton.styleFrom(primary: OlukoColors.primary),
                    onPressed: () {},
                    child: Stack(children: [
                      Align(
                        child: const Text('Get Started'),
                      )
                    ])))),
      ];
    } else {
      return [];
    }
  }

  showWaitlist(BuildContext context, InfoDialog infoDialog) {
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
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(10))),
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
                          decoration: BoxDecoration(boxShadow: [BoxShadow(blurRadius: 5)], borderRadius: BorderRadius.all(Radius.circular(15))),
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
      SubscriptionCard subscriptionCard = SubscriptionCard(plan);
      return subscriptionCard;
    }).toList();
  }
}
