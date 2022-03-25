import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/plan_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_helper.dart';
import 'package:oluko_app/helpers/user_helper.dart';
import 'package:oluko_app/models/plan.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/oluko_user_info.dart';
import 'package:oluko_app/ui/components/subscription_card.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class ProfileMyAccountPage extends StatefulWidget {
  ProfileMyAccountPage();
  @override
  _ProfileMyAccountPageState createState() => _ProfileMyAccountPageState();
}

class _ProfileMyAccountPageState extends State<ProfileMyAccountPage> {
  UserResponse _profileInfo;

  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthSuccess) {
        BlocProvider.of<PlanBloc>(context).getPlans();
        this._profileInfo = state.user;
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
      appBar: OlukoAppBar(
          title: ProfileViewConstants.profileMyAccountTitle, showSearchBar: false, showTitle: OlukoNeumorphism.isNeumorphismDesign),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
          child: Column(
            children: [buildUserInformationFields()],
          ),
        ),
      ),
    );
  }

  Column buildUserInformationFields() {
    return Column(
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
    );
  }

  Widget userInformationFields(String title, String value) {
    return OlukoUserInfoWidget(title: title, value: value);
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
