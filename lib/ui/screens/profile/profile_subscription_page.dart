import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/subscription_content_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/plan.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/subscription_card.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/app_navigator.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class ProfileSubscriptionPage extends StatefulWidget {
  @override
  _ProfileSubscriptionPageState createState() => _ProfileSubscriptionPageState();
}

class _ProfileSubscriptionPageState extends State<ProfileSubscriptionPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubscriptionContentBloc, SubscriptionContentState>(
      bloc: BlocProvider.of<SubscriptionContentBloc>(context)..initialize(),
      listenWhen: (context, subscriptionContentState) {
        return subscriptionContentState is GoToHomeState || subscriptionContentState is GoBackState;
      },
      listener: (context, subscriptionContentState) {
        if (subscriptionContentState is GoToHomeState) {
          Navigator.popUntil(context, ModalRoute.withName('/'));
          AppNavigator().goToAssessmentVideosViaMain(context);
        } else if (subscriptionContentState is GoBackState) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, subscriptionContentState) {
        if (subscriptionContentState is SubscriptionContentLoading) {
          return const CircularProgressIndicator();
        } else if (subscriptionContentState is SubscriptionContentInitialized) {
          return Scaffold(
            backgroundColor: OlukoColors.black,
            appBar: OlukoAppBar(
              title: ProfileViewConstants.profileOptionsSubscription,
              showSearchBar: false,
            ),
            body: Container(
              color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: subscriptionContentState.plans != null
                    ? ListView(
                        shrinkWrap: true,
                        children: subscriptionContentState.plans.map((plan) {
                          return _showSubscriptionCard(plan, subscriptionContentState.user);
                        }).toList(),
                      )
                    : const SizedBox(),
              ),
            ),
          );
        } else {
          return SizedBox(
            width: ScreenUtils.width(context),
            height: ScreenUtils.height(context),
            child: Center(
              child: Text(
                OlukoLocalizations.get(context, 'somethingWentWrong'),
                textAlign: TextAlign.center,
                style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w500),
              ),
            ),
          );
        }
      },
    );
  }

  SubscriptionCard _showSubscriptionCard(Plan plan, UserResponse user) {
    final SubscriptionCard subscriptionCard = SubscriptionCard();
    subscriptionCard.plan = plan;
    subscriptionCard.priceLabel = shortDurationLabel[PlanDuration.values[plan.intervalCount]];
    subscriptionCard.priceSubtitle = 'Renews every ${durationLabel[PlanDuration.values[plan.intervalCount]]?.toLowerCase()}';
    subscriptionCard.selected = plan.metadata['level'] == user.currentPlan;
    subscriptionCard.userId = user.id;
    subscriptionCard.loadingAction = _emitLoading;
    subscriptionCard.subscribeAction = () => BlocProvider.of<SubscriptionContentBloc>(context).subscribe(plan, user.id);
    return subscriptionCard;
  }

  void _emitLoading() {
    BlocProvider.of<SubscriptionContentBloc>(context).emitSubscriptionContentLoading();
  }
}
