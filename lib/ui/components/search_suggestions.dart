import 'package:flutter/material.dart';

class SearchSuggestions extends StatefulWidget {
  final Function(num) onTap;
  final List<String> items;

  SearchSuggestions({this.items, this.onTap});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SearchSuggestions> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: widget.items.length,
        itemBuilder: (BuildContext context, num index) {
          return Container(
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Colors.white24, width: 1))),
            child: GestureDetector(
              child: ListTile(
                title: Text(
                  widget.items[index],
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w300),
                ),
              ),
            ),
          );
        });
  }
}
