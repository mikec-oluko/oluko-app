import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/routes.dart';

class HelpAndSupportTileContentFormatted extends StatefulWidget {
  const HelpAndSupportTileContentFormatted({this.rawTileStringContent}) : super();
  final String rawTileStringContent;

  @override
  State<HelpAndSupportTileContentFormatted> createState() => _HelpAndSupportTileContentFormattedState();
}

class _HelpAndSupportTileContentFormattedState extends State<HelpAndSupportTileContentFormatted> {
  final RegExp _matchContactWord = RegExp(r'\b(contact|Contact)\b');

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
        tempTextElements.insert(1, _createLinkText());
        textElements.addAll(tempTextElements);
      } else if (pElement.contains('performance')) {
        textElements = [TextSpan(text: "PERFORMANCE: ${pElement}")];
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

  TextSpan _createLinkText() {
    return TextSpan(
      text: 'Contact',
      style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.coral),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          Navigator.pushNamed(
            context,
            routeLabels[RouteEnum.profileContactUs],
          );
        },
    );
  }

  String _removeBlankAddTextEnd(String pElement) => '${pElement.trim()}.';

  List<String> formatText(String rawText) => rawText.split('.').where((textContent) => textContent.isNotEmpty).toList();

  RichText _createRichTextElement(List<TextSpan> textContent) {
    return RichText(text: TextSpan(children: textContent));
  }
}
