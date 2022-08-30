import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
// import 'package:oluko_app/blocs/market_bloc.dart';
import 'package:oluko_app/blocs/plan_bloc.dart';
import 'package:oluko_app/blocs/subscription_content_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/plan.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/subscription_card.dart';
import 'package:oluko_app/ui/components/subscription_modal_options.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_white_button.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/app_navigator.dart';
import 'package:oluko_app/utils/app_modal.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class ProfileSubscriptionPage extends StatefulWidget {
  final bool fromRegister;
  const ProfileSubscriptionPage({this.fromRegister});
  @override
  _ProfileSubscriptionPageState createState() => _ProfileSubscriptionPageState();
}

class _ProfileSubscriptionPageState extends State<ProfileSubscriptionPage> with TickerProviderStateMixin {
  final bool useNew = true;
  TabController _controller;
  int _currentIndex = 0;
  final int _planQty = 3;

  @override
  void initState() {
    super.initState();
    _controller = TabController(vsync: this, animationDuration: Duration.zero, length: _planQty);
    _controller.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubscriptionContentBloc, SubscriptionContentState>(
      bloc: BlocProvider.of<SubscriptionContentBloc>(context)..initialize(widget.fromRegister),
      listenWhen: (context, subscriptionContentState) {
        return subscriptionContentState is PurchaseSuccess || subscriptionContentState is FailureState;
      },
      listener: (context, subscriptionContentState) {
        if (subscriptionContentState is PurchaseSuccess) {
          if (widget.fromRegister) {
            Navigator.popUntil(context, ModalRoute.withName('/'));
            AppNavigator().goToAssessmentVideosViaMain(context);
          } else {
            Navigator.of(context).pop();
          }
        } else if (subscriptionContentState is FailureState) {
          Navigator.of(context).pop();
          AppMessages.clearAndShowSnackbarTranslated(context, 'manageSubscriptionFromWeb');
        }
      },
      builder: (context, subscriptionContentState) {
        return Scaffold(
          backgroundColor: OlukoColors.white,
          appBar: OlukoAppBar(
            showTitle: false,
            showLogo: true,
            reduceHeight: true,
            showBackButton: false,
            title: ProfileViewConstants.profileOptionsSubscription,
            showSearchBar: false,
          ),
          body: getBody(subscriptionContentState),
        );
      },
    );
  }

  Align _selectPlanButton(SubscriptionContentInitialized state) {
    return Align(
      child: Container(
        width: ScreenUtils.width(context) / 2,
        height: 60,
        child: OlukoNeumorphicPrimaryButton(
          isDisabled: false,
          isExpanded: false,
          thinPadding: false,
          flatStyle: true,
          onPressed: () {
            print(state.plans[_currentIndex].name);
          },
          title: OlukoLocalizations.get(context, 'selectPlan'),
        ),
      ),
    );
  }

