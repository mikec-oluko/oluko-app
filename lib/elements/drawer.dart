import 'package:flutter/material.dart';

import 'package:oluko_app/constants/theme.dart';

import 'package:oluko_app/elements/drawer_tile.dart';

class OlukoDrawer extends StatelessWidget {
  final String currentPage;

  OlukoDrawer({this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Container(
      color: OlukoColors.white,
      child: Column(children: [
        Container(
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width * 0.85,
            child: SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Image.asset("assets/img/Oluko-logo.png"),
                ),
              ),
            )),
        Expanded(
          flex: 2,
          child: ListView(
            padding: EdgeInsets.only(top: 24, left: 16, right: 16),
            children: [
              DrawerTile(
                  icon: Icons.home,
                  tap: () {
                    if (currentPage != "Home")
                      Navigator.pushReplacementNamed(context, '/home');
                  },
                  iconColor: OlukoColors.primary,
                  title: "Home",
                  isSelected: currentPage == "Home" ? true : false),
              DrawerTile(
                  icon: Icons.pie_chart,
                  tap: () {
                    if (currentPage != "Profile")
                      Navigator.pushReplacementNamed(context, '/profile');
                  },
                  iconColor: OlukoColors.warning,
                  title: "Profile",
                  isSelected: currentPage == "Profile" ? true : false),
              DrawerTile(
                  icon: Icons.account_circle,
                  tap: () {
                    if (currentPage != "Account")
                      Navigator.pushReplacementNamed(context, '/account');
                  },
                  iconColor: OlukoColors.info,
                  title: "Account",
                  isSelected: currentPage == "Account" ? true : false),
              DrawerTile(
                  icon: Icons.settings_input_component,
                  tap: () {
                    if (currentPage != "Elements")
                      Navigator.pushReplacementNamed(context, '/elements');
                  },
                  iconColor: OlukoColors.error,
                  title: "Elements",
                  isSelected: currentPage == "Elements" ? true : false),
              DrawerTile(
                  icon: Icons.apps,
                  tap: () {
                    if (currentPage != "Articles")
                      Navigator.pushReplacementNamed(context, '/articles');
                  },
                  iconColor: OlukoColors.primary,
                  title: "Articles",
                  isSelected: currentPage == "Articles" ? true : false),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
              padding: EdgeInsets.only(left: 8, right: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(height: 4, thickness: 0, color: OlukoColors.muted),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 16.0, left: 16, bottom: 8),
                    child: Text("DOCUMENTATION",
                        style: TextStyle(
                          color: Color.fromRGBO(0, 0, 0, 0.5),
                          fontSize: 15,
                        )),
                  ),
                  DrawerTile(
                      icon: Icons.airplanemode_active,
                      iconColor: OlukoColors.muted,
                      title: "Getting Started",
                      isSelected:
                          currentPage == "Getting started" ? true : false),
                ],
              )),
        ),
      ]),
    ));
  }
}
