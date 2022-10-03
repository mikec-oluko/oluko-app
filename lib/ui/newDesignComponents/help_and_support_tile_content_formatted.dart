import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/services/url_launcher_service.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:flutter/foundation.dart';

class HelpAndSupportTileContentFormatted extends StatefulWidget {
  const HelpAndSupportTileContentFormatted({this.rawTileStringContent}) : super();
  final String rawTileStringContent;

  @override
  State<HelpAndSupportTileContentFormatted> createState() => _HelpAndSupportTileContentFormattedState();
}

class _HelpAndSupportTileContentFormattedState extends State<HelpAndSupportTileContentFormatted> {
  final RegExp _matchContactWord = RegExp(r'\b(contact|Contact)\b');
  final RegExp _matchPxPerformanceWord = RegExp(r'\b(PRx Performance|prx performance)\b');
  final Uri _prxPerformanceUrl = Uri.parse('https://prxperformance.com/');

  @override
  Widget build(BuildContext context) {
    return getRichText(widget.rawTileStringContent);
  }

  Widget getRichText(String inputText) {
    List<TextSpan> _textElementsToReturn = [];
    List<TextSpan> _textElementsWithLinks = [];
    List<String> _listOfParagraphs = formatText(inputText);
    _listOfParagraphs.forEach((pElement) {
      pElement = _removeBlankAddTextEnd(pElement);

      if (pElement.contains(_matchContactWord)) {
        _textElementsWithLinks = newTextSpanElement(textToMatch: pElement, matchRegExp: _matchContactWord);
        _textElementsWithLinks.insert(
            1,
            _createLinkText(
                textContent: OlukoLocalizations.get(context, 'contact'),
                onTapFunction: () {
                  Navigator.pushNamed(
                    context,
                    routeLabels[RouteEnum.profileContactUs],
                  );
                }));
        _textElementsToReturn.addAll(_textElementsWithLinks);
      } else if (pElement.contains(_matchPxPerformanceWord)) {
        _textElementsWithLinks = newTextSpanElement(textToMatch: pElement, matchRegExp: _matchPxPerformanceWord);
        _textElementsWithLinks.insert(
            1,
            _createLinkText(
                textContent: OlukoLocalizations.get(context, 'prxPerformance'),
                onTapFunction: () {
                  UrlLauncherService.openNewUrl(_prxPerformanceUrl);
                }));
        _textElementsToReturn.addAll(_textElementsWithLinks);
      } else {
        _textElementsToReturn.add(TextSpan(text: formatTextSpan(pElement), style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.black)));
      }
    });
    return _createRichTextElement(_textElementsToReturn);
  }

  List<TextSpan> newTextSpanElement({String textToMatch, RegExp matchRegExp}) {
    return textToMatch
        .split(matchRegExp)
        .map((textContentForSpan) => TextSpan(text: textContentForSpan, style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.black)))
        .toList();
  }

  String formatTextSpan(String text) {
    return text
        .split('.')
        .toList()
        .where((element) => element.isNotEmpty)
        .toList()
        .map((e) => "$e.'\n'")
        .toList()
        .toString()
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll("'", '');
  }

  TextSpan _createLinkText({@required String textContent, @required Function() onTapFunction}) {
    return TextSpan(
      text: textContent,
      style: OlukoFonts.olukoSmallFont(customColor: OlukoNeumorphismColors.olukoNeumorphicBlueBackgroundColor, customFontWeight: FontWeight.bold)
          .copyWith(decoration: TextDecoration.underline),
      recognizer: TapGestureRecognizer()..onTap = () => onTapFunction(),
    );
  }

  String _removeBlankAddTextEnd(String pElement) => '${pElement.trim()}.';

  List<String> formatText(String rawText) => rawText.split('.').where((textContent) => textContent.isNotEmpty).toList();

  RichText _createRichTextElement(List<TextSpan> textContent) {
    return RichText(text: TextSpan(children: textContent));
  }
}
