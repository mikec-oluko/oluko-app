import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/dto/forgot_password_dto.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_back_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_secondary_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class LoginUsernamePage extends StatefulWidget {
  LoginUsernamePage({Key key}) : super(key: key);

  @override
  _LoginUsernamePageState createState() => _LoginUsernamePageState();
}

class _LoginUsernamePageState extends State<LoginUsernamePage> {
  final _formKey = GlobalKey<FormState>();
  String data;
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
                      Align(alignment: Alignment.topLeft, child: OlukoNeumorphicCircleButton(onPressed: () => Navigator.pop(context))),
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
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(OlukoLocalizations.get(context, 'usernameOrEmail'), style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w400)),
        ),
        const SizedBox(height: 12),
        Text(OlukoLocalizations.get(context, 'loginSubtitle'), style: OlukoFonts.olukoMediumFont(customColor: Colors.grey)),
        const SizedBox(
          height: 45,
        ),
        TextFormField(
          style: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.bold, customColor: Colors.white),
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
          decoration: InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            hintStyle: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.bold, customColor: Colors.grey[800]),
            hintText: OlukoLocalizations.get(context, 'usernameOrEmail').toLowerCase(),
            fillColor: Colors.white70,
          ),
          onSaved: (value) {
            data = null;
            if (value != null && value.isNotEmpty) {
              data = value.trim();
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
          height: 65,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 150,
              height: 60,
              child: _isButtonEnabled
                  ? OlukoNeumorphicPrimaryButton(
                      useBorder: true,
                      isExpanded: false,
                      isDisabled: true,
                      thinPadding: true,
                      onPressed: () {
                        _formKey.currentState.save();
                        FocusScope.of(context).unfocus();
                        Navigator.pushNamed(context, routeLabels[RouteEnum.logInPassword], arguments: {'requestData': data});
                      },
                      title: OlukoLocalizations.get(context, 'continue'),
                    )
                  : OlukoNeumorphicSecondaryButton(
                      useBorder: true,
                      isDisabled: true,
                      isExpanded: false,
                      thinPadding: true,
                      textColor: Colors.grey[800],
                      title: OlukoLocalizations.get(context, 'continue'),
                      onPressed: () {}, //TODO: warn user it is disabled
                    ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: InkWell(
                child: Text(
                  OlukoLocalizations.get(context, 'forgotPassword'),
                  style: OlukoFonts.olukoMediumFont(customColor: Colors.grey),
                ),
                onTap: () {
                  _formKey.currentState.save();
                  BlocProvider.of<AuthBloc>(context).sendPasswordResetEmail(
                    context,
                    ForgotPasswordDto(email: data, projectId: GlobalConfiguration().getString('projectId')),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
