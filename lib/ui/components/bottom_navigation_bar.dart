import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/models/oluko_bottom_navigation_bar_item.dart';
import 'package:oluko_app/utils/screen_utils.dart';

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
    return BottomNavigationBar(
        currentIndex: selectedIndex,
        showUnselectedLabels: true,
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        onTap: (num index) => this.setState(() {
              selectedIndex = index;
            }),
        items: getNavigationItems(selectedIndex: selectedIndex));
  }

  BottomNavigationBarItem bottomNavigationBarItem(
      OlukoBottomNavigationBarItem olukoBottomNavigationBarItem) {
    double blockSize =
        MediaQuery.of(context).orientation == Orientation.portrait
            ? ScreenUtils.width(context) / 5
            : ScreenUtils.height(context) / 5;
    return BottomNavigationBarItem(
        icon: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.white24, width: 1)),
            color: olukoBottomNavigationBarItem.selected
                ? OlukoColors.primary
                : Colors.black,
          ),
          width: blockSize,
          height: blockSize,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ImageIcon(AssetImage(olukoBottomNavigationBarItem.assetImageUrl)),
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  olukoBottomNavigationBarItem.title,
                  style: TextStyle(
                      color: olukoBottomNavigationBarItem.selected
                          ? Colors.black
                          : Colors.white),
                ),
              )
            ],
          ),
        ),
        label: '');
  }

  List<BottomNavigationBarItem> getNavigationItems({num selectedIndex = 0}) {
    List<OlukoBottomNavigationBarItem> items = [
      OlukoBottomNavigationBarItem(
          title: 'Home',
          assetImageUrl: 'assets/bottom_navigation_bar/home.png'),
      OlukoBottomNavigationBarItem(
          title: 'Coach',
          assetImageUrl: 'assets/bottom_navigation_bar/coach.png'),
      OlukoBottomNavigationBarItem(
          title: 'Friends',
          assetImageUrl: 'assets/bottom_navigation_bar/friends.png'),
      OlukoBottomNavigationBarItem(
          title: 'Courses',
          assetImageUrl: 'assets/bottom_navigation_bar/course.png'),
      OlukoBottomNavigationBarItem(
          title: 'Profile',
          assetImageUrl: 'assets/bottom_navigation_bar/profile.png'),
    ];

    items[selectedIndex].selected = true;
    return items.map((item) => bottomNavigationBarItem(item)).toList();
  }
}
