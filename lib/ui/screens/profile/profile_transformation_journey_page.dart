import 'package:flutter/material.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';

class ProfileTransformationJourneyPage extends StatefulWidget {
  @override
  _ProfileTransformationJourneyPageState createState() =>
      _ProfileTransformationJourneyPageState();
}

class _ProfileTransformationJourneyPageState
    extends State<ProfileTransformationJourneyPage> {
  @override
  Widget build(BuildContext context) {
    final String _buttonText = "Tap to Upload";

    return Scaffold(
      appBar: OlukoAppBar(
        title: ProfileViewConstants.profileOptionsTransformationJourney,
        showSearchBar: false,
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        color: Colors.black,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: OlukoOutlinedButton(
                title: _buttonText,
                onPressed: () {},
              ),
            ),
            // TODO: Working on Gallery for Transformation Journey Content
          ],
        ),
      ),
    );
  }
}
