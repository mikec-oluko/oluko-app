import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/internet_connection_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/form_helper.dart';
import 'package:oluko_app/models/dto/forgot_password_dto.dart';
import 'package:oluko_app/models/dto/login_request.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_secondary_button.dart';
import 'package:oluko_app/ui/screens/authentication/peek_password.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class LoginNeumorphicPage extends StatefulWidget {
  LoginNeumorphicPage({this.dontShowWelcomeTest, this.userDeleted = false, Key key}) : super(key: key);
  bool dontShowWelcomeTest;
  bool userDeleted;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginNeumorphicPage> {
  final _formKey = GlobalKey<FormState>();
  final LoginRequest _requestData = LoginRequest();
  bool _peekPassword = false;
  DateTime pre_backpress = DateTime.now();

  @override
  void initState() {
    BlocProvider.of<InternetConnectionBloc>(context).getConnectivityType();
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (widget.userDeleted) {
        deletionInstructionsPopUp(context);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loginForm();
  }

  Widget loginForm() {
    return Form(
      key: _formKey,
      child: WillPopScope(
        onWillPop: () async {
          final timegap = DateTime.now().difference(pre_backpress);
          final cantExit = timegap >= Duration(seconds: 2);
          pre_backpress = DateTime.now();
          if (cantExit) {
            AppMessages.clearAndShowSnackbarTranslated(context, 'exitOnButtonBack');
            return false;
          } else {
            SystemNavigator.pop();
            return true;
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6.0)),
              image: DecorationImage(
                image: AssetImage('assets/login/login_neumorphic_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: ListView(
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(children: formFields()),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> formFields() {
    return [
      getWelcomeText(),
      SizedBox(
        height: ScreenUtils.height(context) * 0.04,
      ),
      TextFormField(
        style: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.bold, customColor: Colors.white),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 3, color: OlukoColors.primary),
            borderRadius: BorderRadius.circular(40),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 3, color: OlukoColors.primary),
            borderRadius: BorderRadius.circular(40),
          ),
          filled: true,
          hintStyle: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.w500, customColor: Colors.white),
          hintText: OlukoLocalizations.get(context, 'emailOrUsername').toLowerCase(),
          fillColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
        ),
        cursorColor: Colors.white,
        onSaved: (value) {
          _requestData.email = null;
          _requestData.userName = null;
          if (FormHelper.isEmail(value)) {
            _requestData.email = value.trim();
          } else {
            _requestData.userName = value.trim();
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return OlukoLocalizations.get(context, 'required');
          }
          return null;
        },
      ),
      const SizedBox(
        height: 10,
      ),
      TextFormField(
        style: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.bold, customColor: Colors.white),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          suffixIcon: PeekPassword(
            onPressed: (bool peekPassword) => {
              setState(() {
                _peekPassword = peekPassword;
              })
            },
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 3, color: OlukoColors.primary),
            borderRadius: BorderRadius.circular(40),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 3, color: OlukoColors.primary),
            borderRadius: BorderRadius.circular(40),
          ),
          filled: true,
          errorStyle: const TextStyle(height: 0.5),
          hintStyle: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.w500, customColor: Colors.white),
          hintText: OlukoLocalizations.get(context, 'password').toLowerCase(),
          fillColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
        ),
        obscureText: !_peekPassword,
        cursorColor: Colors.white,
        onSaved: (value) {
          if (value != null && value.isNotEmpty) {
            value = value.trim();
          }
          _requestData.password = null;
          _requestData.password = value;
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return OlukoLocalizations.get(context, 'required');
          }
          return null;
        },
      ),
      BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthResetPassLoading) {
            return Align(
              alignment: Alignment.centerRight,
              child: Padding(
                  padding: EdgeInsets.only(top: 20, right: 20),
                  child: Container(height: 15, width: 15, child: OlukoCircularProgressIndicator(personalized: true, width: 2))),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  child: Text(
                    OlukoLocalizations.get(context, 'forgotPassword'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                ),
              ),
            );
          }
        },
      ),
      const SizedBox(
        height: 20,
      ),
      SizedBox(
        height: 50,
        child: OlukoNeumorphicPrimaryButton(
          useBorder: true,
          isExpanded: false,
          thinPadding: true,
          onPressed: () {
            _formKey.currentState.save();
            FocusScope.of(context).unfocus();
            BlocProvider.of<AuthBloc>(context).login(
              context,
              LoginRequest(
                email: _requestData.email,
                password: _requestData.password,
                userName: _requestData.userName,
                projectId: GlobalConfiguration().getString('projectId'),
              ),
            );
          },
          title: OlukoLocalizations.get(context, 'login'),
        ),
      ),
      if (Platform.isIOS || Platform.isMacOS)
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: SizedBox(
            height: 50,
            child: OlukoNeumorphicPrimaryButton(
              useBorder: true,
              isExpanded: false,
              thinPadding: true,
              onPressed: () {
                Navigator.pushNamed(context, routeLabels[RouteEnum.registerUser]);
              },
              title: OlukoLocalizations.get(context, 'register'),
            ),
          ),
        ),
      const SizedBox(
        height: 15,
      ),
      SizedBox(
        width: ScreenUtils.width(context),
        child: Row(children: [
          Expanded(
            child: Image.asset(
              'assets/login/line.png',
            ),
          ),
          Text(
            OlukoLocalizations.get(context, 'or').toUpperCase(),
            style: OlukoFonts.olukoMediumFont(customColor: Colors.white),
          ),
          Expanded(
            child: Image.asset(
              'assets/login/line.png',
            ),
          )
        ]),
      ),
      const SizedBox(
        height: 15,
      ),
      //getExternalLoginButtonsWithFacebook(),
      SizedBox(
        width: ScreenUtils.width(context),
        child: getExternalLoginButtons(),
      ),
    ];
  }

  Widget getExternalLoginButtonsWithFacebook() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      SizedBox(
        width: 120,
        height: 50,
        child: OlukoNeumorphicSecondaryButton(
          title: '',
          useBorder: true,
          isExpanded: false,
          thinPadding: true,
          onlyIcon: true,
          onPressed: () {
            BlocProvider.of<AuthBloc>(context).loginWithFacebook(context);
          },
          icon: Align(
              child: Image.asset(
            'assets/login/facebook-logo.png',
            width: 30,
          )),
        ),
      ),
      const SizedBox(width: 35),
      SizedBox(
        width: 120,
        height: 50,
        child: OlukoNeumorphicSecondaryButton(
          title: '',
          useBorder: true,
          isExpanded: false,
          thinPadding: true,
          onlyIcon: true,
          onPressed: () {
            BlocProvider.of<AuthBloc>(context).loginWithGoogle(context);
          },
          icon: Align(
            child: Image.asset(
              'assets/login/google-logo.png',
              width: 25,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ]);
  }

  Widget getWelcomeText() {
    if (widget.dontShowWelcomeTest != null && widget.dontShowWelcomeTest == true) {
      return SizedBox(height: ScreenUtils.height(context) * 0.25);
    } else {
      return Column(
        children: [
          SizedBox(height: ScreenUtils.height(context) * 0.22),
          Text(
            OlukoLocalizations.get(context, 'welcomeBack'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      );
    }
  }

  Widget getExternalLoginButtons() {
    final Widget googleButton = SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(OlukoColors.white),
        ),
        onPressed: () => BlocProvider.of<AuthBloc>(context).loginWithGoogle(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/login/google-logo.png',
              width: 20,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              OlukoLocalizations.get(context, 'continueWithGoogle'),
              style: const TextStyle(color: OlukoColors.grayColor),
            )
          ],
        ),
      ),
    );

    if (Platform.isIOS || Platform.isMacOS) {
      return Column(
        children: [
          googleButton,
          const SizedBox(
            height: 5,
          ),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(OlukoColors.black),
              ),
              onPressed: () => BlocProvider.of<AuthBloc>(context).continueWithApple(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/login/apple-logo.png',
                    width: 18,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    OlukoLocalizations.get(context, 'continueWithApple'),
                    style: const TextStyle(color: OlukoColors.white),
                  )
                ],
              ),
            ),
          )
        ],
      );
    } else {
      return Column(
        children: [
          googleButton,
        ],
      );
    }
  }

  Future<void> deletionInstructionsPopUp(BuildContext context) async {
    bool result = true;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: OlukoColors.black,
        content: Text(
          OlukoLocalizations.get(context, 'deletionInstructions'),
          style: OlukoFonts.olukoBigFont(),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              OlukoLocalizations.get(context, 'ok'),
            ),
          ),
        ],
      ),
    );
  }
}
