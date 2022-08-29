import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
// import 'package:oluko_app/blocs/market_bloc.dart';
import 'package:oluko_app/blocs/plan_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/plan.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/subscription_card.dart';
import 'package:oluko_app/ui/components/subscription_modal_options.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/app_modal.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class ProfileSubscriptionPage extends StatefulWidget {
  @override
  _ProfileSubscriptionPageState createState() => _ProfileSubscriptionPageState();
}

class _ProfileSubscriptionPageState extends State<ProfileSubscriptionPage> with TickerProviderStateMixin {
  final bool useNew = true;
  TabController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = TabController(vsync: this, length: 3);
    _controller.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        // BlocProvider.of<PlanBloc>(context).getPlans();
        return BlocProvider(
          create: (context) => PlanBloc()..getPlans(),
          child:
              // return
              SafeArea(
                  child: Scaffold(
                      backgroundColor: OlukoColors.white,
                      appBar: OlukoAppBar(
                        showTitle: false,
                        showLogo: true,
                        reduceHeight: true,
                        showBackButton: false,
                        title: ProfileViewConstants.profileOptionsSubscription,
                        showSearchBar: false,
                      ),
                      body: Container(
                        width: ScreenUtils.width(context),
                        height: ScreenUtils.height(context),
                        color: OlukoColors.white,
                        child: BlocBuilder<PlanBloc, PlanState>(
                          builder: (context, state) {
                            if (state is PlansSuccess) {
                              // BlocProvider.of<MarketBloc>(context).initState(state.plans);
                              return state.plans != null
                                  ? ListView(
                                      shrinkWrap: true,
                                      children: [
                                        _subscriptionTitleSection(context),
                                        _subscriptionBodyContent(context, state, authState),
                                        _selectPlanButton(state),
                                        _cancelPlanButton()
                                      ],
                                    )
                                  : const SizedBox();
                            } else {
                              return Container();
                            }
                          },
                        ),
                      ))),
        );
      } else {
        return const SizedBox();
      }
    });
  }

  Align _cancelPlanButton() {
    return Align(
      child: Container(
        width: 150,
        height: 60,
        child: OlukoNeumorphicPrimaryButton(isDisabled: false, isExpanded: false, thinPadding: false, flatStyle: true, onPressed: () {}, title: 'Cancel'
            // OlukoLocalizations.get(context, 'letsGo'),
            ),
      ),
    );
  }

  Align _selectPlanButton(PlansSuccess state) {
    return Align(
      child: Container(
        width: 150,
        height: 60,
        child: OlukoNeumorphicPrimaryButton(
            isDisabled: false,
            isExpanded: false,
            thinPadding: false,
            flatStyle: true,
            onPressed: () {
              print(state.plans[_currentIndex].name);
            },
            title: 'Select Plan'
            // OlukoLocalizations.get(context, 'letsGo'),
            ),
      ),
    );
  }

  Padding _subscriptionBodyContent(BuildContext context, PlansSuccess state, AuthSuccess authState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: ScreenUtils.height(context) / 2,
        child: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
            Center(child: _subscriptionContent(context, state, authState)),
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
          width: ScreenUtils.width(context) / 4,
        ),
        _manageMembershipText(),
        SizedBox(
          width: ScreenUtils.width(context) / 4,
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
        border: Border.all(color: OlukoColors.primary, width: 1),
        borderRadius: const BorderRadius.all(Radius.circular(50.0)),
      ),
      child: Image.asset(
        'assets/assessment/neumorphic_check.png',
        scale: 4,
      ),
    );
  }

  Container _subscriptionContent(BuildContext context, PlansSuccess state, AuthSuccess authState) {
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
                  userId: authState.user.id))
              .toList()),
    );
  }

  Container _plansTabs(PlansSuccess state, BuildContext context) {
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
        tabs: state.plans
            .map(
              (tabContent) => _tabWithSelectedIcon(context, state, tabContent),
            )
            .toList(),
      ),
    );
  }

  Stack _tabWithSelectedIcon(BuildContext context, PlansSuccess state, Plan tabContent) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: AlignmentDirectional.topCenter,
      children: [
        Tab(
          height: ScreenUtils.height(context) / 10,
          child: _tabMainContainer(state, tabContent, context),
        ),
        Visibility(visible: _currentIndex == state.plans.indexOf(tabContent), child: Positioned(top: -10, child: _checkCircle())),
      ],
    );
  }

  Container _tabMainContainer(PlansSuccess state, Plan tabContent, BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          color: _currentIndex == state.plans.indexOf(tabContent) ? OlukoColors.primary : OlukoColors.subscriptionTabsColor,
        ),
        child: Padding(
          padding: !(_currentIndex == state.plans.indexOf(tabContent)) ? EdgeInsets.zero : const EdgeInsets.fromLTRB(4, 4, 4, 0),
          child: _tabBorderEffect(context, tabContent, state),
        ));
  }

  Widget _tabBorderEffect(BuildContext context, Plan tabContent, PlansSuccess state) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      child: Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: !(_currentIndex == state.plans.indexOf(tabContent)) ? OlukoColors.primary : OlukoColors.subscriptionTabsColor, width: 4.0)),
            color: OlukoColors.subscriptionTabsColor),
        child: _tabContent(context, tabContent),
      ),
    );
  }

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
}
