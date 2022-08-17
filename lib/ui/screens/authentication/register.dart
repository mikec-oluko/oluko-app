import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/country_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/enums/register_fields_enum.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_register_textfield.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import '../../../utils/screen_utils.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage() : super();

  @override
  State<RegisterPage> createState() => _RegisterState();
}

class _RegisterState extends State<RegisterPage> {
  final bool _tempCheck = true;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    BlocProvider.of<CountryBloc>(context).getAllCountries();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: OlukoAppBar(
          showActions: false,
          showLogo: true,
          reduceHeight: true,
          onPressed: () {
            Navigator.pop(context);
          },
          showTitle: false,
          showBackButton: false,
          title: '',
          actions: [],
        ),
        body: Container(
          color: OlukoColors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _defaultWidgetSpacer(context),
                _getSignUpText(context),
                _defaultWidgetSpacer(context),
                _textfieldsSection(),
                _defaultWidgetSpacer(context, customHeight: ScreenUtils.height(context) * 0.02),
                _passwordRequirementsSection(context),
                _defaultWidgetSpacer(context),
                _userCheckConditionsAndPolicySection(context),
                _defaultWidgetSpacer(context),
                _registerConfirmButton(context),
                _defaultWidgetSpacer(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding _registerConfirmButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtils.width(context) / 4),
      child: Container(
        width: 150,
        height: 60,
        child: OlukoNeumorphicPrimaryButton(
          isExpanded: false,
          thinPadding: true,
          onPressed: () {
            validateAndSave();
          },
          title: 'Lets Go',
        ),
      ),
    );
  }

  Padding _userCheckConditionsAndPolicySection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Container(width: 15, height: 15, child: checkBox()),
              ),
              Text(
                'I agree to Terms And Conditions and Privacy Policy',
                style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w300, customColor: OlukoColors.black),
              ),
            ],
          ),
          _defaultWidgetSpacer(context, customHeight: ScreenUtils.height(context) * 0.02),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Container(
                  width: 15,
                  height: 15,
                  child: Container(width: 15, height: 15, child: checkBox()),
                ),
              ),
              Text(
                'Sign up for MVT Fitness news, info and offers.',
                style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w300, customColor: OlukoColors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Padding _passwordRequirementsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          _passwordRequirementsTitle(),
          _defaultWidgetSpacer(context, customHeight: ScreenUtils.height(context) * 0.02),
          _passwordRequirementsChecksList(context)
        ],
      ),
    );
  }

  Column _passwordRequirementsChecksList(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Container(
                    width: 15,
                    height: 15,
                    child: Stack(alignment: Alignment.center, children: [
                      Image.asset(
                        _tempCheck ? 'assets/assessment/neumorphic_green_circle.png' : 'assets/assessment/neumorphic_green_outlined.png',
                        scale: 4,
                      ),
                      if (_tempCheck)
                        Image.asset(
                          'assets/assessment/neumorphic_check.png',
                          scale: 4,
                        )
                      else
                        const SizedBox.shrink()
                    ]),
                  ),
                ),
                Text(
                  '8 or more characters',
                  style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w300, customColor: OlukoColors.black),
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Container(
                    width: 15,
                    height: 15,
                    child: Stack(alignment: Alignment.center, children: [
                      Image.asset(
                        _tempCheck ? 'assets/assessment/neumorphic_green_circle.png' : 'assets/assessment/neumorphic_green_outlined.png',
                        scale: 4,
                      ),
                      if (_tempCheck)
                        Image.asset(
                          'assets/assessment/neumorphic_check.png',
                          scale: 4,
                        )
                      else
                        const SizedBox.shrink()
                    ]),
                  ),
                ),
                Text(
                  'At least 1 uppercase letter',
                  style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w300, customColor: OlukoColors.black),
                ),
              ],
            ),
          ],
        ),
        _defaultWidgetSpacer(context, customHeight: ScreenUtils.height(context) * 0.01),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Container(
                    width: 15,
                    height: 15,
                    child: Stack(alignment: Alignment.center, children: [
                      Image.asset(
                        _tempCheck ? 'assets/assessment/neumorphic_green_circle.png' : 'assets/assessment/neumorphic_green_outlined.png',
                        scale: 4,
                      ),
                      if (_tempCheck)
                        Image.asset(
                          'assets/assessment/neumorphic_check.png',
                          scale: 4,
                        )
                      else
                        const SizedBox.shrink()
                    ]),
                  ),
                ),
                Text(
                  'At least one number',
                  style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w300, customColor: OlukoColors.black),
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Container(
                    width: 15,
                    height: 15,
                    child: Stack(alignment: Alignment.center, children: [
                      Image.asset(
                        _tempCheck ? 'assets/assessment/neumorphic_green_circle.png' : 'assets/assessment/neumorphic_green_outlined.png',
                        scale: 4,
                      ),
                      if (!_tempCheck)
                        Image.asset(
                          'assets/assessment/neumorphic_check.png',
                          scale: 4,
                        )
                      else
                        const SizedBox.shrink()
                    ]),
                  ),
                ),
                Text(
                  'At least 1 lowercase letter',
                  style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w300, customColor: OlukoColors.black),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }

  Row _passwordRequirementsTitle() {
    return Row(
      children: [
        Text(
          'Password Requirements',
          style: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.w600, customColor: OlukoColors.primary),
        )
      ],
    );
  }

  Padding _textfieldsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: _registerInputFields(),
    );
  }

  Widget _defaultWidgetSpacer(BuildContext context, {double customHeight}) =>
      SizedBox(width: ScreenUtils.width(context), height: customHeight ?? ScreenUtils.height(context) * 0.03);

  Container _getSignUpText(BuildContext context) {
    return Container(
      width: ScreenUtils.width(context),
      height: ScreenUtils.height(context) * 0.08,
      // color: OlukoColors.coral,
      child: Center(
        child: Text(
          'Sign up',
          style: OlukoFonts.olukoBiggestFont(customFontWeight: FontWeight.w600, customColor: OlukoColors.black),
        ),
      ),
    );
  }

  Widget _registerInputFields() {
    return Form(
      key: formKey,
      child: Column(
        children: [
          OlukoRegisterTextfield(key: formKey, title: OlukoLocalizations.get(context, 'username'), fieldType: RegisterFieldEnum.USERNAME),
          OlukoRegisterTextfield(key: formKey, title: OlukoLocalizations.get(context, 'firstName'), fieldType: RegisterFieldEnum.FIRSTNAME),
          OlukoRegisterTextfield(key: formKey, title: OlukoLocalizations.get(context, 'lastName'), fieldType: RegisterFieldEnum.LASTNAME),
          OlukoRegisterTextfield(key: formKey, title: OlukoLocalizations.get(context, 'country'), fieldType: RegisterFieldEnum.COUNTRY),
          OlukoRegisterTextfield(key: formKey, title: OlukoLocalizations.get(context, 'state'), fieldType: RegisterFieldEnum.STATE),
          OlukoRegisterTextfield(key: formKey, title: OlukoLocalizations.get(context, 'city'), fieldType: RegisterFieldEnum.CITY),
          OlukoRegisterTextfield(key: formKey, title: OlukoLocalizations.get(context, 'email'), fieldType: RegisterFieldEnum.EMAIL),
          OlukoRegisterTextfield(key: formKey, title: OlukoLocalizations.get(context, 'password'), fieldType: RegisterFieldEnum.PASSWORD),
        ],
      ),
    );
  }

  void validateAndSave() {
    final FormState form = formKey.currentState;
    if (form.validate()) {
      print('Form is valid');
    } else {
      print('Form is invalid');
    }
  }

  Widget checkBox() {
    return Theme(
      data: ThemeData(unselectedWidgetColor: OlukoColors.primary),
      child: Checkbox(
        checkColor: OlukoColors.primary,
        activeColor: Colors.transparent,
        value: !_tempCheck,
        onChanged: (bool value) {
          setState(() {
            // _tempCheck = value;
          });
          // widget.onShowAgainPressed();
        },
      ),
    );
  }
}
