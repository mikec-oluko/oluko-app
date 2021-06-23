import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/plan_bloc.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/helpers/enum_helper.dart';
import 'package:oluko_app/models/plan.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/subscription_card.dart';
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
      child: Scaffold(
        appBar:
            OlukoAppBar(title: ProfileViewConstants.profileOptionsSubscription),
        body: SingleChildScrollView(
          child: Container(
              color: Colors.black,
              child: BlocBuilder<PlanBloc, PlanState>(
                builder: (context, state) {
                  if (state is PlansSuccess) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: showSubscriptionCard(state.plans[0]),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: TitleBody(ProfileViewConstants
                                .profileSubscriptionMessage),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                          child: showSubscriptionCard(state.plans[2]),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(10.0),
                                            bottomRight:
                                                Radius.circular(10.0))),
                                    primary: OlukoColors.primary,
                                    side:
                                        BorderSide(color: OlukoColors.primary)),
                                onPressed: () => {},
                                child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Text(
                                      ProfileViewConstants.profileUpgradeText,
                                      style: TextStyle(fontSize: 18),
                                    ))),
                          ),
                        )
                      ],
                    );
                  } else {
                    return Container();
                  }
                },
              )),
        ),
      ),
    );
  }

  SubscriptionCard showSubscriptionCard(Plan plan) {
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
    subscriptionCard.selected = plan.price == 99 ? true : false;
    subscriptionCard.showHint = false;
    subscriptionCard.backgroundImage = plan.backgroundImage;
    subscriptionCard.onHintPressed = plan.infoDialog != null ? () {} : null;
    return subscriptionCard;
  }
}
