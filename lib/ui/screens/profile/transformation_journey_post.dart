import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';

class TransformationJourneyPostPage extends StatefulWidget {
  final List<Widget> content;
  TransformationJourneyPostPage({this.content});
  @override
  _TransformationJourneyPostPageState createState() => _TransformationJourneyPostPageState();
}

class _TransformationJourneyPostPageState extends State<TransformationJourneyPostPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
      appBar: OlukoAppBar(
        title: "Post",
        showSearchBar: false,
      ),
      body: Container(
        color: OlukoColors.black,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: OlukoPrimaryButton(
                      title: "Upload",
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 150, 10, 0),
              child: GridView.count(
                crossAxisCount: 2,
                children: widget.content,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
