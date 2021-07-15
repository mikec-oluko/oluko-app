import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/plan_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_helper.dart';
import 'package:oluko_app/models/plan.dart';
// import 'package:oluko_app/models/sign_up_request.dart';
import 'package:oluko_app/models/sign_up_response.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_user_info.dart';
import 'package:oluko_app/ui/components/subscription_card.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class ProfileMyAccountPage extends StatefulWidget {
  @override
  _ProfileMyAccountPageState createState() => _ProfileMyAccountPageState();
}

class _ProfileMyAccountPageState extends State<ProfileMyAccountPage> {
  UserResponse profileInfo;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getProfileInfo(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return BlocProvider(
              create: (context) => PlanBloc()..getPlans(),
              child: buildScaffoldPage(context),
            );
          } else {
            return SizedBox();
          }
        });
  }

  Scaffold buildScaffoldPage(BuildContext context) {
    return Scaffold(
      appBar: OlukoAppBar(
        title: ProfileViewConstants.profileMyAccountTitle,
        showSearchBar: false,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: OlukoColors.black,
          child: Column(
            children: [
              userImageSection(),
              buildUserInformationFields(),
              subscriptionSection(),
              logoutButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget userImageSection() {
    return Container(
        color: OlukoColors.black,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: CircleAvatar(
                // backgroundImage: //TODO: Get image,
                backgroundColor: OlukoColors.primary,
                radius: 50.0,
                child: IconButton(
                    icon: Icon(Icons.linked_camera_outlined,
                        color: OlukoColors.white),
                    onPressed: () {
                      //TODO: Change profile picture
                    }),
              ),
            )
          ],
        ));
  }

  Column buildUserInformationFields() {
    return Column(
      children: [
        userInformationFields(
            OlukoLocalizations.of(context).find('userName'),
            profileInfo.username != null
                ? profileInfo.username
                : ProfileViewConstants.profileUserNameContent),
        userInformationFields(OlukoLocalizations.of(context).find('firstName'),
            profileInfo.firstName),
        userInformationFields(OlukoLocalizations.of(context).find('lastName'),
            profileInfo.lastName),
        userInformationFields(
            OlukoLocalizations.of(context).find('email'), profileInfo.email),
      ],
    );
  }

  Widget userInformationFields(String title, String value) {
    return OlukoUserInfoWidget(title: title, value: value);
  }

  Widget subscriptionSection() {
    return Container(
        width: MediaQuery.of(context).size.width,
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
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

  List<SubscriptionCard> showSubscriptionCard(List<Plan> plans) {
    //TODO: Use plan from userData.
    final Plan userPlan = plans[1];

    SubscriptionCard subscriptionCard = SubscriptionCard();
    subscriptionCard.priceLabel =
        '\$${userPlan.price}/${durationLabel[userPlan.duration].toLowerCase()}';
    subscriptionCard.priceSubtitle = userPlan.recurrent
        ? 'Renews every ${durationLabel[userPlan.duration].toLowerCase()}'
        : '';
    subscriptionCard.title = userPlan.title;
    subscriptionCard.subtitles = userPlan.features
        .map((PlanFeature feature) => EnumHelper.enumToString(feature))
        .toList();
    subscriptionCard.selected = true;
    subscriptionCard.showHint = false;
    subscriptionCard.backgroundImage = userPlan.backgroundImage;
    subscriptionCard.onHintPressed = userPlan.infoDialog != null ? () {} : null;
    return [subscriptionCard];
  }

  Align logoutButton() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 5.0),
        child: TextButton(
          child: Text(OlukoLocalizations.of(context).find('logout'),
              style: OlukoFonts.olukoBigFont(customColor: OlukoColors.primary)),
          onPressed: () {
            BlocProvider.of<AuthBloc>(context).logout(context);
            AppMessages.showSnackbar(context, 'Logged out.');
            Navigator.pushNamed(context, '/');

            setState(() {});
          },
        ),
      ),
    );
  }

  Future<void> getProfileInfo() async {
    UserResponse loginData = (await AuthBloc().retrieveLoginData());
    if (loginData != null) {
      profileInfo = UserResponse.fromJson(loginData.toJson());
      return profileInfo;
    }
    return null;
  }
}
