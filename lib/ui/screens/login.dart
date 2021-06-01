import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/models/login_request.dart';
import 'package:oluko_app/models/sign_up_response.dart';
import 'package:oluko_app/ui/peek_password.dart';
import 'package:oluko_app/utils/app_loader.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
            AppLocalizations.of(context).welcomeBack,
            textAlign: TextAlign.start,
            style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(
            height: 10,
          ),
        ]));
  }

  List<Widget> formFields() {
    return [
      //Text Fields
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
            hintText: AppLocalizations.of(context).emailExample,
            fillColor: Colors.white70,
            labelText: AppLocalizations.of(context).email,
            labelStyle: new TextStyle(color: Colors.grey[800])),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppLocalizations.of(context).required;
          }
          return null;
        },
        onSaved: (value) {
          this._requestData.email = value;
        },
      ),
      SizedBox(
        height: 10,
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
            suffixIcon: PeekPassword(
                onPressed: (bool peekPassword) => {
                      this.setState(() {
                        this._peekPassword = peekPassword;
                      })
                    }),
            filled: false,
            errorStyle: TextStyle(height: 0.5),
            hintStyle: new TextStyle(color: Colors.grey[800]),
            labelStyle: new TextStyle(color: Colors.grey[800]),
            hintText: "8 ${AppLocalizations.of(context).maxChars}",
            labelText: AppLocalizations.of(context).password,
            fillColor: Colors.white70),
        obscureText: !_peekPassword,
        onSaved: (value) {
          this._requestData.password = value;
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppLocalizations.of(context).required;
          }
          return null;
        },
      ),
      //Forgot password?
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                child: Text(
                  AppLocalizations.of(context).forgotPassword,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.underline,
                    color: Colors.grey,
                  ),
                ),
                onTap: () {
                  _formKey.currentState.save();
                  BlocProvider.of<AuthBloc>(context)
                    ..sendPasswordResetEmail(
                        context,
                        LoginRequest(
                          email: _requestData.email,
                        ));
                },
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
                  onPressed: () {
                    _formKey.currentState.save();
                    AppLoader.startLoading(context);
                    BlocProvider.of<AuthBloc>(context)
                      ..login(
                          context,
                          LoginRequest(
                              email: _requestData.email,
                              password: _requestData.password));
                  },
                  child: Stack(children: [
                    Align(
                      child: Text(AppLocalizations.of(context).login),
                    )
                  ])))),
      Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Text(
            '- ${AppLocalizations.of(context).or} -',
            style: TextStyle(color: Colors.grey),
          )),
      //Login with SSO
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width / 2.2,
                child: OutlinedButton(
                    onPressed: () {
                      BlocProvider.of<AuthBloc>(context)
                        ..loginWithGoogle(context);
                    },
                    style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        side: BorderSide(color: Colors.grey)),
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
            padding: EdgeInsets.symmetric(vertical: 5),
            child: SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width / 2.2,
                child: OutlinedButton(
                    onPressed: () {
                      BlocProvider.of<AuthBloc>(context)
                        ..loginWithFacebook(context);
                    },
                    style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        side: BorderSide(color: Colors.grey)),
                    child: Stack(children: [
                      Align(
                        alignment: Alignment.center,
                        child: Image.network(
                          'https://cdn.icon-icons.com/icons2/1826/PNG/512/4202110facebooklogosocialsocialmedia-115707_115594.png',
                          width: 30,
                        ),
                      ),
                    ])))),
      ])
    ];
  }
}
