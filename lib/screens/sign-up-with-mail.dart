import 'package:flutter/material.dart';
import 'package:oluko_app/BLoC/auth-bloc.dart';
import 'package:oluko_app/models/sign-up-request.dart';

class SignUpWithMailPage extends StatefulWidget {
  SignUpWithMailPage({Key key}) : super(key: key);

  @override
  _SignUpWithMailPageState createState() => _SignUpWithMailPageState();
}

class _SignUpWithMailPageState extends State<SignUpWithMailPage> {
  int _counter = 0;
  final _formKey = GlobalKey<FormState>();
  SignUpRequest _requestData = SignUpRequest();

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                                  onPressed: () => Navigator.pop(context),
                                )),
                            SizedBox(height: 20),
                            Container(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Sign Up to get started',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'Create an account, You are just one step away!',
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w300),
                                      )
                                    ])),
                            SizedBox(height: 75),
                            Container(
                                width: MediaQuery.of(context).size.width,
                                height: 400,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(children: [
                                      TextFormField(
                                        decoration: new InputDecoration(
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(10.0),
                                                topRight: Radius.circular(10.0),
                                              ),
                                            ),
                                            border: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(10.0),
                                                topRight: Radius.circular(10.0),
                                              ),
                                            ),
                                            filled: true,
                                            hintStyle: new TextStyle(
                                                color: Colors.grey[800]),
                                            hintText: "First Name",
                                            labelText: "First Name",
                                            fillColor: Colors.white70),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter some text';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          this._requestData.firstName = value;
                                        },
                                      ),
                                      TextFormField(
                                        decoration: new InputDecoration(
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white),
                                              borderRadius:
                                                  const BorderRadius.only(),
                                            ),
                                            border: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white),
                                              borderRadius:
                                                  const BorderRadius.only(),
                                            ),
                                            filled: true,
                                            hintStyle: new TextStyle(
                                                color: Colors.grey[800]),
                                            hintText: "Last Name",
                                            labelText: "Last Name",
                                            fillColor: Colors.white70),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter some text';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          this._requestData.lastName = value;
                                        },
                                      ),
                                      TextFormField(
                                        decoration: new InputDecoration(
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white),
                                              borderRadius:
                                                  const BorderRadius.only(),
                                            ),
                                            border: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white),
                                              borderRadius:
                                                  const BorderRadius.only(),
                                            ),
                                            filled: true,
                                            hintStyle: new TextStyle(
                                                color: Colors.grey[800]),
                                            hintText: "Your Email",
                                            labelText: "Email Address",
                                            fillColor: Colors.white70),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter some text';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          this._requestData.email = value;
                                        },
                                      ),
                                      TextFormField(
                                        decoration: new InputDecoration(
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                bottomLeft:
                                                    Radius.circular(10.0),
                                                bottomRight:
                                                    Radius.circular(10.0),
                                              ),
                                            ),
                                            border: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                bottomLeft:
                                                    Radius.circular(10.0),
                                                bottomRight:
                                                    Radius.circular(10.0),
                                              ),
                                            ),
                                            filled: true,
                                            errorStyle: TextStyle(height: 0.5),
                                            hintStyle: new TextStyle(
                                                color: Colors.grey[800]),
                                            hintText: "8 or more characters",
                                            labelText: "Password",
                                            fillColor: Colors.white70),
                                        onSaved: (value) {
                                          this._requestData.password = value;
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter some text';
                                          }
                                          return null;
                                        },
                                      ),
                                    ]),
                                    SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                primary: Colors.brown.shade300),
                                            onPressed: () async {
                                              if (_formKey.currentState
                                                  .validate()) {
                                                _formKey.currentState.save();
                                                await SignUpWithEmailBloc()
                                                    .signUp(_requestData);
                                                Navigator.popUntil(context,
                                                    ModalRoute.withName('/'));
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content: Text('OK!')));
                                              }
                                            },
                                            child: Stack(children: [
                                              Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Icon(
                                                      Icons.navigate_next)),
                                              Align(
                                                child: Text('SIGN UP'),
                                              )
                                            ]))),
                                    SizedBox(height: 10),
                                    Text('Already a Subscribed user?'),
                                    Text('Log In')
                                  ],
                                ))
                          ])))
                ]))));
  }
}
