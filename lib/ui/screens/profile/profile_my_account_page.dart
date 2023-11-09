import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/country_bloc.dart';
import 'package:oluko_app/blocs/plan_bloc.dart';
import 'package:oluko_app/blocs/profile/my_account_bloc.dart';
import 'package:oluko_app/blocs/user/user_information_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_helper.dart';
import 'package:oluko_app/helpers/text_helper.dart';
import 'package:oluko_app/helpers/user_helper.dart';
import 'package:oluko_app/models/dto/change_user_information.dart';
import 'package:oluko_app/models/dto/country.dart';
import 'package:oluko_app/models/plan.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/subscription_card.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/app_validators.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class ProfileMyAccountPage extends StatefulWidget {
  BuildContext contextToLogOut;
  ProfileMyAccountPage();
  @override
  _ProfileMyAccountPageState createState() => _ProfileMyAccountPageState();
}

class _ProfileMyAccountPageState extends State<ProfileMyAccountPage> {
  UserResponse _profileInfo;
  UserInformation newFields = UserInformation();
  UserInformation _defaultUser;
  bool emailHasChanged = false;
  bool usernameHasChanged = false;
  bool isGoogleAuth = false;
  bool formHasChanged = false;
  final formKey = GlobalKey<FormState>();
  final String _defaultValueForLocationData = '';

