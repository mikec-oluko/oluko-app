import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:oluko_app/BLoC/AuthBloc.dart';
import 'package:oluko_app/models/SignUpRequest.dart';
import 'package:oluko_app/models/SignUpResponse.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  SignUpRequest _requestData = SignUpRequest();
  SignUpResponse profileInfo;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getProfileInfo(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return signUpForm();
          } else {
            return SizedBox();
          }
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
                            titleSection(),
                            SizedBox(height: 75),
                            formSection()
                          ])))
                ]))));
  }

  Widget formSection() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 400,
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Column(children: formFields()),
        ]));
  }

  Widget titleSection() {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'Your profile',
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Your personal information',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w300),
          )
        ]));
  }

  List<Widget> formFields() {
    return [
      TextFormField(
        decoration: new InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
            ),
            filled: true,
            hintStyle: new TextStyle(color: Colors.grey[800]),
            hintText: "First Name",
            labelText: "First Name",
            fillColor: Colors.white70),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
        initialValue: this.profileInfo.firstName,
        enabled: false,
        onSaved: (value) {
          this._requestData.firstName = value;
        },
      ),
      TextFormField(
        decoration: new InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: const BorderRadius.only(),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: const BorderRadius.only(),
            ),
            filled: true,
            hintStyle: new TextStyle(color: Colors.grey[800]),
            hintText: "Last Name",
            labelText: "Last Name",
            fillColor: Colors.white70),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
        initialValue: this.profileInfo.lastName,
        enabled: false,
        onSaved: (value) {
          this._requestData.lastName = value;
        },
      ),
      TextFormField(
        decoration: new InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: const BorderRadius.only(),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: const BorderRadius.only(),
            ),
            filled: true,
            hintStyle: new TextStyle(color: Colors.grey[800]),
            hintText: "Your Email",
            labelText: "Email Address",
            fillColor: Colors.white70),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
        initialValue: this.profileInfo.email,
        enabled: false,
        onSaved: (value) {
          this._requestData.email = value;
        },
      ),
      TextFormField(
        decoration: new InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0),
              ),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0),
              ),
            ),
            filled: true,
            errorStyle: TextStyle(height: 0.5),
            hintStyle: new TextStyle(color: Colors.grey[800]),
            hintText: "8 or more characters",
            labelText: "Password",
            fillColor: Colors.white70),
        obscureText: true,
        onSaved: (value) {
          this._requestData.password = value;
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
        initialValue: 'samplePassword',
        enabled: false,
      )
    ];
  }

  handleError(AsyncSnapshot snapshot) {}

  handleResult(AsyncSnapshot snapshot) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      returnToHome();
    });
  }

  Future<void> getProfileInfo() async {
    profileInfo = SignUpResponse.fromJson(
        (await AuthBloc().retrieveLoginData()).toJson());
    return profileInfo;
  }

  Future<void> returnToHome() async {
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }
}