  Padding _subscriptionBodyContent(BuildContext context, SubscriptionContentInitialized state, UserResponse user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
      child: Container(
        height: ScreenUtils.height(context) / 2,
        child: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
            Center(child: _subscriptionContent(context, state, user)),
            Positioned(left: 0, right: 0, top: -(ScreenUtils.height(context) * 0.395), child: _plansTabs(state, context)),
          ],
        ),
      ),
    );
  }

  Row _subscriptionTitleSection(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: ScreenUtils.width(context) / 7.2,
        ),
        _manageMembershipText(),
        SizedBox(
          width: ScreenUtils.width(context) / 7.2,
        ),
      ],
    );
  }

  Container _checkCircle() {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        color: OlukoColors.primary,
        border: Border.all(color: OlukoColors.primary),
        borderRadius: const BorderRadius.all(Radius.circular(50.0)),
      ),
      child: Image.asset(
        'assets/assessment/neumorphic_check.png',
        scale: 4,
      ),
    );
  }

  Container _subscriptionContent(BuildContext context, SubscriptionContentInitialized state, UserResponse user) {
    return Container(
      width: ScreenUtils.width(context),
      height: ScreenUtils.height(context) / 5,
      child: TabBarView(
          controller: _controller,
          children: state.plans
              .map((plan) => SubscriptionCard(
                  plan: state.plans.elementAt(_currentIndex),
                  priceLabel: shortDurationLabel[PlanDuration.values[plan.intervalCount]],
                  priceSubtitle: 'Renews every ${durationLabel[PlanDuration.values[plan.intervalCount]]?.toLowerCase()}',
                  selected: true,
                  userId: user.id))
              .toList()),
    );
  }

  Container _plansTabs(SubscriptionContentInitialized state, BuildContext context) {
    return Container(
      width: ScreenUtils.width(context),
      height: ScreenUtils.height(context),
      child: TabBar(
        onTap: (index) {
          setState(() {});
        },
        controller: _controller,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.black,
        indicatorWeight: 0.001,
        padding: EdgeInsets.zero,
        indicatorPadding: EdgeInsets.zero,
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        tabs: state.plans
            .map(
              (tabContent) => _tabWithSelectedIcon(context, state, tabContent),
            )
            .toList(),
      ),
    );
  }

  Stack _tabWithSelectedIcon(BuildContext context, SubscriptionContentInitialized state, Plan tabContent) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: AlignmentDirectional.topCenter,
      children: [
        Tab(
          height: ScreenUtils.height(context) / 10,
          child: _tabMainContainer(state, tabContent, context),
        ),
        Visibility(visible: _isCurrentTabIndex(state, tabContent), child: Positioned(top: -10, child: _checkCircle())),
      ],
    );
  }

  Container _tabMainContainer(SubscriptionContentInitialized state, Plan tabContent, BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          color: _isCurrentTabIndex(state, tabContent) ? OlukoColors.primary : OlukoColors.subscriptionTabsColor,
        ),
        child: Padding(
          padding: !_isCurrentTabIndex(state, tabContent) ? EdgeInsets.zero : const EdgeInsets.fromLTRB(4, 4, 4, 0),
          child: _tabBorderEffect(context, tabContent, state),
        ));
  }

  Widget _tabBorderEffect(BuildContext context, Plan tabContent, SubscriptionContentInitialized state) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      child: Container(
        decoration: BoxDecoration(
            border:
                Border(bottom: BorderSide(color: !_isCurrentTabIndex(state, tabContent) ? OlukoColors.primary : OlukoColors.subscriptionTabsColor, width: 4.0)),
            color: OlukoColors.subscriptionTabsColor),
        child: _tabContent(context, tabContent),
      ),
    );
  }

  bool _isCurrentTabIndex(SubscriptionContentInitialized state, Plan tabContent) => _currentIndex == state.plans.indexOf(tabContent);

  Container _tabContent(BuildContext context, Plan tabContent) {
    return Container(
        padding: EdgeInsets.zero,
        width: MediaQuery.of(context).size.width,
        child: Align(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(tabContent.name, style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w600, customColor: OlukoColors.black)),
            Text('${_getCurrency(tabContent)} ${tabContent.applePrice.toString()}'),
          ],
        )));
  }

  Widget _manageMembershipText() {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Container(
          child: Text('Manage Membership', textAlign: TextAlign.center, style: OlukoFonts.olukoBiggestFont(customColor: Colors.black)),
        ),
      ),
    );
  }

  String _getCurrency(Plan tabContent) => tabContent.currency == 'usd' ? '\$' : tabContent.currency;

  void _handleTabSelection() {
    setState(() {
      _currentIndex = _controller.index;
    });
  }

  Align _cancelPlanButton() {
    return Align(
      child: Container(
        width: ScreenUtils.width(context) / 2,
        height: 60,
        child:
            OlukoNeumorphicWhiteButton(isExpanded: false, useBorder: true, flatStyle: true, onPressed: () {}, title: OlukoLocalizations.get(context, 'cancel')),
      ),
    );
  }

  Widget getBody(SubscriptionContentState state) {
    if (state is SubscriptionContentLoading) {
      return OlukoCircularProgressIndicator();
    } else if (state is SubscriptionContentInitialized) {
      return Container(
        color: OlukoColors.white,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: state.plans != null
                ? ListView(
                    shrinkWrap: true,
                    children: [
                      _subscriptionTitleSection(context),
                      _subscriptionBodyContent(context, state, state.user),
                      _selectPlanButton(state),
                      _cancelPlanButton()
                    ],
                  )
                : const SizedBox()
            // ? ListView(shrinkWrap: true, children: []
            //     //  state.plans.map((plan) {
            //     //   return _showSubscriptionCard(plan, state.user);
            //     // }).toList(),
            //     )
            // : const SizedBox(),
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
            style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w500),
          ),
        ),
      );
    }
  }
}
