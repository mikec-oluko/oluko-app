import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_helper.dart';
import 'package:oluko_app/models/plan.dart';
import 'package:html/parser.dart';

class SubscriptionCard extends StatefulWidget {
  Plan plan;

  SubscriptionCard(this.plan);

  @override
  _State createState() => _State();
}

class _State extends State<SubscriptionCard> {
  @override
  Widget build(BuildContext context) {
    return _subscriptionCardForPlan();
  }

  Container _subscriptionCardForPlan() {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: OlukoColors.primary,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            color: OlukoColors.primary),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: OlukoColors.subscriptionTabsColor,
              ),
              child: ListView(
                  children: _parseHtmlString(widget.plan.description)
                      .map((element) => Padding(
                            padding: const EdgeInsets.fromLTRB(5, 10, 0, 0),
                            child: Text('- $element', style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.black)),
                          ))
                      .toList())),
        ));
  }

  List<String> _parseHtmlString(String htmlString) {
    var rows = parse(htmlString).getElementsByTagName('ul')[0].getElementsByTagName('li');
    return rows.map((element) => element.text).toList();
  }

  List<Widget> displayFeatures(List<String> items) {
    return items
        .map(
          (item) => Text(
            featureLabel[EnumHelper.enumFromString<PlanFeature>(PlanFeature.values, item)],
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w300),
          ),
        )
        .toList();
  }

  Widget getWaitList() {
    return Expanded(
      child: InkWell(
        onTap: () {} /*widget.onHintPressed()*/,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            Text(
              'Waitlist',
              style: TextStyle(color: OlukoColors.secondary),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Icon(
                Icons.help,
                color: OlukoColors.secondary,
              ),
            )
          ],
        ),
      ),
    );
  }
}
