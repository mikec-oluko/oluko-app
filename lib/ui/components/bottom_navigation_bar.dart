import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mvt_fitness/constants/theme.dart';
import 'package:mvt_fitness/models/oluko_bottom_navigation_bar_item.dart';
import 'package:mvt_fitness/utils/oluko_localizations.dart';
import 'package:mvt_fitness/utils/screen_utils.dart';

class OlukoBottomNavigationBar extends StatefulWidget {
  final Function() onPressed;
  final List<Widget> actions;

  OlukoBottomNavigationBar({this.onPressed, this.actions});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<OlukoBottomNavigationBar> {
  num selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    selectedIndex = getIndexFromRoute();
    return BottomNavigationBar(
        currentIndex: selectedIndex,
        showUnselectedLabels: true,
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        onTap: (num index) => this.setState(() {
              final OlukoBottomNavigationBarItem selectedItem =
                  getBottomNavigationBarItems()[index];
              if (selectedItem.disabled == false) {
                Navigator.popAndPushNamed(context, selectedItem.route);
                selectedIndex = index;
              }
            }),
        items: getNavigationBarWidgets(selectedIndex: selectedIndex));
  }

  BottomNavigationBarItem getBottomNavigationBarWidget(
      OlukoBottomNavigationBarItem olukoBottomNavigationBarItem) {
    double blockSize =
        MediaQuery.of(context).orientation == Orientation.portrait
            ? ScreenUtils.width(context) / 5
            : ScreenUtils.width(context) / 5;
    return BottomNavigationBarItem(
        icon: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.white24, width: 1)),
            color: olukoBottomNavigationBarItem.selected
                ? OlukoColors.primary
                : Colors.black,
          ),
          width: blockSize,
          height: MediaQuery.of(context).orientation == Orientation.portrait
              ? blockSize
              : blockSize / 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ImageIcon(AssetImage(olukoBottomNavigationBarItem.assetImageUrl),
                  color: olukoBottomNavigationBarItem.disabled
                      ? Colors.grey.shade800
                      : null),
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  olukoBottomNavigationBarItem.title,
                  style: TextStyle(
                      color: olukoBottomNavigationBarItem.disabled
                          ? Colors.grey.shade800
                          : olukoBottomNavigationBarItem.selected
                              ? Colors.black
                              : Colors.white),
                ),
              )
            ],
          ),
        ),
        label: '');
  }

  List<OlukoBottomNavigationBarItem> getBottomNavigationBarItems() {
    List<OlukoBottomNavigationBarItem> items = [
      OlukoBottomNavigationBarItem(
          title: OlukoLocalizations.of(context).find('home'),
          assetImageUrl: 'assets/bottom_navigation_bar/home.png',
          route: '/'),
      OlukoBottomNavigationBarItem(
          title: OlukoLocalizations.of(context).find('coach'),
          assetImageUrl: 'assets/bottom_navigation_bar/coach.png',
          route: '/coach',
          disabled: true),
      OlukoBottomNavigationBarItem(
          title: OlukoLocalizations.of(context).find('friends'),
          assetImageUrl: 'assets/bottom_navigation_bar/friends.png',
          route: '/friends',
          disabled: true),
      OlukoBottomNavigationBarItem(
          title: OlukoLocalizations.of(context).find('courses'),
          assetImageUrl: 'assets/bottom_navigation_bar/course.png',
          route: '/courses'),
      OlukoBottomNavigationBarItem(
          title: OlukoLocalizations.of(context).find('profile'),
          assetImageUrl: 'assets/bottom_navigation_bar/profile.png',
          route: '/profile'),
    ];
    return items;
  }

  getIndexFromRoute() {
    String routeName = ModalRoute.of(context).settings.name;
    num routeIndex;
    getBottomNavigationBarItems().asMap().forEach((key, value) {
      if (value.route == routeName) {
        routeIndex = key;
      }
    });
    return routeIndex;
  }

  List<BottomNavigationBarItem> getNavigationBarWidgets(
      {num selectedIndex = 0}) {
    List<OlukoBottomNavigationBarItem> items = getBottomNavigationBarItems();
    items[selectedIndex].selected = true;
    return items.map((item) => getBottomNavigationBarWidget(item)).toList();
  }
}
