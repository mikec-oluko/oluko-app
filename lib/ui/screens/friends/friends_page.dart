import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/community_tab_friend_notification_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/blocs/user_list_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/search_results.dart';
import 'package:oluko_app/models/submodels/friend_request_model.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/search_bar.dart';
import 'package:oluko_app/ui/screens/friends/friends_list_page.dart';
import 'package:oluko_app/ui/screens/friends/friends_requests_page.dart';
import 'package:oluko_app/utils/app_navigator.dart';
import 'package:oluko_app/utils/community_tab.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/search_utils.dart';

class FriendsPage extends StatefulWidget {
  Function showBottomTab;
  FriendsPage({this.showBottomTab, Key key}) : super(key: key);
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> with SingleTickerProviderStateMixin {
  TabController _tabController;
  int _activeTabIndex;
  final int _numOfTabs = 2;
  final String _title = "Friends";
  AuthSuccess _authStateData;
  final searchFriendsKey = GlobalKey<SearchState>();
  TextEditingController searchBarController;
  SearchResults<UserResponse> searchResults = SearchResults(query: '', suggestedItems: []);
  List<UserResponse> _users = [];
  List<dynamic> _friendNotifications = [];

  @override
  void initState() {
    _tabController = TabController(length: _numOfTabs, vsync: this);
    BlocProvider.of<UserListBloc>(context).get();
    BlocProvider.of<CommunityTabFriendNotificationBloc>(context).listenFriendRequestByUserId();
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

  void _setFriendsRequestAsViews({int value}) {
    if (value == 1) {
      BlocProvider.of<CommunityTabFriendNotificationBloc>(context).setFriendsRequestAsViews();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
      appBar: _appBar(),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthSuccess && _authStateData == null) {
            _authStateData = authState;
            //TODO: CHECK IF NEED IT INSIDE TABS
            BlocProvider.of<FriendBloc>(context).getFriendsByUserId(_authStateData.user.id);
          }
          return BlocBuilder<UserListBloc, UserListState>(
            builder: (context, state) {
              if (state is UserListSuccess) {
                _users = state.users;
                _users.removeWhere((element) => element.id == _authStateData.user.id);
              }
              return _usersWidget(context);
            },
          );
        },
      ),
    );
  }

  Widget _body() {
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
                    color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            FriendsListPage(
                              currentUser: _authStateData.user,
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
          shadowDarkColorEmboss: OlukoColors.black,
          shadowLightColorEmboss: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
          surfaceIntensity: 1,
          shadowLightColor: Colors.white,
          shadowDarkColor: OlukoColors.black),
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
                _setFriendsRequestAsViews(value: value);
              },
              labelPadding: EdgeInsets.all(0),
              indicatorColor: OlukoColors.grayColor,
              indicator: BoxDecoration(
                  borderRadius: _activeTabIndex == 0
                      ? const BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5))
                      : const BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
                  color: OlukoColors.primary),
              unselectedLabelColor: OlukoColors.white,
              labelColor: OlukoColors.white,
              controller: _tabController,
              tabs: [
                Tab(text: OlukoLocalizations.get(context, 'friends')),
                BlocBuilder<CommunityTabFriendNotificationBloc, CommunityTabFriendNotificationState>(
                  builder: (context, state) {
                    return Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (state is CommunityTabFriendsNotification && CommunityTabUtils.friendNotificationsAreSeen(state.friendNotifications))
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          Text(OlukoLocalizations.get(context, 'requests') +
                              (state is CommunityTabFriendsNotification && state.friendNotifications.isNotEmpty
                                  ? ' (${state.friendNotifications.length})'
                                  : '')),
                        ],
                      ),
                    );
                  },
                )
              ]),
        ),
      ],
    );
  }

  PreferredSizeWidget _appBar() {
    return OlukoAppBar<UserResponse>(
      showBottomTab: widget.showBottomTab,
      showTitle: true,
      searchKey: searchFriendsKey,
      showBackButton: false,
      title: OlukoLocalizations.get(context, 'community'),
      actions: [],
      onSearchSubmit: (SearchResults<UserResponse> results) => setState(() {
        searchResults = results;
      }),
      onSearchResults: (SearchResults results) => setState(() {
        searchResults = SearchResults<UserResponse>(query: results.query, searchResults: List<UserResponse>.from(results.searchResults));
      }),
      searchMethod: SearchUtils.searchUserMethod,
      suggestionMethod: SearchUtils.suggestionMethodForUsers,
      searchResultItems: _users,
      showSearchBar: true,
      whenSearchBarInitialized: (TextEditingController controller) => searchBarController = controller,
    );
  }

  Widget _usersWidget(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      return Container(
        color: OlukoNeumorphismColors.appBackgroundColor,
        height: ScreenUtils.height(context),
        width: ScreenUtils.width(context),
        child: searchResults.query.isEmpty ? _body() : SearchUtils.searchUserResults(context, searchResults, _authStateData.user),
      );
    });
  }
}
