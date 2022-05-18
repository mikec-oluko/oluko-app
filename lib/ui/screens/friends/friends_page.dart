import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/blocs/user_list_bloc.dart';
import 'package:oluko_app/blocs/user_progress_stream_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/screens/friends/friends_list_page.dart';
import 'package:oluko_app/ui/screens/friends/friends_requests_page.dart';
import 'package:oluko_app/utils/app_navigator.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class FriendsPage extends StatefulWidget {
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> with SingleTickerProviderStateMixin {
  TabController _tabController;
  int _activeTabIndex;
  final int _numOfTabs = 2;
  final String _title = "Friends";
  AuthSuccess _authStateData;

  @override
  void initState() {
    _tabController = TabController(length: _numOfTabs, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _setActiveTabIndex({int value}) {
    setState(() {
      _activeTabIndex = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OlukoAppBar(
        showBackButton: false,
        title: _title,
        showTitle: true,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthSuccess && _authStateData == null) {
            _authStateData = authState;
            //TODO: CHECK IF NEED IT INSIDE TABS
            BlocProvider.of<UserListBloc>(context).get();
            BlocProvider.of<FriendBloc>(context).getFriendsByUserId(_authStateData.user.id);
          }
          return Container(
            color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
            child: WillPopScope(
              onWillPop: () => AppNavigator.onWillPop(context),
              child: Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: OlukoNeumorphism.isNeumorphismDesign
                            ? const EdgeInsets.symmetric(horizontal: 5, vertical: 20)
                            : const EdgeInsets.symmetric(horizontal: 5),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: OlukoNeumorphism.isNeumorphismDesign ? neumoprhicTabs() : defaultTabs(),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: OlukoNeumorphism.isNeumorphismDesign
                              ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark
                              : OlukoColors.black,
                          child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  FriendsListPage(
                                    authUser: _authStateData,
                                  ),
                                  FriendsRequestPage(
                                    authUser: _authStateData,
                                  )
                                ],
                              )),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Neumorphic neumoprhicTabs() {
    return Neumorphic(
      style: const NeumorphicStyle(
          shape: NeumorphicShape.flat,
          boxShape: NeumorphicBoxShape.stadium(),
          depth: 5,
          intensity: 0.35,
          border: NeumorphicBorder(width: 1.5, color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark),
          color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
          lightSource: LightSource.topLeft,
          shadowDarkColorEmboss: Colors.black,
          shadowLightColorEmboss: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
          surfaceIntensity: 1,
          shadowLightColor: Colors.white,
          shadowDarkColor: Colors.black),
      child: friendsTabs(),
    );
  }

  Widget defaultTabs() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: OlukoColors.grayColor,
      ),
      child: friendsTabs(),
    );
  }

  Row friendsTabs() {
    return Row(
      children: [
        Expanded(
          child: TabBar(
            onTap: (int value) {
              _setActiveTabIndex(value: value);
            },
            labelPadding: EdgeInsets.all(0),
            indicatorColor: OlukoColors.grayColor,
            indicator: BoxDecoration(
                borderRadius: _activeTabIndex == 0
                    ? BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5))
                    : BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
                color: OlukoColors.primary),
            unselectedLabelColor: OlukoColors.white,
            labelColor: OlukoColors.white,
            controller: _tabController,
            tabs: [Tab(text: OlukoLocalizations.get(context, 'friends')), Tab(text: OlukoLocalizations.get(context, 'requests'))],
          ),
        ),
      ],
    );
  }
}
