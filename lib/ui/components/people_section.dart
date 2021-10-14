import 'package:flutter/material.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class PeopleSection extends StatelessWidget {
  final int peopleQty;

  const PeopleSection({ this.peopleQty }) : super();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(
        '$peopleQty+',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      const SizedBox(height: 5),
      Text(
        OlukoLocalizations.get(context, 'inThis'),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: Colors.white),
      ),
      Text(
        OlukoLocalizations.get(context, 'course').toLowerCase(),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: Colors.white),
      ),
    ]);
  }
}