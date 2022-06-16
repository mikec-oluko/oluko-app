import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/plan_bloc.dart';
import 'package:oluko_app/blocs/user/user_information_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_helper.dart';
import 'package:oluko_app/helpers/text_helper.dart';
import 'package:oluko_app/helpers/user_helper.dart';
import 'package:oluko_app/models/dto/change_user_information.dart';
import 'package:oluko_app/models/plan.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/oluko_user_info.dart';
import 'package:oluko_app/ui/components/subscription_card.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class ProfileMyAccountPage extends StatefulWidget {
  BuildContext contextToLogOut;
  ProfileMyAccountPage();
  @override
  _ProfileMyAccountPageState createState() => _ProfileMyAccountPageState();
}

class _ProfileMyAccountPageState extends State<ProfileMyAccountPage> {
  UserResponse _profileInfo;
  ChangeUserInformation newFields = ChangeUserInformation();
  bool emailHasChanged = false;
  bool usernameHasChanged = false;
  bool isGoogleAuth = false;
  final formKey = GlobalKey<FormState>();
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthSuccess) {
        //BlocProvider.of<PlanBloc>(context).getPlans();
        this._profileInfo = state.user;
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
      resizeToAvoidBottomInset: false,
      appBar: OlukoAppBar(
          title: ProfileViewConstants.profileMyAccountTitle, showSearchBar: false, showTitle: OlukoNeumorphism.isNeumorphismDesign),
      body: Stack(children: [
        SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
            child: Column(
              children: [
                buildUserInformationFields(),
                SizedBox(
                  height: 100,
                )
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: saveChangesButton(),
        ),
      ]),
    );
  }

  Widget buildUserInformationFields() {
    return Form(
      key: formKey,
      child: Column(
        children: [
          userInformationFields(
              OlukoLocalizations.get(context, 'username'), UserHelper.printUsername(_profileInfo.username, _profileInfo.id)),
          userInformationFields(OlukoLocalizations.get(context, 'firstName'), _profileInfo.firstName),
          userInformationFields(OlukoLocalizations.get(context, 'lastName'), _profileInfo.lastName),
          userInformationFields(OlukoLocalizations.get(context, 'email'), _profileInfo.email),
          userInformationFields(OlukoLocalizations.get(context, 'city'), _profileInfo.city != null ? _profileInfo.city : ""),
          userInformationFields(OlukoLocalizations.get(context, 'state'), _profileInfo.state != null ? _profileInfo.state : ""),
          userInformationFields(OlukoLocalizations.get(context, 'country'), _profileInfo.country != null ? _profileInfo.country : ""),
        ],
      ),
    );
  }

  Widget userInformationFields(String title, String value) {
    String oldEmail;
    String oldUserName;
    if (title == 'Email') {
      oldEmail = value;
    }
    if (title == 'Username') {
      oldUserName = value;
    }
    TextEditingController controller = TextEditingController();
    controller.text = value;
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding:
              OlukoNeumorphism.isNeumorphismDesign ? const EdgeInsets.symmetric(horizontal: 20, vertical: 10) : const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
                borderRadius:
                    OlukoNeumorphism.isNeumorphismDesign ? BorderRadius.all(Radius.circular(15.0)) : BorderRadius.all(Radius.circular(5.0)),
                border: OlukoNeumorphism.isNeumorphismDesign ? Border.symmetric() : Border.all(width: 1.0, color: OlukoColors.grayColor),
                color:
                    OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicGreyBackgroundFlat : Colors.transparent),
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
                      style: OlukoFonts.olukoMediumFont(
                          customColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.grayColor : OlukoColors.primary),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: OlukoNeumorphism.isNeumorphismDesign ? 20 : 10),
                    child: TextFormField(
                      enabled: !isGoogleAuth,
                      initialValue: value,
                      onSaved: (value) async {
                        if (value != null || value.isNotEmpty) {
                          value = value.trim();
                        }
                        switch (title) {
                          case 'Username':
                            if (value != oldUserName) {
                              usernameHasChanged = true;
                            }
                            newFields.username = value;
                            break;
                          case 'First Name':
                            newFields.firstName = value;
                            break;
                          case 'Last Name':
                            newFields.lastName = value;
                            break;
                          case 'Email':
                            if (value != oldEmail) {
                              emailHasChanged = true;
                            }
                            newFields.email = value;
                            break;
                          case 'City':
                            newFields.city = value;
                            break;
                          case 'State':
                            newFields.state = value;
                            break;
                          case 'Country':
                            newFields.country = value;
                            break;
                        }
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      style: OlukoFonts.olukoBigFont(
                          customFontWeight: FontWeight.w500, customColor: !isGoogleAuth ? OlukoColors.white : OlukoColors.grayColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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

  Container saveChangesButton() {
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          child: OlukoNeumorphicPrimaryButton(
            title:
                '${TextHelper.capitalizeFirstCharacter(OlukoLocalizations.get(context, 'save'))} ${TextHelper.capitalizeFirstCharacter(OlukoLocalizations.get(context, 'changes'))}',
            onPressed: () async {
              formKey.currentState.save();
              FocusScope.of(context).unfocus();
              if (emailHasChanged || usernameHasChanged) {
                if (await logOutConfirmationPopUp(context)) {
                  AppMessages.clearAndShowSnackbarTranslated(context, 'uploadingWithDots');
                  if (await BlocProvider.of<UserInformationBloc>(context).updateUserInformation(newFields, _profileInfo.id, context)) {
                    logOut();
                  }
                }
              } else {
                AppMessages.clearAndShowSnackbarTranslated(context, 'uploadingWithDots');
                BlocProvider.of<UserInformationBloc>(context).updateUserInformation(newFields, _profileInfo.id, context);
              }
              usernameHasChanged = false;
              emailHasChanged = false;
            },
            isExpanded: false,
            customHeight: 60,
          ),
        ),
      ),
    );
  }

  void logOut() {
    BlocProvider.of<AuthBloc>(context).logout(context);
    AppMessages.clearAndShowSnackbarTranslated(context, 'loggedOut');
    Navigator.popUntil(context, ModalRoute.withName('/'));
    setState(() {});
  }

  Future<bool> logOutConfirmationPopUp(BuildContext context) async {
    bool result = false;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        content: Text(
          OlukoLocalizations.get(context, 'updateEmailUserNameMsg'),
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
    //TODO: Use plan from userData.
    final Plan userPlan = plans.firstWhere((element) => element.isCurrentLevel(_profileInfo.currentPlan), orElse: () => null);

    SubscriptionCard subscriptionCard = SubscriptionCard();
    subscriptionCard.selected = true;
    if (userPlan != null) {
      subscriptionCard.priceLabel = '\$${userPlan.price}/${durationLabel[userPlan.duration].toLowerCase()}';
      subscriptionCard.priceSubtitle = userPlan.recurrent ? 'Renews every ${durationLabel[userPlan.duration].toLowerCase()}' : '';
      subscriptionCard.title = userPlan.title;
      subscriptionCard.subtitles = userPlan.features.map((PlanFeature feature) => EnumHelper.enumToString(feature)).toList();
      subscriptionCard.showHint = false;
      subscriptionCard.backgroundImage = userPlan.backgroundImage;
      subscriptionCard.onHintPressed = userPlan.infoDialog != null ? () {} : null;
    }
    return [subscriptionCard];
  }
}
