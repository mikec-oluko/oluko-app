import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';

class SearchSuggestions<T> extends StatefulWidget {
  final String textInput;
  final List<T> itemList;
  final List<String> keyNameList;
  final Function(T) onPressed;

  SearchSuggestions({this.textInput, this.itemList, this.keyNameList, this.onPressed});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SearchSuggestions> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: widget.itemList.length,
        itemBuilder: (BuildContext context, int index) {
          final searchResultName = widget.keyNameList[index];
          final textInputSearchLength = widget.textInput.length;
          return ListTile(
              onTap: () => widget.onPressed(widget.itemList[index]),
              title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: RichText(
                      text: TextSpan(
                    children: [
                      TextSpan(
                          text: searchResultName.substring(0, textInputSearchLength),
                          style: const TextStyle(color: OlukoColors.searchSuggestionsAlreadyWrittenText)),
                      TextSpan(
                          text: searchResultName.substring(textInputSearchLength),
                          style: const TextStyle(color: OlukoColors.searchSuggestionsText))
                    ],
                  )),
                ),
                const Divider(
                  color: OlukoColors.divider,
                  height: 1,
                )
              ]));
        });
  }
}
