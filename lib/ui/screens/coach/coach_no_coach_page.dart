import 'package:flutter/material.dart';
import 'package:nil/nil.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

import '../../../routes.dart';

class NoCoachPage extends StatefulWidget {
  const NoCoachPage();

  @override
  _NoCoachPageState createState() => _NoCoachPageState();
}

class _NoCoachPageState extends State<NoCoachPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OlukoAppBar(
        title: OlukoLocalizations.get(context, 'coach'),
        showBackButton: true,
        onPressed: () => Navigator.pushNamed(context, routeLabels[RouteEnum.root]),
      ),
      body: const Nil(),
    );
  }
}
