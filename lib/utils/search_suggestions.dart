import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';

class SearchSuggestionsUtils {
  List<TextSpan> getCourseTitle(
      int ocurrenceIndex, String searchResultName, String textInput) {
    List<TextSpan> texts = [];
    if (ocurrenceIndex == 0) {
      texts.add(getText(
          searchResultName.substring(ocurrenceIndex, textInput.length), true));
      texts.add(getText(
          searchResultName.substring(textInput.length, searchResultName.length),
          false));
    } else if (ocurrenceIndex == searchResultName.length) {
      texts.add(getText(searchResultName.substring(0, ocurrenceIndex), false));
      texts.add(getText(
          searchResultName.substring(ocurrenceIndex, textInput.length), true));
    } else {
      texts.add(getText(searchResultName.substring(0, ocurrenceIndex), false));
      texts.add(getText(
          searchResultName.substring(
              ocurrenceIndex, ocurrenceIndex + textInput.length),
          true));
      texts.add(getText(
          searchResultName.substring(
              ocurrenceIndex + textInput.length, searchResultName.length),
          false));
    }
    return texts;
  }

  TextSpan getText(String text, bool isWrittenSuggestion) {
    return TextSpan(
        text: text,
        style: isWrittenSuggestion
            ? const TextStyle(
                color: OlukoColors.searchSuggestionsAlreadyWrittenText)
            : const TextStyle(color: OlukoColors.searchSuggestionsText));
  }
}
