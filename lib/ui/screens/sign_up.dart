import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';

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
    return BlocProvider(
        create: (context) => AuthBloc(),
        child: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
          return Stack(alignment: Alignment.bottomCenter, children: [
            Image.network(
              'https://p0.pxfuel.com/preview/450/272/870/girl-boxing-fit-fitness.jpg',
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
                                              primary: Colors.brown.shade300),
                                          onPressed: () => Navigator.pushNamed(
                                              context, '/log-in'),
                                          child: Stack(children: [
                                            Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child:
                                                    Icon(Icons.navigate_next)),
                                            Align(
                                              child: Text('Login'),
                                            )
                                          ]))),
                                  SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.brown.shade300),
                                          onPressed: () => Navigator.pushNamed(
                                              context, '/sign-up-with-email'),
                                          child: Stack(children: [
                                            Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child:
                                                    Icon(Icons.navigate_next)),
                                            Align(
                                              child: Text('Sign Up'),
                                            )
                                          ]))),
                                  SizedBox(height: 10),
                                ],
                              )))
                    ]))))
          ]);
        }));
  }
}
