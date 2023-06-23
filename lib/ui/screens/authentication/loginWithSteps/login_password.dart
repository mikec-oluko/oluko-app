import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/form_helper.dart';
import 'package:oluko_app/models/dto/login_request.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_back_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_secondary_button.dart';
import 'package:oluko_app/ui/screens/authentication/peek_password.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:global_configuration/global_configuration.dart';

class LoginPasswordPage extends StatefulWidget {
  LoginPasswordPage({Key key, this.requestData}) : super(key: key);
  String requestData;

  @override
  _LoginPasswordPageState createState() => _LoginPasswordPageState();
}

class _LoginPasswordPageState extends State<LoginPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  bool _peekPassword = false;
  LoginRequest request = LoginRequest();
  bool _isButtonEnabled = false;

  @override
  Widget build(BuildContext context) {
    return loginForm();
  }

  Widget loginForm() {
    return Form(
      key: _formKey,
      child: Scaffold(
        body: Container(
          color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
          child: ListView(
            physics: OlukoNeumorphism.listViewPhysicsEffect,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: false,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      const SizedBox(height: 70),
                      Align(
                        alignment: Alignment.topLeft,
                        child: OlukoNeumorphicCircleButton(onPressed: () => Navigator.pop(context)),
                      ),
                      const SizedBox(height: 25),
                      formSection()
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget formSection() {
    return Column(
      children: [
        //Text Fields
        Align(
          alignment: Alignment.topLeft,
          child: Text(OlukoLocalizations.get(context, 'password'), style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w400)),
        ),
        const SizedBox(
          height: 12,
        ),
        Text(OlukoLocalizations.get(context, 'loginSubtitle'), style: const TextStyle(color: Colors.grey)),
        const SizedBox(
          height: 45,
        ),
        TextFormField(
          style: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.bold, customColor: Colors.white),
          decoration: InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            suffixIcon: PeekPassword(
              onPressed: (bool peekPassword) => {
                setState(() {
                  _peekPassword = peekPassword;
                })
              },
            ),
            filled: false,
            errorStyle: const TextStyle(height: 0.5),
            hintStyle: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.bold, customColor: Colors.grey[800]),
            hintText: OlukoLocalizations.get(context, 'password').toLowerCase(),
            fillColor: Colors.white70,
          ),
          obscureText: !_peekPassword,
          onChanged: (value) {
            if (!_isButtonEnabled && value != null && value.isNotEmpty) {
              setState(() {
                _isButtonEnabled = true;
              });
            } else if (_isButtonEnabled && (value == null || value.isEmpty)) {
              setState(() {
                _isButtonEnabled = false;
              });
            }
          },
          onSaved: (value) {
            if (value != null && value.isNotEmpty) {
              value = value.trim();
            }
            if (FormHelper.isEmail(widget.requestData)) {
              request.email = widget.requestData;
            } else {
              request.userName = widget.requestData;
            }
            request.password = null;
            request.password = value;
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return OlukoLocalizations.get(context, 'required');
            }
            return null;
          },
        ),
        const SizedBox(
          height: 65,
        ),
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 150,
            height: 60,
            child: _isButtonEnabled
                ? OlukoNeumorphicPrimaryButton(
                    useBorder: true,
                    isExpanded: false,
                    thinPadding: true,
                    onPressed: () {
                      _formKey.currentState.save();
                      FocusScope.of(context).unfocus();
                      BlocProvider.of<AuthBloc>(context).login(
                        context,
                        LoginRequest(
                          email: request.email,
                          password: request.password,
                          userName: request.userName,
                          projectId: GlobalConfiguration().getString('projectId'),
                        ),
                      );
                    },
                    title: OlukoLocalizations.get(context, 'continue'),
                  )
                : OlukoNeumorphicSecondaryButton(
                    useBorder: true,
                    isExpanded: false,
                    isDisabled: true,
                    thinPadding: true,
                    textColor: Colors.grey[800],
                    title: OlukoLocalizations.get(context, 'continue'),
                    onPressed: () {}, //TODO: warn user it is disabled
                  ),
          ),
        ),
      ],
    );
  }
}
