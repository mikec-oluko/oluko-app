import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsAndConditionsPrivacyPolicyComponent extends StatefulWidget {
  const TermsAndConditionsPrivacyPolicyComponent({this.onPressed, this.currentValue, this.isReadOnly = false}) : super();
  final Function(bool) onPressed;
  final bool currentValue;
  final bool isReadOnly;
  @override
  State<TermsAndConditionsPrivacyPolicyComponent> createState() => _TermsAndConditionsPrivacyPolicyComponentState();
}

class _TermsAndConditionsPrivacyPolicyComponentState extends State<TermsAndConditionsPrivacyPolicyComponent> {
  @override
  final Uri _mvtTermsAndConditionsUrl = Uri.parse('https://www.mvtfitnessapp.com/terms');
  final Uri _mvtPrivacyPolicyUrl = Uri.parse('https://www.mvtfitnessapp.com/privacy-policy');
  bool _agreeWithRequirements = false;

  Widget build(BuildContext context) {
    return !widget.isReadOnly
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Theme(
              data: ThemeData(
                unselectedWidgetColor: OlukoColors.primary,
              ),
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      checkColor: OlukoColors.black,
                      activeColor: Colors.white,
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      value: widget.currentValue,
                      title: Transform.translate(
                        offset: const Offset(-20, 0),
                        child: _textContent(context, isReadOnly: widget.isReadOnly),
                      ),
                      onChanged: (value) {
                        widget.onPressed(value);
                      })),
            ),
          )
        : _textContent(context);
  }

  Wrap _textContent(BuildContext context, {bool isReadOnly = false}) {
    return Wrap(
      children: [
        Text(OlukoLocalizations.get(context, isReadOnly ? 'seeTextForTermsAndConditions' : 'registerByContinuing'),
            style: OlukoFonts.olukoBigFont(customColor: OlukoColors.black)),
        InkWell(
          onTap: () => _launchUrl(_mvtTermsAndConditionsUrl),
          child: Text(OlukoLocalizations.get(context, 'termsAndConditions'),
              style: OlukoFonts.olukoBigFont(customColor: OlukoColors.primary).copyWith(decoration: TextDecoration.underline)),
        ),
        Text(OlukoLocalizations.get(context, 'and'), style: OlukoFonts.olukoBigFont(customColor: OlukoColors.black)),
        InkWell(
          onTap: () => _launchUrl(_mvtPrivacyPolicyUrl),
          child: Text(OlukoLocalizations.get(context, 'privacyPolicy'),
              style: OlukoFonts.olukoBigFont(customColor: OlukoColors.primary).copyWith(
                decoration: TextDecoration.underline,
              )),
        ),
      ],
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }
}
