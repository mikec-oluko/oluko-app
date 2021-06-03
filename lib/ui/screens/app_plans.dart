import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/login_request.dart';
import 'package:oluko_app/models/sign_up_response.dart';
import 'package:oluko_app/ui/components/subscription_card.dart';
import 'package:oluko_app/ui/peek_password.dart';
import 'package:oluko_app/utils/app_loader.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppPlans extends StatefulWidget {
  AppPlans({Key key}) : super(key: key);

  @override
  _AppPlansState createState() => _AppPlansState();
}

class _AppPlansState extends State<AppPlans> {
  final _formKey = GlobalKey<FormState>();
  LoginRequest _requestData = LoginRequest();
  SignUpResponse profileInfo;
  bool _peekPassword = false;

  @override
  Widget build(BuildContext context) {
    return loginForm();
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
                            titleSection(),
                            SizedBox(height: 50),
                            formSection()
                          ])))
                ]))));
  }

  Widget formSection() {
    return Container(
        width: MediaQuery.of(context).size.width,
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Column(children: formFields()),
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
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w200,
                    color: Colors.white),
              ),
              Text(
                'Your Plan',
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
        ]));
  }

  List<Widget> formFields() {
    return [
      Column(
        children: [
          SubscriptionCard(
            priceLabel: '\$99/year.',
            priceSubtitle: 'Renews every year',
            subtitles: [
              ' Access to all content',
            ],
            title: '1st Level Access',
            selected: true,
          ),
          SubscriptionCard(
            priceLabel: '\$199/year.',
            priceSubtitle: 'Renews every year',
            subtitles: [
              'Access to all content',
              'Connect with coach twice a month'
            ],
            title: '2nd Level Access',
            selected: false,
          ),
          SubscriptionCard(
            priceLabel: '\$299/year.',
            priceSubtitle: 'Renews every year',
            subtitles: [
              'Access to all content',
              'Connect with coach twice a week'
            ],
            title: '3rd Level Access',
            selected: false,
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
  }
}
