import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/form_helper.dart';
import 'package:oluko_app/models/dto/forgot_password_dto.dart';
import 'package:oluko_app/models/dto/login_request.dart';
import 'package:oluko_app/ui/screens/authentication/peek_password.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:global_configuration/global_configuration.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final LoginRequest _requestData = LoginRequest();
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
                color: OlukoColors.black,
                child: ListView(addAutomaticKeepAlives: false, addRepaintBoundaries: false, children: [
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(children: [SizedBox(height: 20), SizedBox(height: 20), titleSection(), SizedBox(height: 50), formSection()])))
                ]))));
  }

  Widget formSection() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 400,
        child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Column(children: formFields()),
        ]));
  }

  Widget titleSection() {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            OlukoLocalizations.get(context, 'welcomeBack'),
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
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
        decoration: InputDecoration(
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
            hintText: OlukoLocalizations.get(context, 'emailExample'),
            fillColor: Colors.white70,
            labelText: OlukoLocalizations.get(context, 'usernameOrEmail'),
            labelStyle: new TextStyle(color: Colors.grey[800])),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return OlukoLocalizations.get(context, 'required');
          }
          return null;
        },
        onSaved: (value) {
          this._requestData.email = null;
          this._requestData.userName = null;
          if (FormHelper.isEmail(value)) {
            this._requestData.email = value;
          } else {
            this._requestData.userName = value;
          }
        },
      ),
      const SizedBox(
        height: 10,
      ),
      TextFormField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
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
            errorStyle: const TextStyle(height: 0.5),
            hintStyle: TextStyle(color: Colors.grey[800]),
            labelStyle: TextStyle(color: Colors.grey[800]),
            hintText: "8 ${OlukoLocalizations.get(context, 'maxChars')}",
            labelText: OlukoLocalizations.get(context, 'password'),
            fillColor: Colors.white70),
        obscureText: !_peekPassword,
        onSaved: (value) {
          this._requestData.password = null;
          this._requestData.password = value;
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return OlukoLocalizations.get(context, 'required');
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
                  OlukoLocalizations.get(context, 'forgotPassword'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.underline,
                    color: Colors.grey,
                  ),
                ),
                onTap: () {
                  _formKey.currentState.save();
                  BlocProvider.of<AuthBloc>(context).sendPasswordResetEmail(
                    context,
                    ForgotPasswordDto(
                      email: _requestData.email,
                      projectId: GlobalConfiguration().getString('projectId'),
                    ),
                  );
                },
              ))),
      //Login button
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: OlukoColors.primary),
                  onPressed: () {
                    _formKey.currentState.save();
                    FocusScope.of(context).unfocus();
                    BlocProvider.of<AuthBloc>(context).login(
                        context,
                        LoginRequest(
                            email: _requestData.email,
                            password: _requestData.password,
                            userName: _requestData.userName,
                            projectId: GlobalConfiguration().getString('projectId')));
                  },
                  child: Stack(children: [
                    Align(
                      child: Text(OlukoLocalizations.get(context, 'login').toUpperCase()),
                    )
                  ])))),
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Text(
            '- ${OlukoLocalizations.get(context, 'or')} -',
            style: const TextStyle(color: Colors.grey),
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
                      BlocProvider.of<AuthBloc>(context).loginWithGoogle(context);
                    },
                    style: OutlinedButton.styleFrom(backgroundColor: Colors.transparent, side: BorderSide(color: Colors.grey)),
                    child: Stack(children: [
                      Align(
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/login/google-logo.png',
                          width: 25,
                          color: Colors.white,
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
                      BlocProvider.of<AuthBloc>(context).loginWithFacebook(context);
                    },
                    style: OutlinedButton.styleFrom(backgroundColor: Colors.transparent, side: BorderSide(color: Colors.grey)),
                    child: Stack(children: [
                      Align(
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/login/facebook-logo.png',
                            width: 30,
                          )),
                    ])))),
      ]),
    ];
  }
}
