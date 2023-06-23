import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/plan_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_helper.dart';
import 'package:oluko_app/utils/info_dialog.dart';
import 'package:oluko_app/models/plan.dart';
import 'package:oluko_app/models/sign_up_response.dart';
import 'package:oluko_app/ui/components/subscription_card.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class ChoosePlayPayments extends StatefulWidget {
  ChoosePlayPayments({Key key}) : super(key: key);

  @override
  _ChoosePlayPaymentsState createState() => _ChoosePlayPaymentsState();
}

class _ChoosePlayPaymentsState extends State<ChoosePlayPayments> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlanBloc()..getPlans(),
      child: form(),
    );
  }

  Widget form() {
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
                          child: Column(children: [SizedBox(height: 20), SizedBox(height: 20), titleSection(), SizedBox(height: 20), formSection()])))
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
                'Summary',
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ]));
  }

  List<Widget> formFields(PlanState state) {
    if (state is PlansSuccess) {
      return [
        Column(
          children: [
            showSubscriptionCard(state.plans[1]),
            Container(
              decoration: BoxDecoration(border: Border.all(color: OlukoColors.primary, width: 1), borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  decoration: new InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusColor: Colors.white,
                      filled: false,
                      hintStyle: new TextStyle(color: Colors.grey[800]),
                      hintText: OlukoLocalizations.get(context, 'emailExample'),
                      fillColor: Colors.white70,
                      labelText: OlukoLocalizations.get(context, 'email'),
                      labelStyle: new TextStyle(color: OlukoColors.primary)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return OlukoLocalizations.get(context, 'required');
                    }
                    return null;
                  },
                  onSaved: (value) {},
                ),
              ),
            )
          ],
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
                        child: Text('Get Started'),
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

  SubscriptionCard showSubscriptionCard(Plan plan) {
    SubscriptionCard subscriptionCard = SubscriptionCard(plan);
    return subscriptionCard;
  }
}
