import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/sign_up_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/sign_up_request.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/screens/authentication/peek_password.dart';
import 'package:oluko_app/utils/app_loader.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/utils/app_validators.dart';

class SignUpWithMailPage extends StatefulWidget {
  SignUpWithMailPage({Key key}) : super(key: key);

  @override
  _SignUpWithMailPageState createState() => _SignUpWithMailPageState();
}

class _SignUpWithMailPageState extends State<SignUpWithMailPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => SignupBloc(), child: SignUpWithMailContentPage());
  }
}

class SignUpWithMailContentPage extends StatefulWidget {
  SignUpWithMailContentPage({Key key}) : super(key: key);

  @override
  _SignUpWithMailContentPageState createState() => _SignUpWithMailContentPageState();
}

class _SignUpWithMailContentPageState extends State<SignUpWithMailContentPage> {
  final _formKey = GlobalKey<FormState>();
  SignUpRequest _requestData = SignUpRequest(projectId: GlobalConfiguration().getString('projectId'));
  PasswordStrength passwordStrength;
  bool _peekPassword = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupBloc, UserState>(
      builder: (context, UserState state) {
        return signUpForm();
      },
    );
  }

  Widget signUpForm() {
    return Form(
      key: _formKey,
      child: Scaffold(
        body: Container(
          color: OlukoColors.black,
          child: ListView(
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: false,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      titleSection(),
                      SizedBox(height: 30),
                      //Login with SSO
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: SizedBox(
                              height: 50,
                              width: MediaQuery.of(context).size.width / 2.2,
                              child: OutlinedButton(
                                onPressed: () {
                                  BlocProvider.of<AuthBloc>(context).loginWithGoogle(context);
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  side: BorderSide(color: Colors.grey),
                                ),
                                child: Stack(
                                  children: [
                                    const Align(
                                      alignment: Alignment.center,
                                      child: Image(
                                        image: CachedNetworkImageProvider('https://img.icons8.com/color/452/google-logo.png'),
                                        width: 30,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: SizedBox(
                              height: 50,
                              width: MediaQuery.of(context).size.width / 2.2,
                              child: OutlinedButton(
                                onPressed: () {
                                  BlocProvider.of<AuthBloc>(context)..loginWithFacebook(context);
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  side: BorderSide(color: Colors.grey),
                                ),
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: CachedNetworkImage(
                                        imageUrl: 'https://cdn.icon-icons.com/icons2/1826/PNG/512/4202110facebooklogosocialsocialmedia-115707_115594.png',
                                        width: 30,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      formSection()
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget formSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 600,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(height: 350, child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: formFields())),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: BlocBuilder<SignupBloc, UserState>(
              builder: (context, state) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: OlukoColors.primary),
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      SignupBloc()..signUp(context, _requestData);
                    }
                  },
                  child: Stack(
                    children: [
                      Align(
                        child: Text('SIGN UP'),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          InkWell(
            onTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.logInUsername]),
            child: Padding(
              padding: EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Text(
                    'Already a subscribed user?',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text('Log In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget titleSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome',
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
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
          fillColor: Colors.white70,
        ),
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
          fillColor: Colors.white70,
        ),
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
          hintText: "Username",
          labelText: "Username",
          fillColor: Colors.white70,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
        onSaved: (value) {
          this._requestData.username = value;
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
          fillColor: Colors.white70,
        ),
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
            },
          ),
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
          fillColor: Colors.white70,
        ),
        obscureText: !_peekPassword,
        onChanged: (value) => this.setState(() {
          this.passwordStrength = AppValidators().validatePassword(value);
        }),
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
      LinearProgressIndicator(
        value: getPasswordStrengthLength(passwordStrength),
        valueColor: new AlwaysStoppedAnimation<Color>(getPasswordStrengthColor(passwordStrength)),
        backgroundColor: Colors.grey.shade700,
      ),
      Text(
        getPasswordStrengthLabel(passwordStrength),
        style: TextStyle(color: Colors.white),
      )
    ];
  }

  Color getPasswordStrengthColor(PasswordStrength passwordStrength) {
    switch (passwordStrength) {
      case PasswordStrength.weak:
        return Colors.red;
        break;
      case PasswordStrength.medium:
        return Colors.amber;
        break;
      case PasswordStrength.strong:
        return Colors.green;
        break;
      default:
        return Colors.transparent;
        break;
    }
  }

  String getPasswordStrengthLabel(PasswordStrength passwordStrength) {
    switch (passwordStrength) {
      case PasswordStrength.weak:
        return 'Weak';
        break;
      case PasswordStrength.medium:
        return 'Medium';
        break;

      case PasswordStrength.strong:
        return 'Strong';
        break;
      default:
        return '';
        break;
    }
  }

  double getPasswordStrengthLength(PasswordStrength passwordStrength) {
    switch (passwordStrength) {
      case PasswordStrength.weak:
        return 0.25;
        break;
      case PasswordStrength.medium:
        return 0.50;
        break;
      case PasswordStrength.strong:
        return 1;
        break;
      default:
        return 0;
        break;
    }
  }
}
