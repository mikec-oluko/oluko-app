import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:oluko_app/models/sign-up-request.dart';
import 'package:oluko_app/models/sign-up-response.dart';
import 'package:oluko_app/services/login-service.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  SignUpRequest _requestData = SignUpRequest();
  SignUpResponse profileInfo;
  @override
  Widget build(BuildContext context) {
    return loginForm();
  }

  Widget loginForm() {
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
                            SizedBox(height: 50),
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
            'Login',
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Login with your Email',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w300),
          )
        ]));
  }

  List<Widget> formFields() {
    return [
      //Text Fields
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
            hintText: "example@yourcompany.com",
            labelText: "Email",
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
      ),
      //Forgot password?
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Forgot Password?',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
              ))),
      //Login button
      Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(primary: Colors.brown.shade300),
                  onPressed: () =>
                      Navigator.pushNamed(context, '/sign-up-with-email'),
                  child: Stack(children: [
                    Align(
                        alignment: Alignment.centerRight,
                        child: Icon(Icons.navigate_next)),
                    Align(
                      child: Text('LOG IN'),
                    )
                  ])))),
      Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Text('- Or you can also -')),
      //Login with SSO
      Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                  onPressed: () {},
                  style:
                      OutlinedButton.styleFrom(backgroundColor: Colors.white),
                  child: Stack(children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Image.network(
                        'https://img.icons8.com/color/452/google-logo.png',
                        width: 30,
                      ),
                    ),
                    Align(
                      child: Text('Log In with Google',
                          style: TextStyle(color: Colors.black)),
                    )
                  ])))),
      Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                  onPressed: () {},
                  style:
                      OutlinedButton.styleFrom(backgroundColor: Colors.white),
                  child: Stack(children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Image.network(
                        'https://cdn.icon-icons.com/icons2/1826/PNG/512/4202110facebooklogosocialsocialmedia-115707_115594.png',
                        width: 30,
                      ),
                    ),
                    Align(
                      child: Text('Log In with Facebook',
                          style: TextStyle(color: Colors.black)),
                    )
                  ])))),
    ];
  }

  handleError(AsyncSnapshot snapshot) {}

  handleResult(AsyncSnapshot snapshot) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      returnToHome();
    });
  }

  Future<void> getProfileInfo() async {
    profileInfo = await LoginService.retrieveLoginData();
    return profileInfo;
  }

  Future<void> returnToHome() async {
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }
}
