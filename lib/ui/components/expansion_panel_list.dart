import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/basic_tiles.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/faq_item.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/services/url_launcher_service.dart';
import 'package:oluko_app/ui/components/parent_tile.dart';
import 'package:oluko_app/ui/newDesignComponents/help_and_support_tile_content_formatted.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class ExpansionPanelListWidget extends StatefulWidget {
  List<FAQItem> faqList;
  ExpansionPanelListWidget({this.faqList});
  @override
  _ExpansionPanelListState createState() => _ExpansionPanelListState();
}

class _ExpansionPanelListState extends State<ExpansionPanelListWidget> {
  final Uri _mvtTermsAndConditionsUrl = Uri.parse('https://www.mvtfitnessapp.com/terms');
  final Uri _mvtPrivacyPolicyUrl = Uri.parse('https://www.mvtfitnessapp.com/privacy-policy');
  @override
  Widget build(BuildContext context) {
    return Container(
      color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : OlukoColors.black,
      child: ListView(
        physics: OlukoNeumorphism.listViewPhysicsEffect,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
        children: [
          for (var type in FAQCategoriesEnum.values)
            ParentTileWidget(
              tile: BasicTile(title: OlukoLocalizations.get(context, fAQCategories[type]), tiles: [
                for (FAQItem faq in widget.faqList)
                  if (faq.category == type)
                    BasicTile(title: faq.question, tiles: [BasicTile(child: HelpAndSupportTileContentFormatted(rawTileStringContent: faq.answer))])
              ]),
            ),
          ParentTileWidget(
              tile: BasicTile(title: _termsAndConditionText(context), tiles: [
            BasicTile(
              child: InkWell(
                onTap: () => UrlLauncherService.openNewUrl(_mvtTermsAndConditionsUrl),
                child: Text(OlukoLocalizations.get(context, 'termsAndConditions'), style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.black)),
              ),
            ),
            BasicTile(
              child: InkWell(
                onTap: () => UrlLauncherService.openNewUrl(_mvtPrivacyPolicyUrl),
                child: Text(OlukoLocalizations.get(context, 'privacyPolicy'), style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.black)),
              ),
            )
          ])),
        ],
      ),
    );
  }

  String _termsAndConditionText(BuildContext context) {
    return OlukoLocalizations.get(context, 'termsAndConditions') + OlukoLocalizations.get(context, 'and') + OlukoLocalizations.get(context, 'privacyPolicy');
  }
}
