import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class PeopleSection extends StatelessWidget {
  final int peopleQty;
  final bool isChallenge;

  const PeopleSection({this.peopleQty, this.isChallenge = false}) : super();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(
        peopleQty != 0 ? '$peopleQty+' : '0',
        textAlign: TextAlign.center,
        style: OlukoNeumorphism.isNeumorphismDesign
            ? const TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: OlukoColors.primary)
            : const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      const SizedBox(height: 5),
      Text(
        isChallenge ? OlukoLocalizations.get(context, 'doneThis') : OlukoLocalizations.get(context, 'inThis'),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: Colors.white),
      ),
      Text(
        isChallenge ? OlukoLocalizations.get(context, 'challenge').toLowerCase() : OlukoLocalizations.get(context, 'course').toLowerCase(),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: Colors.white),
      ),
    ]);
  }
}
