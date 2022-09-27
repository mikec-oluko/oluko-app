import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/services/url_launcher_service.dart';

class HelpAndSupportTileContentFormatted extends StatefulWidget {
  const HelpAndSupportTileContentFormatted({this.rawTileStringContent}) : super();
  final String rawTileStringContent;

  @override
  State<HelpAndSupportTileContentFormatted> createState() => _HelpAndSupportTileContentFormattedState();
}

class _HelpAndSupportTileContentFormattedState extends State<HelpAndSupportTileContentFormatted> {
  final RegExp _matchContactWord = RegExp(r'\b(contact|Contact)\b');
  final RegExp _matPxPerformanceWord = RegExp(r'\b(PRx Performance|prx performance)\b');
  final Uri _prxPerformanceUrl = Uri.parse('https://prxperformance.com/');

  @override
  Widget build(BuildContext context) {
    return getRichText(widget.rawTileStringContent);
  }

  Widget getRichText(String inputText) {
    List<TextSpan> textElements = [];
    List<TextSpan> tempTextElements = [];
    List<String> _listOfParagraphs = formatText(inputText);
    _listOfParagraphs.forEach((pElement) {
      pElement = _removeBlankAddTextEnd(pElement);

      if (pElement.contains(_matchContactWord)) {
        tempTextElements = pElement
            .split(_matchContactWord)
            .map((pElementWidget) => TextSpan(text: pElementWidget, style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.black)))
            .toList();
        tempTextElements.insert(
            1,
            _createLinkText(
                textContent: 'contact',
                onTapFunction: () {
                  Navigator.pushNamed(
                    context,
                    routeLabels[RouteEnum.profileContactUs],
                  );
                }));
        textElements.addAll(tempTextElements);
      } else if (pElement.contains(_matPxPerformanceWord)) {
        tempTextElements = pElement
            .split(_matPxPerformanceWord)
            .map((pElementWidget) => TextSpan(text: pElementWidget, style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.black)))
            .toList();
        tempTextElements.insert(
            1,
            _createLinkText(
                textContent: 'PRx Performance',
                onTapFunction: () {
                  UrlLauncherService.openNewUrl(_prxPerformanceUrl);
                }));
        textElements.addAll(tempTextElements);
      } else {
        textElements.add(TextSpan(text: formatTextSpan(pElement), style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.black)));
      }
    });
    return _createRichTextElement(textElements);
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
        .replaceAll("'", "");
  }

  TextSpan _createLinkText({@required String textContent, @required Function() onTapFunction}) {
    return TextSpan(
      text: textContent,
      style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.skyblue, customFontWeight: FontWeight.bold).copyWith(decoration: TextDecoration.underline),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          onTapFunction();
        },
    );
  }

  String _removeBlankAddTextEnd(String pElement) => '${pElement.trim()}.';

  List<String> formatText(String rawText) => rawText.split('.').where((textContent) => textContent.isNotEmpty).toList();

  RichText _createRichTextElement(List<TextSpan> textContent) {
    return RichText(text: TextSpan(children: textContent));
  }
}
