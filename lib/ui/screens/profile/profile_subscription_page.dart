import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/plan_bloc.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/helpers/enum_helper.dart';
import 'package:oluko_app/models/plan.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/subscription_card.dart';
import 'package:oluko_app/ui/components/subscription_modal_options.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';

class ProfileSubscriptionPage extends StatefulWidget {
  @override
  _ProfileSubscriptionPageState createState() =>
      _ProfileSubscriptionPageState();
}

class _ProfileSubscriptionPageState extends State<ProfileSubscriptionPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlanBloc()..getPlans(),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: OlukoAppBar(
            title: ProfileViewConstants.profileOptionsSubscription,
            showSearchBar: false,
          ),
          body: BlocBuilder<PlanBloc, PlanState>(
            builder: (context, state) {
              if (state is PlansSuccess) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: _showSubscriptionCard(state.plans[0]),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: TitleBody(ProfileViewConstants
                                .profileSubscriptionMessage),
                          ),
                        ),
                        _subscriptionCardWithButton(state, context),
                      ],
                    ),
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }

  Stack _subscriptionCardWithButton(PlansSuccess state, BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: _showSubscriptionCard(state.plans[2]),
        ),
        Positioned(
          bottom: -30,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10.0),
                              bottomRight: Radius.circular(10.0))),
                      primary: OlukoColors.primary,
                      side: BorderSide(color: OlukoColors.primary)),
                  onPressed: () => ProfileViewConstants.dialogContent(
                      context: context,
                      content: [SubscriptionModalOption()],
                      closeButton: true),
                  child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        ProfileViewConstants.profileUpgradeText,
                        style: TextStyle(fontSize: 18),
                      ))),
            ),
          ),
        )
      ],
    );
  }

  SubscriptionCard _showSubscriptionCard(Plan plan) {
    SubscriptionCard subscriptionCard = SubscriptionCard();

    subscriptionCard.priceLabel =
        '\$${plan.price}/${durationLabel[plan.duration].toLowerCase()}';
    subscriptionCard.priceSubtitle = plan.recurrent
        ? 'Renews every ${durationLabel[plan.duration].toLowerCase()}'
        : '';
    subscriptionCard.title = plan.title;
    subscriptionCard.subtitles = plan.features
        .map((PlanFeature feature) => EnumHelper.enumToString(feature))
        .toList();
    subscriptionCard.selected = false;
    subscriptionCard.showHint = false;
    subscriptionCard.backgroundImage = plan.backgroundImage;
    subscriptionCard.onHintPressed = plan.infoDialog != null ? () {} : null;
    return subscriptionCard;
  }
}
