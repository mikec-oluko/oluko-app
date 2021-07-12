import 'package:flutter/material.dart';

class FriendsListPage extends StatefulWidget {
  @override
  _FriendsListPageState createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.blue,
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            color: Colors.white,
            height: 100,
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              CircleAvatar(
                backgroundColor: Colors.red,
                radius: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text("Hello"),
                        Text("Word"),
                      ],
                    ),
                    Text("Word"),
                  ],
                ),
              )
            ]),
          )
        ],
      ),
    );
  }
}
