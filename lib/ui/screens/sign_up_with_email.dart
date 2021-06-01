import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/user_bloc.dart';
import 'package:oluko_app/models/sign_up_request.dart';
import 'package:oluko_app/models/sign_up_response.dart';
import 'package:oluko_app/utils/app_loader.dart';

import '../peek_password.dart';

class SignUpWithMailPage extends StatefulWidget {
  SignUpWithMailPage({Key key}) : super(key: key);

  @override
  _SignUpWithMailPageState createState() => _SignUpWithMailPageState();
}

class _SignUpWithMailPageState extends State<SignUpWithMailPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => UserBloc(), child: SignUpWithMailContentPage());
  }
}

class SignUpWithMailContentPage extends StatefulWidget {
  SignUpWithMailContentPage({Key key}) : super(key: key);

  @override
  _SignUpWithMailContentPageState createState() =>
      _SignUpWithMailContentPageState();
}

class _SignUpWithMailContentPageState extends State<SignUpWithMailContentPage> {
  final _formKey = GlobalKey<FormState>();
  SignUpRequest _requestData = SignUpRequest();
  bool _peekPassword = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
        builder: (context, UserState state) {
      return signUpForm();
    });
  }

  Widget signUpForm() {
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
                color: Colors.black,
                child: ListView(children: [
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(children: [
                            SizedBox(height: 20),
                            titleSection(),
                            SizedBox(height: 30),
                            //Login with SSO
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 5),
                                      child: SizedBox(
                                          height: 50,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.2,
                                          child: OutlinedButton(
                                              onPressed: () {
                                                BlocProvider.of<AuthBloc>(
                                                    context)
                                                  ..loginWithGoogle(context);
                                              },
                                              style: OutlinedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  side: BorderSide(
                                                      color: Colors.grey)),
                                              child: Stack(children: [
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: Image.network(
                                                    'https://img.icons8.com/color/452/google-logo.png',
                                                    width: 30,
                                                  ),
                                                ),
                                              ])))),
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 5),
                                      child: SizedBox(
                                          height: 50,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.2,
                                          child: OutlinedButton(
                                              onPressed: () {
                                                BlocProvider.of<AuthBloc>(
                                                    context)
                                                  ..loginWithFacebook(context);
                                              },
                                              style: OutlinedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  side: BorderSide(
                                                      color: Colors.grey)),
                                              child: Stack(children: [
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: Image.network(
                                                    'https://cdn.icon-icons.com/icons2/1826/PNG/512/4202110facebooklogosocialsocialmedia-115707_115594.png',
                                                    width: 30,
                                                  ),
                                                ),
                                              ])))),
                                ]),
                            formSection()
                          ])))
                ]))));
  }

  Widget formSection() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 400,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
                height: 300,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: formFields())),
            SizedBox(
                width: double.infinity,
                height: 50,
                child:
                    BlocBuilder<UserBloc, UserState>(builder: (context, state) {
                  return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.brown.shade300),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          UserBloc()..signUp(context, _requestData);
                          AppLoader.startLoading(context);
                        }
                      },
                      child: Stack(children: [
                        Align(
                          child: Text('SIGN UP'),
                        )
                      ]));
                })),
            SizedBox(height: 10),
            Text(
              'Already a Subscribed user?',
              style: TextStyle(color: Colors.white),
            ),
            Text('Log In',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
          ],
        ));
  }

  Widget titleSection() {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'Welcome',
            textAlign: TextAlign.start,
            style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ]));
  }

  List<Widget> formFields() {
    return [
      TextFormField(
        style: TextStyle(color: Colors.white),
        decoration: new InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            focusColor: Colors.white,
            filled: false,
            hintStyle: new TextStyle(color: Colors.grey[800]),
            labelStyle: new TextStyle(color: Colors.grey[800]),
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
        style: TextStyle(color: Colors.white),
        decoration: new InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            focusColor: Colors.white,
            filled: false,
            hintStyle: new TextStyle(color: Colors.grey[800]),
            labelStyle: new TextStyle(color: Colors.grey[800]),
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
        style: TextStyle(color: Colors.white),
        decoration: new InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            focusColor: Colors.white,
            filled: false,
            hintStyle: new TextStyle(color: Colors.grey[800]),
            labelStyle: new TextStyle(color: Colors.grey[800]),
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
        style: TextStyle(color: Colors.white),
        decoration: new InputDecoration(
            suffixIcon: PeekPassword(
                onPressed: (bool peekPassword) => {
                      this.setState(() {
                        this._peekPassword = peekPassword;
                      })
                    }),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            focusColor: Colors.white,
            filled: false,
            hintStyle: new TextStyle(color: Colors.grey[800]),
            labelStyle: new TextStyle(color: Colors.grey[800]),
            hintText: "8 or more characters",
            labelText: "Password",
            fillColor: Colors.white70),
        obscureText: !_peekPassword,
        onSaved: (value) {
          this._requestData.password = value;
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
      )
    ];
  }
}