  @override
  void initState() {
    BlocProvider.of<CountryBloc>(context).clear();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Country> countries = [];
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthSuccess) {
        _profileInfo = state.user;
        _defaultUser = UserInformation(
          username: _profileInfo.username,
          firstName: _profileInfo.firstName,
          lastName: _profileInfo.lastName,
          email: _profileInfo.email,
          city: _profileInfo.city,
          state: _profileInfo.state,
          country: _profileInfo.country,
        );
        newFields = UserInformation(
          username: newFields.username ?? _profileInfo.username,
          firstName: newFields.firstName ?? _profileInfo.firstName,
          lastName: newFields.lastName ?? _profileInfo.lastName,
          email: newFields.email ?? _profileInfo.email,
          city: _profileInfo.city ?? _defaultValueForLocationData,
          state: _profileInfo.state ?? _defaultValueForLocationData,
          country: _profileInfo.country ?? _defaultValueForLocationData,
        );
        isGoogleAuth = state.firebaseUser.providerData[0].providerId == 'google.com';
        return buildScaffoldPage(context);
      } else {
        return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: OlukoCircularProgressIndicator(),
        );
      }
    });
  }

  Scaffold buildScaffoldPage(BuildContext context) {
    return Scaffold(
      backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
      resizeToAvoidBottomInset: true,
      appBar: OlukoAppBar(
        title: ProfileViewConstants.profileMyAccountTitle,
        showSearchBar: false,
        showTitle: OlukoNeumorphism.isNeumorphismDesign,
        onPressed: () {
          BlocProvider.of<MyAccountBloc>(context).emitMyAccountDispose();
          Navigator.pop(context);
        },
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Stack(children: [
          SingleChildScrollView(
            physics: OlukoNeumorphism.listViewPhysicsEffect,
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
              child: Column(
                children: [
                  buildUserInformationFields(),
                  deleteMyAccountButton(),
                  const SizedBox(
                    height: 120,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: getSaveButton(),
          ),
        ]),
      ),
    );
  }

  Widget buildUserInformationFields() {
    return Form(
      key: formKey,
      child: Column(
        children: [
          userInformationFields(
            OlukoLocalizations.get(context, 'username'),
            UserHelper.printUsername(_profileInfo.username, _profileInfo.id),
            'username',
          ),
          userInformationFields(OlukoLocalizations.get(context, 'firstName'), _profileInfo.firstName, 'firstName'),
          userInformationFields(OlukoLocalizations.get(context, 'lastName'), _profileInfo.lastName, 'lastName'),
          userInformationFields(OlukoLocalizations.get(context, 'email'), _profileInfo.email, 'email'),
        ],
      ),
    );
  }

  Widget userInformationFields(String title, String value, String key) {
    String oldEmail;
    String oldUserName;
    if (key == 'email') {
      oldEmail = value;
    }
    if (key == 'username') {
      oldUserName = value;
    }
    TextEditingController controller = TextEditingController();
    controller.text = value;
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: OlukoNeumorphism.isNeumorphismDesign ? const EdgeInsets.symmetric(horizontal: 20, vertical: 10) : const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
                borderRadius:
                    OlukoNeumorphism.isNeumorphismDesign ? const BorderRadius.all(const Radius.circular(15.0)) : const BorderRadius.all(Radius.circular(5.0)),
                border: OlukoNeumorphism.isNeumorphismDesign ? const Border.symmetric() : Border.all(width: 1.0, color: OlukoColors.grayColor),
                color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicGreyBackgroundFlat : Colors.transparent),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: OlukoNeumorphism.isNeumorphismDesign ? 20 : 10),
                    child: Text(
                      title,
                      style: OlukoFonts.olukoMediumFont(customColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.grayColor : OlukoColors.primary),
                    ),
                  ),
                  if (title == OlukoLocalizations.get(context, 'country'))
                    countriesDropdown()
                  else if (title == OlukoLocalizations.get(context, 'state'))
                    statesDropdown()
                  else
                    getTextFormField(value, title, oldUserName, oldEmail, key),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Padding getTextFormField(String value, String title, String oldUserName, String oldEmail, String key) {
    return Padding(
      padding: const EdgeInsets.only(left: OlukoNeumorphism.isNeumorphismDesign ? 20 : 10),
      child: TextFormField(
        enabled: !isGoogleAuth,
        initialValue: value,
        onChanged: (value) async {
          if (value != null || value.isNotEmpty) {
            value = value.trim();
          }
          switch (key) {
            case 'username':
              if (value != oldUserName) {
                usernameHasChanged = true;
              }
              newFields.username = value;
              break;
            case 'firstName':
              newFields.firstName = value;
              break;
            case 'lastName':
              newFields.lastName = value;
              break;
            case 'email':
              if (value != oldEmail) {
                emailHasChanged = true;
              }
              newFields.email = value;
              break;
          }
          BlocProvider.of<MyAccountBloc>(context).changeFormState(_defaultUser, newFields);
        },
        decoration: InputDecoration(
          border: InputBorder.none,
        ),
        style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w500, customColor: !isGoogleAuth ? OlukoColors.white : OlukoColors.grayColor),
      ),
    );
  }

  Widget subscriptionSection() {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          BlocBuilder<PlanBloc, PlanState>(builder: (context, state) {
            return Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: subscriptionContent(state),
              )
            ]);
          }),
        ]));
  }

  Widget subscriptionContent(PlanState state) {
    if (state is PlansSuccess) {
      return Column(
        children: showSubscriptionCard(state.plans),
      );
    } else {
      return Container();
    }
  }

  Widget getSaveButton() {
    return BlocBuilder<MyAccountBloc, MyAccountState>(
      builder: (context, state) {
        if (state is MyAccountSuccess) {
          return saveChangesButton(state.formHasChanged);
        } else {
          return saveChangesButton(false);
        }
      },
    );
  }

  Container saveChangesButton(bool isEnabled) {
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLight,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          child: OlukoNeumorphicPrimaryButton(
            isDisabled: !isEnabled,
            title:
                '${TextHelper.capitalizeFirstCharacter(OlukoLocalizations.get(context, 'save'))} ${TextHelper.capitalizeFirstCharacter(OlukoLocalizations.get(context, 'changes'))}',
            onPressed: !isEnabled ? () {} : saveChangesAction,
            isExpanded: false,
            customHeight: 60,
          ),
        ),
      ),
    );
  }

  Padding deleteMyAccountButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        child: OlukoNeumorphicPrimaryButton(
          customColor: OlukoColors.error,
          title: OlukoLocalizations.get(context, 'deleteMyAccount'),
          onPressed: () => deleteUserAction(),
          isExpanded: false,
          customHeight: 60,
        ),
      ),
    );
  }

  Future<void> deleteUserAction() async {
    if (await logOutConfirmationPopUp(context, 'deleteUserConfirmation')) {
      AppMessages.clearAndShowSnackbarTranslated(context, 'loadingWithDots');
      if (await BlocProvider.of<UserInformationBloc>(context).sendDeleteConfirmation(_profileInfo.id)) {
        logOut(userDeleted: true);
      }
    }
  }

  Future<void> saveChangesAction() async {
    FocusScope.of(context).unfocus();
    if (emailHasChanged || usernameHasChanged) {
      if (await logOutConfirmationPopUp(context, 'updateEmailUserNameMsg')) {
        AppMessages.clearAndShowSnackbarTranslated(context, 'uploadingWithDots');
        if (await BlocProvider.of<UserInformationBloc>(context).updateUserInformation(newFields, _profileInfo.id, context, isLoggedOut: true)) {
          logOut();
        }
      }
    } else {
      AppMessages.clearAndShowSnackbarTranslated(context, 'uploadingWithDots');
      BlocProvider.of<UserInformationBloc>(context).updateUserInformation(newFields, _profileInfo.id, context);
    }
  }

  Future<void> logOut({bool userDeleted = false}) async {
    await BlocProvider.of<AuthBloc>(context).logout(context, userDeleted: userDeleted);
    AppMessages.clearAndShowSnackbarTranslated(context, 'loggedOut');
  }

  Future<bool> logOutConfirmationPopUp(BuildContext context, String textKey) async {
    bool result = false;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: OlukoColors.black,
        content: Text(
          OlukoLocalizations.get(context, textKey),
          style: OlukoFonts.olukoBigFont(),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              OlukoLocalizations.get(context, 'no'),
            ),
          ),
          TextButton(
            onPressed: () {
              result = true;
              Navigator.of(context).pop();
            },
            child: Text(
              OlukoLocalizations.get(context, 'yes'),
            ),
          ),
        ],
      ),
    );

    return result;
  }

  List<SubscriptionCard> showSubscriptionCard(List<Plan> plans) {
    final Plan userPlan = plans.firstWhere((element) => element.isCurrentLevel(_profileInfo.currentPlan as int), orElse: () => null);
    SubscriptionCard subscriptionCard = SubscriptionCard(userPlan);
    return [subscriptionCard];
  }

  Widget countriesDropdown() {
    return BlocListener<CountryBloc, CountryState>(
      listener: (context, state) {
        if (state is CountrySuccess) {
          if (countries == null || countries.isEmpty || _profileInfo.country != newFields.country) {
            setState(() {
              countries = state.countries;
            });
          }
        }
      },
      child: countries != null && countries.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: OlukoNeumorphism.isNeumorphismDesign ? 20 : 10),
              child: DropdownButton(
                dropdownColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicGreyBackgroundFlat : Colors.transparent,
                isExpanded: true,
                value: newFields.country ?? _profileInfo.country ?? countries[0].name,
                items: countries.map<DropdownMenuItem<String>>((Country country) {
                  return DropdownMenuItem<String>(
                    value: country.name,
                    child: Text(
                      country.name,
                      overflow: TextOverflow.ellipsis,
                      style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w500, customColor: !isGoogleAuth ? OlukoColors.white : OlukoColors.grayColor),
                    ),
                  );
                }).toList(),
                onChanged: (String item) async {
                  final selectedCountry = countries.firstWhere((country) => country.name == item);
                  final List<String> statesOfSelectedCountry = selectedCountry?.states;
                  var newFieldsState = newFields.state;
                  var newCountries = countries;
                  if (statesOfSelectedCountry != null && statesOfSelectedCountry.isNotEmpty) {
                    newFieldsState = statesOfSelectedCountry[0];
                  } else {
                    newCountries = await BlocProvider.of<CountryBloc>(context).getStatesForCountry(selectedCountry.id);
                    final Country newCountryWithStates = newCountries.firstWhere((element) => element.id == selectedCountry.id);
                    newFieldsState =
                        newCountryWithStates != null && AppValidators.isNeitherNullNorEmpty(newCountryWithStates.states) ? newCountryWithStates.states[0] : '-';
                  }
                  setState(() {
                    newFields.country = item;
                    newFields.state = newFieldsState;
                    countries = newCountries;
                  });
                  BlocProvider.of<MyAccountBloc>(context).changeFormState(_defaultUser, newFields);
                },
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: OlukoNeumorphism.isNeumorphismDesign ? 20 : 10),
              child: Text(
                '-',
                style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w500, customColor: !isGoogleAuth ? OlukoColors.white : OlukoColors.grayColor),
              ),
            ),
    );
  }

  Widget statesDropdown() {
    if (countries != null && countries.isNotEmpty) {
      final items = getItemsForStatesDropdown();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: OlukoNeumorphism.isNeumorphismDesign ? 20 : 10),
        child: DropdownButton(
          dropdownColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicGreyBackgroundFlat : Colors.transparent,
          isExpanded: true,
          value: newFields.state ?? _profileInfo.state,
          items: items,
          onChanged: (String item) {
            setState(() {
              newFields.state = item;
            });
            BlocProvider.of<MyAccountBloc>(context).changeFormState(_defaultUser, newFields);
          },
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: OlukoNeumorphism.isNeumorphismDesign ? 20 : 10),
      child: Text(
        '-',
        style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w500, customColor: !isGoogleAuth ? OlukoColors.white : OlukoColors.grayColor),
      ),
    );
  }

  List<DropdownMenuItem<String>> getItemsForStatesDropdown() {
    List<String> statesList = [];
    if (newFields.country != null) {
      statesList = countries.firstWhere((country) => country.name == newFields.country)?.states;
    } else if (_profileInfo.country != null) {
      statesList = countries.firstWhere((country) => country.name == _profileInfo.country)?.states;
    } else {
      statesList = countries[0]?.states;
    }
    return statesList != null && statesList.isNotEmpty
        ? statesList.map<DropdownMenuItem<String>>((String state) {
            return DropdownMenuItem<String>(
              value: state,
              child: Text(
                state,
                overflow: TextOverflow.ellipsis,
                style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w500, customColor: !isGoogleAuth ? OlukoColors.white : OlukoColors.grayColor),
              ),
            );
          }).toList()
        : [];
  }
}
