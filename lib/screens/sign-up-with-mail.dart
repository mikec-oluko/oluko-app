import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:oluko_app/BLoC/auth-bloc.dart';
import 'package:oluko_app/BLoC/bloc-provider.dart';
import 'package:oluko_app/BLoC/bloc.dart';
import 'package:oluko_app/models/sign-up-request.dart';
import 'package:oluko_app/models/sign-up-response.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

class SignUpWithMailPage extends StatefulWidget {
  SignUpWithMailPage({Key key}) : super(key: key);

  @override
  _SignUpWithMailPageState createState() => _SignUpWithMailPageState();
}

class _SignUpWithMailPageState extends State<SignUpWithMailPage> {
  var bloc = SignUpWithEmailBloc();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignUpWithEmailBloc>(
        bloc: bloc, child: SignUpWithMailContentPage());
  }
}

class SignUpWithMailContentPage extends StatefulWidget {
  SignUpWithMailContentPage({Key key}) : super(key: key);

  @override
  _SignUpWithMailContentPageState createState() =>
      _SignUpWithMailContentPageState();
}

class _SignUpWithMailContentPageState extends State<SignUpWithMailContentPage> {
  int _counter = 0;
  final _formKey = GlobalKey<FormState>();
  SignUpRequest _requestData = SignUpRequest();
  var bloc = SignUpWithEmailBloc();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SignUpResponse>(
        stream: bloc.authStream,
        builder: (context, snapshot) {
          final results = snapshot.data;
          if (results != null) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              Loader.hide();
              returnToHome();
            });
            return SizedBox();
          } else {
            return Form(
                key: _formKey,
                child: Scaffold(
                    appBar: AppBar(
                      // Here we take the value from the MyHomePage object that was created by
                      // the App.build method, and use it to set our appbar title.
                      title: Text('Sign Up'),
                      backgroundColor: Colors.white,
                      actions: [],
                    ),
                    body: Container(
                        color: Colors.brown.shade100,
                        child: ListView(children: [
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(children: [
                                    SizedBox(height: 20),
                                    Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                          icon: Icon(Icons.cancel),
                                          color: Colors.grey,
                                          iconSize: 30,
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        )),
                                    SizedBox(height: 20),
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Sign Up to get started',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontSize: 30,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                'Create an account, You are just one step away!',
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.w300),
                                              )
                                            ])),
                                    SizedBox(height: 75),
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 400,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(children: [
                                              TextFormField(
                                                decoration: new InputDecoration(
                                                    focusedBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.white),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topLeft:
                                                            Radius.circular(
                                                                10.0),
                                                        topRight:
                                                            Radius.circular(
                                                                10.0),
                                                      ),
                                                    ),
                                                    border:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.white),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topLeft:
                                                            Radius.circular(
                                                                10.0),
                                                        topRight:
                                                            Radius.circular(
                                                                10.0),
                                                      ),
                                                    ),
                                                    filled: true,
                                                    hintStyle: new TextStyle(
                                                        color:
                                                            Colors.grey[800]),
                                                    hintText: "First Name",
                                                    labelText: "First Name",
                                                    fillColor: Colors.white70),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please enter some text';
                                                  }
                                                  return null;
                                                },
                                                onSaved: (value) {
                                                  this._requestData.firstName =
                                                      value;
                                                },
                                              ),
                                              TextFormField(
                                                decoration: new InputDecoration(
                                                    focusedBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.white),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(),
                                                    ),
                                                    border:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.white),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(),
                                                    ),
                                                    filled: true,
                                                    hintStyle: new TextStyle(
                                                        color:
                                                            Colors.grey[800]),
                                                    hintText: "Last Name",
                                                    labelText: "Last Name",
                                                    fillColor: Colors.white70),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please enter some text';
                                                  }
                                                  return null;
                                                },
                                                onSaved: (value) {
                                                  this._requestData.lastName =
                                                      value;
                                                },
                                              ),
                                              TextFormField(
                                                decoration: new InputDecoration(
                                                    focusedBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.white),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(),
                                                    ),
                                                    border:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.white),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(),
                                                    ),
                                                    filled: true,
                                                    hintStyle: new TextStyle(
                                                        color:
                                                            Colors.grey[800]),
                                                    hintText: "Your Email",
                                                    labelText: "Email Address",
                                                    fillColor: Colors.white70),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please enter some text';
                                                  }
                                                  return null;
                                                },
                                                onSaved: (value) {
                                                  this._requestData.email =
                                                      value;
                                                },
                                              ),
                                              TextFormField(
                                                decoration: new InputDecoration(
                                                    focusedBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.white),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        bottomLeft:
                                                            Radius.circular(
                                                                10.0),
                                                        bottomRight:
                                                            Radius.circular(
                                                                10.0),
                                                      ),
                                                    ),
                                                    border:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.white),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        bottomLeft:
                                                            Radius.circular(
                                                                10.0),
                                                        bottomRight:
                                                            Radius.circular(
                                                                10.0),
                                                      ),
                                                    ),
                                                    filled: true,
                                                    errorStyle:
                                                        TextStyle(height: 0.5),
                                                    hintStyle: new TextStyle(
                                                        color:
                                                            Colors.grey[800]),
                                                    hintText:
                                                        "8 or more characters",
                                                    labelText: "Password",
                                                    fillColor: Colors.white70),
                                                onSaved: (value) {
                                                  this._requestData.password =
                                                      value;
                                                },
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please enter some text';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ]),
                                            SizedBox(
                                                width: double.infinity,
                                                height: 50,
                                                child: StreamBuilder(
                                                    stream: BlocProvider.of<
                                                                SignUpWithEmailBloc>(
                                                            context)
                                                        .authStream,
                                                    builder:
                                                        (context, snapshot) {
                                                      return ElevatedButton(
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                                  primary: Colors
                                                                      .brown
                                                                      .shade300),
                                                          onPressed: () async {
                                                            if (_formKey
                                                                .currentState
                                                                .validate()) {
                                                              _formKey
                                                                  .currentState
                                                                  .save();
                                                              bloc.signUp(
                                                                  _requestData);
                                                              Loader.show(
                                                                  context,
                                                                  progressIndicator:
                                                                      CircularProgressIndicator());
                                                            }
                                                          },
                                                          child:
                                                              Stack(children: [
                                                            Align(
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child: Icon(Icons
                                                                    .navigate_next)),
                                                            Align(
                                                              child: Text(
                                                                  'SIGN UP'),
                                                            )
                                                          ]));
                                                    })),
                                            SizedBox(height: 10),
                                            Text('Already a Subscribed user?'),
                                            Text('Log In')
                                          ],
                                        ))
                                  ])))
                        ]))));
          }
        });
  }

  Future<void> returnToHome() async {
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  void _openLoadingDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Container(
            child: AlertDialog(
          content: CircularProgressIndicator(),
        ));
      },
    );
  }
}
