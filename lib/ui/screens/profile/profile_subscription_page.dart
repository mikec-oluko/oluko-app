import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/market_bloc.dart';
import 'package:oluko_app/blocs/plan_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/plan.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/subscription_card.dart';
import 'package:oluko_app/ui/components/subscription_modal_options.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/app_modal.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class ProfileSubscriptionPage extends StatefulWidget {
  @override
  _ProfileSubscriptionPageState createState() => _ProfileSubscriptionPageState();
}

class _ProfileSubscriptionPageState extends State<ProfileSubscriptionPage> {
  @override
  void initState() {
    BlocProvider.of<MarketBloc>(context).initState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        return BlocProvider(
          create: (context) => PlanBloc()..getPlans(),
          child: SafeArea(
            child: Scaffold(
              backgroundColor: OlukoColors.black,
              appBar: OlukoAppBar(
                title: ProfileViewConstants.profileOptionsSubscription,
                showSearchBar: false,
              ),
              body: Container(
                color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: BlocBuilder<PlanBloc, PlanState>(
                    builder: (context, state) {
                      if (state is PlansSuccess) {
                        return state.plans != null
                            ? ListView(
                                shrinkWrap: true,
                                children: state.plans.map((plan) {
                                  return _showSubscriptionCard(plan, authState.user.currentPlan);
                                }).toList(),
                              )
                            : const SizedBox();
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        return const SizedBox();
      }
    });
  }

  Stack _subscriptionCardWithButton(PlansSuccess state, BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: _showSubscriptionCard(state.plans[2], 0),
        ),
        Positioned(
          bottom: -30,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                      ),
                      primary: OlukoColors.primary,
                      side: const BorderSide(color: OlukoColors.primary)),
                  onPressed: () => AppModal.dialogContent(context: context, content: [SubscriptionModalOption()], closeButton: true),
                  child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        OlukoLocalizations.get(context, 'upgrade'),
                        style: const TextStyle(fontSize: 18),
                      ))),
            ),
          ),
        )
      ],
    );
  }

  SubscriptionCard _showSubscriptionCard(Plan plan, double currentPlan) {
    final SubscriptionCard subscriptionCard = SubscriptionCard();
    final priceFormated = NumberFormat('###.##').format(plan.amount);
    subscriptionCard.price = '\$$priceFormated ';
    subscriptionCard.priceLabel = shortDurationLabel[PlanDuration.values[plan.intervalCount]];
    subscriptionCard.description = plan.description;
    subscriptionCard.priceSubtitle = 'Renews every ${durationLabel[PlanDuration.values[plan.intervalCount]]?.toLowerCase()}';
    subscriptionCard.title = plan.name;
    subscriptionCard.selected = plan.metadata['level'] == currentPlan;
    subscriptionCard.appleId = plan.appleId;
    return subscriptionCard;
  }
}
