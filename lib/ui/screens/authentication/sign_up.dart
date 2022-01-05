import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_secondary_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: MainSignUpPage());
  }
}

class MainSignUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
      child: WillPopScope(
        onWillPop: () async {
          Future.delayed(const Duration(milliseconds: 1000), () {
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          });
          return false;
        },
        child: BlocProvider(
            create: (context) => AuthBloc(),
            child: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
              return SizedBox(
                width: ScreenUtils.width(context),
                child: Stack(fit: StackFit.expand, alignment: Alignment.bottomCenter, children: [
                  Positioned(
                      top: 0,
                      child: Stack(alignment: Alignment.topCenter, children: [
                        Image.asset(
                          'assets/login/sign_up.png',
                          height: ScreenUtils.height(context) * 0.6,
                          colorBlendMode: BlendMode.colorBurn,
                        ),
                        Image.asset(
                          'assets/login/sign_up_splash_gradient.png',
                          width: ScreenUtils.width(context),
                          colorBlendMode: BlendMode.colorBurn,
                        ),
                      ])),
                  Positioned(
                    bottom: 60,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: SizedBox(
                            width: ScreenUtils.width(context),
                            child: Column(
                              children: [
                                Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(OlukoLocalizations.get(context, 'welcomeTo'), style: OlukoFonts.olukoTitleFont())),
                                Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(OlukoLocalizations.get(context, 'fitnessWorld'), style: OlukoFonts.olukoTitleFont())),
                                const SizedBox(height: 15),
                                Align(
                                    alignment: Alignment.topLeft,
                                    child:
                                        Text(OlukoLocalizations.get(context, 'bestYouCanDo'), style: const TextStyle(color: Colors.grey))),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 80),
                        SizedBox(
                          width: 300,
                          height: 50,
                          child: OlukoNeumorphicPrimaryButton(
                            useBorder: true,
                            isExpanded: false,
                            thinPadding: true,
                            onPressed: () => Navigator.pushNamed(context, routeLabels[RouteEnum.logInUsername]),
                            title: OlukoLocalizations.get(context, 'loginToContinue'),
                          ),
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: ScreenUtils.width(context),
                          child: Row(children: [
                            Expanded(
                              child: Image.asset(
                                'assets/login/line.png',
                              ),
                            ),
                            Text(
                              OlukoLocalizations.get(context, 'orContinueWith'),
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Expanded(
                              child: Image.asset(
                                'assets/login/line.png',
                              ),
                            )
                          ]),
                        ),
                        const SizedBox(height: 30),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          SizedBox(
                            width: 140,
                            height: 50,
                            child: OlukoNeumorphicSecondaryButton(
                              useBorder: true,
                              isExpanded: false,
                              thinPadding: true,
                              onlyIcon: true,
                              onPressed: () {
                                BlocProvider.of<AuthBloc>(context).loginWithFacebook(context);
                              },
                              icon: Align(
                                  child: Image.asset(
                                'assets/login/facebook-logo.png',
                                width: 30,
                              )),
                            ),
                          ),
                          const SizedBox(width: 35),
                          SizedBox(
                            width: 140,
                            height: 50,
                            child: OlukoNeumorphicSecondaryButton(
                              useBorder: true,
                              isExpanded: false,
                              thinPadding: true,
                              onlyIcon: true,
                              onPressed: () {
                                BlocProvider.of<AuthBloc>(context).loginWithGoogle(context);
                              },
                              icon: Align(
                                child: Image.asset(
                                  'assets/login/google-logo.png',
                                  width: 25,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ]),
              );
            })),
      ),
    );
  }
}


      // TODO: Signup
      // InkWell(
      //   onTap: () => Navigator.pushNamed(context, '/sign-up-with-email'),
      //   child: Padding(
      //     padding: EdgeInsets.only(top: 10),
      //     child: Column(
      //       children: [
      //         Text(
      //           'Tap here to create an account',
      //           style: TextStyle(color: Colors.white),
      //         ),
      //         Text('Sign Up',
      //             style: TextStyle(
      //                 color: Colors.white, fontWeight: FontWeight.bold))
      //       ],
      //     ),
      //   ),
      // )
