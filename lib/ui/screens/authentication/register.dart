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
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_secondary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_register_textfield.dart';
import 'package:oluko_app/ui/newDesignComponents/terms_and_conditions_privacy_policy_component.dart';
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

  @override
  void initState() {
    BlocProvider.of<CountryBloc>(context).getAllCountries();
    _newUserFromRegister.projectId = GlobalConfiguration().getString('projectId');
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
        backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
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
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Container(
            alignment: Alignment.center,
            color: OlukoColors.white,
            child: ListView(
              physics: OlukoNeumorphism.listViewPhysicsEffect,
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false,
              shrinkWrap: true,
              children: [
                _defaultWidgetSpacer(context),
                _getSignUpText(context),
                _defaultWidgetSpacer(context),
                _textfieldsSection(),
                _passwordRequirementsSection(context),
                _defaultWidgetSpacer(context),
                _termsAndConditionsPrivacyPolicy(),
                _mvtNewsInfoAndOffers(context),
                _defaultWidgetSpacer(context),
                _registerConfirmButton(context),
                _registerCancelButton(context),
                _defaultWidgetSpacer(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TermsAndConditionsPrivacyPolicyComponent _termsAndConditionsPrivacyPolicy() {
    return TermsAndConditionsPrivacyPolicyComponent(
      currentValue: _agreeWithRequirements,
      onPressed: (value) => agreeWithTermsAndConditions(value),
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

  Padding _registerCancelButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtils.width(context) / 4, vertical: 10),
      child: Center(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(OlukoLocalizations.get(context, 'cancel'), style: OlukoFonts.olukoBigFont(customColor: OlukoColors.primary)),
        ),
      ),
    );
  }

  Widget _mvtNewsInfoAndOffers(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Theme(
          data: ThemeData(
            unselectedWidgetColor: OlukoColors.primary,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: CheckboxListTile(
                value: _newsletterSettings,
                contentPadding: EdgeInsets.zero,
                checkColor: OlukoColors.black,
                activeColor: Colors.white,
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                title: Transform.translate(
                  offset: const Offset(-20, 0),
                  child: Text(
                    OlukoLocalizations.get(context, 'newsInfoAndOffers'),
                    style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w600, customColor: OlukoColors.black),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _newsletterSettings = value;
                    _newUserFromRegister.newsletter = value;
                  });
                }),
          ),
        ));
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

  Widget _passwordRequirementsTile({@required bool Function() evaluate, @required String errorText}) {
    return Container(
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
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
                  _newUserFromRegister.firstName = _getValue(value);
                });
              }),
          OlukoRegisterTextfield(
              key: formKey,
              title: OlukoLocalizations.get(context, 'lastName'),
              fieldType: RegisterFieldEnum.LASTNAME,
              onInputUpdated: (value) {
                setState(() {
                  _newUserFromRegister.lastName = _getValue(value);
                });
              }),
          OlukoRegisterTextfield(
              key: formKey,
              title: OlukoLocalizations.get(context, 'country'),
              fieldType: RegisterFieldEnum.COUNTRY,
              onInputUpdated: (value) {
                setState(() {
                  _newUserFromRegister.country = _getValue(value);
                });
              }),
          OlukoRegisterTextfield(
              key: formKey,
              title: OlukoLocalizations.get(context, 'state'),
              fieldType: RegisterFieldEnum.STATE,
              onInputUpdated: (value) {
                setState(() {
                  _newUserFromRegister.state = _getValue(value);
                });
              }),
          OlukoRegisterTextfield(
              key: formKey,
              title: OlukoLocalizations.get(context, 'city'),
              fieldType: RegisterFieldEnum.CITY,
              onInputUpdated: (value) {
                setState(() {
                  _newUserFromRegister.city = _getValue(value);
                });
              }),
          OlukoRegisterTextfield(
              key: formKey,
              title: OlukoLocalizations.get(context, 'zipCode'),
              fieldType: RegisterFieldEnum.ZIPCODE,
              onInputUpdated: (value) {
                setState(() {
                  _newUserFromRegister.zipCode = int.parse(_getValue(value));
                });
              }),
          OlukoRegisterTextfield(
              key: formKey,
              title: OlukoLocalizations.get(context, 'email'),
              fieldType: RegisterFieldEnum.EMAIL,
              onInputUpdated: (value) {
                setState(() {
                  _newUserFromRegister.email = _getValue(value);
                });
              }),
          OlukoRegisterTextfield(
              key: formKey,
              title: OlukoLocalizations.get(context, 'username'),
              fieldType: RegisterFieldEnum.USERNAME,
              onInputUpdated: (value) {
                setState(() {
                  _newUserFromRegister.username = _getValue(value);
                });
              }),
          OlukoRegisterTextfield(
            key: formKey,
            title: OlukoLocalizations.get(context, 'password'),
            fieldType: RegisterFieldEnum.PASSWORD,
            onInputUpdated: (value) {
              setState(() {
                _newUserFromRegister.password = _getValue(value);
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

  bool _containsMinChars() => _passwordValidationState[ValidatorNames.containsMinChars];

  bool _containsUppercase() => _passwordValidationState[ValidatorNames.containsUppercase];

  bool _containsDigit() => _passwordValidationState[ValidatorNames.containsDigit];

  bool _containsLowercase() => _passwordValidationState[ValidatorNames.containsLowercase] == true;

  bool isPasswordValid() => (_containsMinChars() && _containsUppercase()) && (_containsDigit() && _containsLowercase());

  String _getValue(String value) => value.trim();

  agreeWithTermsAndConditions(bool value) {
    setState(() {
      _agreeWithRequirements = value;
    });
  }
}
