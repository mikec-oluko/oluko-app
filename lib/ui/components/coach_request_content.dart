import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/stories_item.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class CoachRequestContent extends StatefulWidget {
  final Function() onRecordingAction;
  final Function() onNotRecordingAction;
  final String image;
  final String name;

  const CoachRequestContent({this.onRecordingAction, this.onNotRecordingAction, this.image, this.name});

  @override
  _CoachRequestContentState createState() => _CoachRequestContentState();
}

class _CoachRequestContentState extends State<CoachRequestContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
          image: AssetImage('assets/courses/dialog_background.png'),
          fit: BoxFit.cover,
        )),
        child: Stack(children: [
          Column(children: [
            const SizedBox(height: 30),
            Stack(
                alignment: Alignment.center,
                children: [StoriesItem(maxRadius: 65, imageUrl: widget.image), Image.asset('assets/courses/photo_ellipse.png', scale: 4)]),
            const SizedBox(height: 15),
            Text(OlukoLocalizations.get(context, 'coach') + widget.name,
                textAlign: TextAlign.center, style: OlukoFonts.olukoSuperBigFont(custoFontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Text(OlukoLocalizations.get(context, 'coach') + widget.name + OlukoLocalizations.get(context, 'coachRequest'),
                    textAlign: TextAlign.center, style: OlukoFonts.olukoBigFont())),
            const SizedBox(height: 35),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OlukoOutlinedButton(
                      title: OlukoLocalizations.get(context, 'ignore'),
                      onPressed: () {
                        widget.onNotRecordingAction();
                      },
                    ),
                    const SizedBox(width: 20),
                    OlukoPrimaryButton(
                      title: 'Ok',
                      onPressed: () {
                        widget.onRecordingAction();
                      },
                    )
                  ],
                )),
          ]),
          Align(
              alignment: Alignment.topRight,
              child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)))
        ]));
  }
}
