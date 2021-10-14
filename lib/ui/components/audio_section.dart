import 'package:flutter/material.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class AudioSection extends StatelessWidget {
  final int audioMessageQty;

  const AudioSection({ this.audioMessageQty }) : super();

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.topRight, children: [
      Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Image.asset(
            'assets/courses/audio.png',
            height: 50,
            width: 50,
          )),
      GestureDetector(
          onTap: () {},
          child: Stack(alignment: Alignment.center, children: [
            Image.asset(
              'assets/courses/audio_notification.png',
              height: 22,
              width: 22,
            ),
            Text(
              audioMessageQty.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w300, color: Colors.white),
            )
          ])),
    ]);
  }
}