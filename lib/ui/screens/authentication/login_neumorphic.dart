import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/internet_connection_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/form_helper.dart';
import 'package:oluko_app/models/dto/forgot_password_dto.dart';
import 'package:oluko_app/models/dto/login_request.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_secondary_button.dart';
import 'package:oluko_app/ui/screens/authentication/peek_password.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/user_utils.dart';

class LoginNeumorphicPage extends StatefulWidget {
  LoginNeumorphicPage({this.dontShowWelcomeTest, Key key}) : super(key: key);
  bool dontShowWelcomeTest;

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
        height: ScreenUtils.height(context) * 0.07,
      ),
      TextFormField(
        style: OlukoFonts.olukoSuperBigFont(custoFontWeight: FontWeight.bold, customColor: Colors.white),
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
          hintStyle: OlukoFonts.olukoSuperBigFont(custoFontWeight: FontWeight.w500, customColor: Colors.white),
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
        style: OlukoFonts.olukoSuperBigFont(custoFontWeight: FontWeight.bold, customColor: Colors.white),
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
          hintStyle: OlukoFonts.olukoSuperBigFont(custoFontWeight: FontWeight.w500, customColor: Colors.white),
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
      Padding(
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
                  projectId: GlobalConfiguration().getValue('projectId'),
                ),
              );
            },
          ),
        ),
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
                projectId: GlobalConfiguration().getValue('projectId'),
              ),
            );
          },
          title: OlukoLocalizations.get(context, 'login'),
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
      //getExternalLoginButtons(),
      getOnlyGoogleButton(),
    ];
  }

  Widget getExternalLoginButtons() {
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
          SizedBox(height: ScreenUtils.height(context) * 0.25),
          Text(
            OlukoLocalizations.get(context, 'welcomeBack'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      );
    }
  }

  Widget getOnlyGoogleButton() {
    return SizedBox(
      width: ScreenUtils.width(context),
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
    );
  }
}
