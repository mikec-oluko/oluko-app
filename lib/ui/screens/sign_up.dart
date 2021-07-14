import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/constants/theme.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(body: MainSignUpPage());
  }
}

class MainSignUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Future.delayed(const Duration(milliseconds: 1000), () {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        });
        return false;
      },
      child: BlocProvider(
          create: (context) => AuthBloc(),
          child: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
            return Stack(alignment: Alignment.bottomCenter, children: [
              Image.asset(
                'assets/login/sign_up_splash_screen.png',
                fit: BoxFit.fitHeight,
                colorBlendMode: BlendMode.colorBurn,
                height: MediaQuery.of(context).size.height,
              ),
              Image.asset(
                'assets/login/sign_up_splash_gradient.png',
                fit: BoxFit.fitHeight,
                colorBlendMode: BlendMode.colorBurn,
                height: MediaQuery.of(context).size.height,
              ),
              Positioned(
                  bottom: 0,
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                          child: Column(children: [
                        SizedBox(height: 20),
                        Container(
                            width: MediaQuery.of(context).size.width,
                            height: 150,
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                primary: OlukoColors.primary),
                                            onPressed: () =>
                                                Navigator.pushNamed(
                                                    context, '/log-in'),
                                            child: Stack(children: [
                                              Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Icon(
                                                      Icons.navigate_next)),
                                              Align(
                                                child: Text('LOGIN'),
                                              )
                                            ]))),
                                    // TODO Enable Signup
                                    // SizedBox(
                                    //     width: double.infinity,
                                    //     height: 50,
                                    //     child: ElevatedButton(
                                    //         style: ElevatedButton.styleFrom(
                                    //             primary: OlukoColors.primary),
                                    //         onPressed: () => Navigator.pushNamed(
                                    //             context, '/sign-up-with-email'),
                                    //         child: Stack(children: [
                                    //           Align(
                                    //               alignment:
                                    //                   Alignment.centerRight,
                                    //               child:
                                    //                   Icon(Icons.navigate_next)),
                                    //           Align(
                                    //             child: Text('SIGN UP'),
                                    //           )
                                    //         ]))),
                                    SizedBox(height: 10),
                                  ],
                                )))
                      ]))))
            ]);
          })),
    );
  }
}
