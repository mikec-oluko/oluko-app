import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/friend_bloc.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/helpers/page_content.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/bottom_navigation_bar.dart';
import 'package:oluko_app/ui/screens/friends/friends_list_page.dart';
import 'package:oluko_app/ui/screens/friends/friends_requests_page.dart';

class FriendsPage extends StatefulWidget {
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

final FriendBloc friendBloc = FriendBloc();

class _FriendsPageState extends State<FriendsPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  int _activeTabIndex;
  List<PageContent> _pages = [
    PageContent("Friends",
        BlocProvider.value(value: friendBloc, child: FriendsListPage())),
    PageContent("Requests",
        BlocProvider.value(value: friendBloc, child: FriendsRequestPage()))
  ];
  final String _title = "Friends";

  @override
  void initState() {
    setState(() {});
    _tabController = TabController(length: _pages.length, vsync: this);
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
          title: _title,
          // showSearchBar: true,
        ),
        body: Container(
          color: OlukoColors.black,
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: OlukoColors.grayColor,
                        ),
                        child: Expanded(
                          child: TabBar(
                            onTap: (int value) {
                              _setActiveTabIndex(value: value);
                            },
                            labelPadding: EdgeInsets.all(0),
                            indicatorColor: OlukoColors.grayColor,
                            indicator: BoxDecoration(
                                borderRadius: _activeTabIndex == 0
                                    ? BorderRadius.only(
                                        topLeft: Radius.circular(5),
                                        bottomLeft: Radius.circular(5))
                                    : BorderRadius.only(
                                        topRight: Radius.circular(5),
                                        bottomRight: Radius.circular(5)),
                                color: OlukoColors.primary),
                            unselectedLabelColor: OlukoColors.white,
                            labelColor: OlukoColors.black,
                            controller: _tabController,
                            tabs: [
                              Tab(
                                text: _pages[0].title,
                              ),
                              Tab(
                                text: _pages[1].title,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: OlukoColors.black,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: TabBarView(
                            controller: _tabController,
                            children: _pages
                                .map<Widget>((PageContent page) => page.page)
                                .toList()),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        bottomNavigationBar: OlukoBottomNavigationBar());
  }
}
