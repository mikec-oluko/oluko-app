import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/subscription_content_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/plan.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/auth_repository.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/subscription_card.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_white_button.dart';
import 'package:oluko_app/ui/newDesignComponents/plan_details_text.dart';
import 'package:oluko_app/ui/newDesignComponents/terms_and_conditions_privacy_policy_component.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class ProfileSubscriptionPage extends StatefulWidget {
  final bool fromRegister;
  const ProfileSubscriptionPage({this.fromRegister});
  @override
  _ProfileSubscriptionPageState createState() => _ProfileSubscriptionPageState();
}

class _ProfileSubscriptionPageState extends State<ProfileSubscriptionPage> with TickerProviderStateMixin {
  TabController _controller;
  int _selectedIndex = 0;
  int _currentPlan = -1;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<SubscriptionContentBloc>(context).initState(widget.fromRegister);
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubscriptionContentBloc, SubscriptionContentState>(
      listenWhen: (prevState, subscriptionContentState) {
        return subscriptionContentState is PurchaseSuccess ||
            subscriptionContentState is ManageFromWebState ||
            subscriptionContentState is SubscriptionContentInitialized ||
            subscriptionContentState is PurchaseRestored ||
            (subscriptionContentState is FailureState && prevState is! FailureState);
      },
      listener: (context, subscriptionContentState) async {
        if (subscriptionContentState is SubscriptionContentInitialized) {
          int index = 0;
          TabController controller;
          if (subscriptionContentState.user != null && subscriptionContentState.user.currentPlan != null) {
            index = subscriptionContentState.user.currentPlan.toInt();
          }
          if (subscriptionContentState.plans != null && subscriptionContentState.plans.isNotEmpty) {
            controller = TabController(vsync: this, animationDuration: Duration.zero, length: subscriptionContentState.plans.length);
          } else {
            controller = TabController(vsync: this, animationDuration: Duration.zero, length: 3);
          }
          _selectedIndex = index;
          _currentPlan = index;
          if (index < 0) {
            _selectedIndex = 0;
          }
          _controller = controller;
          _controller.addListener(_handleTabSelection);
        } else if (subscriptionContentState is PurchaseSuccess) {
          removeSubscriptionStream();
          AppMessages.clearAndShowSnackbarTranslated(context, 'successfullySubscribed');
          await AuthRepository().storeLoginData(subscriptionContentState.user);
          BlocProvider.of<AuthBloc>(context).updateAuthSuccess(subscriptionContentState.user, AuthRepository.getLoggedUser());
          if (widget.fromRegister) {
            BlocProvider.of<AuthBloc>(context).navigateToNextScreen(context, subscriptionContentState.user.id);
          } else {
            Navigator.of(context).pop();
          }
        } else if (subscriptionContentState is ManageFromWebState) {
          removeSubscriptionStream();
          AppMessages.clearAndShowSnackbarTranslated(context, 'manageSubscriptionFromWeb');
          Navigator.of(context).pop();
        } else if (subscriptionContentState is PurchaseRestored) {
          removeSubscriptionStream();
          AppMessages.clearAndShowSnackbarTranslated(context, 'subCancelledSuccessfully');
          await BlocProvider.of<AuthBloc>(context).logout(context);
        } else if (subscriptionContentState is FailureState) {
          AppMessages.clearAndShowSnackbarTranslated(context, 'somethingWentWrong');
          setState(() {});
          BlocProvider.of<SubscriptionContentBloc>(context).initState(widget.fromRegister);
        }
      },
      buildWhen: (context, subscriptionContentState) {
        return subscriptionContentState is SubscriptionContentLoading || subscriptionContentState is SubscriptionContentInitialized;
      },
      builder: (context, subscriptionContentState) {
        return WillPopScope(
          onWillPop: () async => _onWillPop(subscriptionContentState),
          child: Scaffold(
            backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
            appBar: OlukoAppBar(
              showTitle: !widget.fromRegister,
              showBackButton: !widget.fromRegister,
              reduceHeight: true,
              title: ProfileViewConstants.profileOptionsSubscription,
              showLogo: widget.fromRegister,
            ),
            body: getBody(subscriptionContentState),
          ),
        );
      },
    );
  }

  Align _selectPlanButton(SubscriptionContentInitialized state) {
    return Align(
      child: SizedBox(
        width: ScreenUtils.width(context) / 1.8,
        height: 60,
        child: OlukoNeumorphicPrimaryButton(
          isExpanded: false,
          flatStyle: true,
          onPressed: () {
            BlocProvider.of<SubscriptionContentBloc>(context).subscribe(state.plans[_selectedIndex], state.user.id);
          },
          title: OlukoLocalizations.get(context, 'selectPlan'),
        ),
      ),
    );
  }

  Padding _subscriptionBodyContent(BuildContext context, SubscriptionContentInitialized state, UserResponse user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SizedBox(
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

  Widget _subscriptionTitleSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Text(
        _currentPlan != null && _currentPlan >= 0 ? OlukoLocalizations.get(context, 'manageMembership') : OlukoLocalizations.get(context, 'paymentDetails'),
        textAlign: TextAlign.center,
        style: const TextStyle(color: OlukoColors.black, fontSize: 36, fontWeight: FontWeight.w600),
      ),
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

  SizedBox _subscriptionContent(BuildContext context, SubscriptionContentInitialized state, UserResponse user) {
    return SizedBox(
      width: ScreenUtils.width(context),
      height: ScreenUtils.height(context) / 5,
      child: TabBarView(controller: _controller, children: state.plans.map((plan) => _showSubscriptionCard(plan, user)).toList()),
    );
  }

  SubscriptionCard _showSubscriptionCard(Plan plan, UserResponse user) {
    final SubscriptionCard subscriptionCard = SubscriptionCard(plan);
    return subscriptionCard;
  }

  SizedBox _plansTabs(SubscriptionContentInitialized state, BuildContext context) {
    return SizedBox(
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
      ),
    );
  }

  Widget _tabBorderEffect(BuildContext context, Plan tabContent, SubscriptionContentInitialized state) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: !_isCurrentTabIndex(state, tabContent)
                  ? OlukoColors.primary
                  : _isCurrentPlan(state, tabContent)
                      ? OlukoColors.listGrayColor
                      : OlukoColors.subscriptionTabsColor,
              width: 4.0,
            ),
          ),
          color: _isCurrentPlan(state, tabContent) ? OlukoColors.listGrayColor : OlukoColors.subscriptionTabsColor,
        ),
        child: _tabContent(context, tabContent, state),
      ),
    );
  }

  bool _isCurrentTabIndex(SubscriptionContentInitialized state, Plan tabContent) => _selectedIndex == state.plans.indexOf(tabContent);

  bool _isCurrentPlan(SubscriptionContentInitialized state, Plan tabContent) => _currentPlan == state.plans.indexOf(tabContent);

  Container _tabContent(BuildContext context, Plan tabContent, SubscriptionContentInitialized state) {
    return Container(
      padding: EdgeInsets.zero,
      width: MediaQuery.of(context).size.width,
      child: Align(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              tabContent.name,
              style: OlukoFonts.olukoBigFont(
                customFontWeight: FontWeight.w600,
                customColor: _isCurrentPlan(state, tabContent) ? OlukoColors.white : OlukoColors.black,
              ),
            ),
            Text(
              '${_getCurrency(tabContent)} ${_getPrice(tabContent.applePrice.toString())}',
              style: TextStyle(color: _isCurrentPlan(state, tabContent) ? OlukoColors.white : OlukoColors.black),
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrency(Plan tabContent) => tabContent.currency == 'usd' ? '\$' : tabContent.currency;

  String _getPrice(String price) => price.length > 2 ? '${price.substring(0, price.length - 2)}.${price.substring(price.length - 2, price.length)}' : price;

  void _handleTabSelection() {
    setState(() {
      _selectedIndex = _controller.index;
    });
  }

  Align _cancelButton() {
    return Align(
      child: SizedBox(
        width: ScreenUtils.width(context) / 1.8,
        height: 60,
        child: OlukoNeumorphicWhiteButton(
          isExpanded: false,
          useBorder: true,
          flatStyle: true,
          onPressed: () async {
            if (_currentPlan == -1) {
              await BlocProvider.of<AuthBloc>(context).logout(context);
            } else {
              Navigator.pop(context);
            }
          },
          title: OlukoLocalizations.get(context, 'cancel'),
        ),
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
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: false,
                  shrinkWrap: true,
                  children: [
                    _subscriptionTitleSection(context),
                    _subscriptionBodyContent(context, state, state.user),
                    _selectPlanButton(state),
                    if (widget.fromRegister) _cancelButton(),
                    _displayTermsAndConditionsPlusPrivacyPolicy(),
                    _getCurrentPlanDetalsText(state)
                  ],
                )
              : const SizedBox(),
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

  PlanDetailsTextComponent _getCurrentPlanDetalsText(SubscriptionContentInitialized state) =>
      PlanDetailsTextComponent(currentIndex: _selectedIndex, plan: state.plans.elementAt(_selectedIndex));

  Padding _displayTermsAndConditionsPlusPrivacyPolicy() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: TermsAndConditionsPrivacyPolicyComponent(isReadOnly: true),
    );
  }

  removeSubscriptionStream() {
    BlocProvider.of<SubscriptionContentBloc>(context).dispose();
  }

  bool _onWillPop(SubscriptionContentState subscriptionContentState) {
    if (subscriptionContentState is SubscriptionContentInitialized) {
      return subscriptionContentState.user.currentPlan >= 0;
    }
    return false;
  }
}
