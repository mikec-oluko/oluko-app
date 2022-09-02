import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/country_bloc.dart';
import 'package:oluko_app/blocs/sign_up_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/enums/register_fields_enum.dart';
import 'package:oluko_app/models/sign_up_request.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_register_textfield.dart';
import 'package:oluko_app/utils/app_validators.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/screen_utils.dart';
import 'package:global_configuration/global_configuration.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage() : super();
  @override
  State<RegisterPage> createState() => _RegisterState();
}

class _RegisterState extends State<RegisterPage> {
  bool _newsletterSettings = false;
  bool _agreeWithRequirements = false;
  final formKey = GlobalKey<FormState>();
  Map<ValidatorNames, bool> _passwordValidationState;
  SignUpRequest _newUserFromRegister = SignUpRequest();
  final Uri _mvtTermsAndConditionsUrl = Uri.parse('https://www.mvtfitnessapp.com/terms');
  final Uri _mvtPrivacyPolicyUrl = Uri.parse('https://www.mvtfitnessapp.com/privacy-policy');

  @override
  void initState() {
    BlocProvider.of<CountryBloc>(context).getAllCountries();
    _newUserFromRegister.projectId = GlobalConfiguration().getValue('projectId');
    _newUserFromRegister.country = '';
    _newUserFromRegister.state = '';
    _newUserFromRegister.city = '';
    _newUserFromRegister.newsletter = _newsletterSettings;

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
          alignment: Alignment.center,
          color: OlukoColors.white,
          child: ListView(
            shrinkWrap: true,
            children: [
              _defaultWidgetSpacer(context),
              _getSignUpText(context),
              _defaultWidgetSpacer(context),
              _textfieldsSection(),
              _passwordRequirementsSection(context),
              _defaultWidgetSpacer(context),
              _userCheckConditionsAndPolicySection(context),
              _defaultWidgetSpacer(context),
              _termsAndConditionsPrivacyPolicy(context),
              _defaultWidgetSpacer(context),
              _registerConfirmButton(context),
              _defaultWidgetSpacer(context),
            ],
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
          isDisabled: !_agreeWithRequirements,
          isExpanded: false,
          thinPadding: true,
          flatStyle: true,
          onPressed: !_agreeWithRequirements
              ? () {}
              : () {
                  validateAndSave();
                },
          title: OlukoLocalizations.get(context, 'letsGo'),
        ),
      ),
    );
  }

  Widget _termsAndConditionsPrivacyPolicy(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 2.5, 5, 0),
                  child: Container(
                    width: 15,
                    height: 15,
                    child: Container(width: 15, height: 15, child: checkBox()),
                  ),
                ),
                Text(
                  OlukoLocalizations.get(context, 'newsInfoAndOffers'),
                  // maxLines: 2,
                  style: OlukoFonts.olukoMediumFont(customFontWeight: FontWeight.w600, customColor: OlukoColors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  Widget _userCheckConditionsAndPolicySection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 2.5, 5, 0),
                  child: Container(
                    width: 15,
                    height: 15,
                    child: Container(width: 15, height: 15, child: checkBox(isAgree: true)),
                  ),
                ),
                Text(OlukoLocalizations.get(context, 'registerByContinuing'),
                    style: OlukoFonts.olukoMediumFont(customFontWeight: FontWeight.w600, customColor: OlukoColors.black)),
                InkWell(
                  onTap: () => _launchUrl(_mvtTermsAndConditionsUrl),
                  child: Text(OlukoLocalizations.get(context, 'termsAndConditions'),
                      style: OlukoFonts.olukoMediumFont(customFontWeight: FontWeight.w600, customColor: OlukoColors.primary)
                          .copyWith(decoration: TextDecoration.underline)),
                ),
                Text(OlukoLocalizations.get(context, 'and'),
                    style: OlukoFonts.olukoMediumFont(customFontWeight: FontWeight.w600, customColor: OlukoColors.black)),
                InkWell(
                  onTap: () => _launchUrl(_mvtPrivacyPolicyUrl),
                  child: Text(OlukoLocalizations.get(context, 'privacyPolicy'),
                      style: OlukoFonts.olukoMediumFont(customFontWeight: FontWeight.w600, customColor: OlukoColors.primary)
                          .copyWith(decoration: TextDecoration.underline)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Expanded _widgetSpacer() => const Expanded(child: SizedBox());

  Padding _passwordRequirementsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          _passwordRequirementsTitle(),
          _defaultWidgetSpacer(context, customHeight: ScreenUtils.height(context) * 0.01),
          _passwordRequirementsChecksList(context)
        ],
      ),
    );
  }

  Widget _passwordRequirementsChecksList(BuildContext context) {
    return Row(
      children: [
        _widgetSpacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _passwordRequirementsTile(
              evaluate: () => _containsMinChars(),
              errorText: OlukoLocalizations.get(context, 'passwordMinLength'),
            ),
            _passwordRequirementsTile(
              evaluate: () => _containsUppercase(),
              errorText: OlukoLocalizations.get(context, 'passwordUppercase'),
            ),
            _passwordRequirementsTile(
              evaluate: () => _containsDigit(),
              errorText: OlukoLocalizations.get(context, 'passwordNumberRequired'),
            ),
            _passwordRequirementsTile(
              evaluate: () => _containsLowercase(),
              errorText: OlukoLocalizations.get(context, 'passwordLowercase'),
            ),
          ],
        ),
        _widgetSpacer(),
      ],
    );
  }

  bool _containsMinChars() => _passwordValidationState[ValidatorNames.containsMinChars];

  bool _containsUppercase() => _passwordValidationState[ValidatorNames.containsUppercase];

  bool _containsDigit() => _passwordValidationState[ValidatorNames.containsDigit];

  bool _containsLowercase() => _passwordValidationState[ValidatorNames.containsLowercase] == true;

  Widget _passwordRequirementsTile({@required bool Function() evaluate, @required String errorText}) {
    return Container(
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Container(
              width: 15,
              height: 15,
              child: Stack(alignment: Alignment.center, children: [
                if (_passwordValidationState == null)
                  Container(
                      decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: OlukoColors.primary, width: 1),
                    borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                  )),
                if (_passwordValidationState != null)
                  Container(
                      decoration: BoxDecoration(
                    color: evaluate() ? OlukoColors.primary : Colors.transparent,
                    border: Border.all(color: evaluate() ? OlukoColors.primary : OlukoColors.error, width: 1),
                    borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                  )),
                if (_passwordValidationState != null && evaluate())
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
            errorText,
            style: OlukoFonts.olukoBigFont(
                customFontWeight: FontWeight.w600, customColor: _passwordValidationState == null || evaluate() ? OlukoColors.black : OlukoColors.error),
          ),
        ],
      ),
    );
  }

  Row _passwordRequirementsTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          OlukoLocalizations.get(context, 'passwordRequirements'),
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
      child: Center(
        child: Text(
          OlukoLocalizations.get(context, 'signUp'),
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
          OlukoRegisterTextfield(
              key: formKey,
              title: OlukoLocalizations.get(context, 'firstName'),
              fieldType: RegisterFieldEnum.FIRSTNAME,
              onInputUpdated: (value) {
                setState(() {
                  _newUserFromRegister.firstName = value;
                });
              }),
          OlukoRegisterTextfield(
              key: formKey,
              title: OlukoLocalizations.get(context, 'lastName'),
              fieldType: RegisterFieldEnum.LASTNAME,
              onInputUpdated: (value) {
                setState(() {
                  _newUserFromRegister.lastName = value;
                });
              }),
          OlukoRegisterTextfield(
              key: formKey,
              title: OlukoLocalizations.get(context, 'country'),
              fieldType: RegisterFieldEnum.COUNTRY,
              onInputUpdated: (value) {
                setState(() {
                  _newUserFromRegister.country = value;
                });
              }),
          OlukoRegisterTextfield(
              key: formKey,
              title: OlukoLocalizations.get(context, 'state'),
              fieldType: RegisterFieldEnum.STATE,
              onInputUpdated: (value) {
                setState(() {
                  _newUserFromRegister.state = value;
                });
              }),
          OlukoRegisterTextfield(
              key: formKey,
              title: OlukoLocalizations.get(context, 'city'),
              fieldType: RegisterFieldEnum.CITY,
              onInputUpdated: (value) {
                setState(() {
                  _newUserFromRegister.city = value;
                });
              }),
          OlukoRegisterTextfield(
              key: formKey,
              title: OlukoLocalizations.get(context, 'email'),
              fieldType: RegisterFieldEnum.EMAIL,
              onInputUpdated: (value) {
                setState(() {
                  _newUserFromRegister.email = value;
                });
              }),
          OlukoRegisterTextfield(
              key: formKey,
              title: OlukoLocalizations.get(context, 'username'),
              fieldType: RegisterFieldEnum.USERNAME,
              onInputUpdated: (value) {
                setState(() {
                  _newUserFromRegister.username = value;
                });
              }),
          OlukoRegisterTextfield(
            key: formKey,
            title: OlukoLocalizations.get(context, 'password'),
            fieldType: RegisterFieldEnum.PASSWORD,
            onInputUpdated: (value) {
              setState(() {
                _newUserFromRegister.password = value;
              });
            },
            onPasswordValidate: (passwordValidateState) => _passwordValidationStatus(passwordValidateState),
          ),
        ],
      ),
    );
  }

  void _passwordValidationStatus(Map<ValidatorNames, bool> passwordValidationState) {
    setState(() {
      _passwordValidationState = passwordValidationState;
    });
  }

  Future<void> validateAndSave() async {
    final FormState form = formKey.currentState;
    if (form.validate() && isPasswordValid()) {
      await BlocProvider.of<SignupBloc>(context).signUp(context, _newUserFromRegister);
    }
  }

  bool isPasswordValid() => (_containsMinChars() && _containsUppercase()) && (_containsDigit() && _containsLowercase());

  Widget checkBox({bool isAgree = false}) {
    return Theme(
      data: ThemeData(unselectedWidgetColor: OlukoColors.primary),
      child: Checkbox(
        checkColor: OlukoColors.black,
        activeColor: Colors.white,
        value: isAgree ? _agreeWithRequirements : _newsletterSettings,
        onChanged: (bool value) {
          setState(() {
            if (isAgree) {
              _agreeWithRequirements = value;
            } else {
              _newsletterSettings = value;
            }
          });
        },
      ),
    );
  }
}
