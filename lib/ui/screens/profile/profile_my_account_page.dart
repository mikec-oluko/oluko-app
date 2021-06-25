import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/plan_bloc.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/helpers/enum_helper.dart';
import 'package:oluko_app/models/plan.dart';
// import 'package:oluko_app/models/sign_up_request.dart';
import 'package:oluko_app/models/sign_up_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/subscription_card.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';

class ProfileMyAccountPage extends StatefulWidget {
  @override
  _ProfileMyAccountPageState createState() => _ProfileMyAccountPageState();
}

class _ProfileMyAccountPageState extends State<ProfileMyAccountPage> {
  SignUpResponse profileInfo;

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
      appBar: OlukoAppBar(title: ProfileViewConstants.profileMyAccountTitle),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.black,
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
        color: Colors.black,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: CircleAvatar(
                // backgroundImage: //TODO: Get image,
                backgroundColor: Colors.red,
                radius: 50.0,
                child: IconButton(
                    icon:
                        Icon(Icons.linked_camera_outlined, color: Colors.white),
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
        userInformationFields(ProfileViewConstants.profileUserName,
            ProfileViewConstants.profileUserNameContent),
        userInformationFields(
            ProfileViewConstants.profileUserFirstName, profileInfo.firstName),
        userInformationFields(
            ProfileViewConstants.profileUserLastName, profileInfo.lastName),
        userInformationFields(
            ProfileViewConstants.profileUserEmail, profileInfo.email),
      ],
    );
  }

  //TODO: Can be a widget
  Widget userInformationFields(String title, String value) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                border: Border.all(width: 1.0, color: OlukoColors.grayColor)),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      title,
                      style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: OlukoColors.primary),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      value,
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
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
          child: Text("Logout",
              style: TextStyle(fontSize: 18.0, color: OlukoColors.primary)),
          onPressed: () {
            //TODO: Define logout action
          },
        ),
      ),
    );
  }

  Future<void> getProfileInfo() async {
    profileInfo = SignUpResponse.fromJson(
        (await AuthBloc().retrieveLoginData()).toJson());
    return profileInfo;
  }
}
