import 'package:flutter/material.dart';

class AudioSection extends StatelessWidget {
  final int audioMessageQty;
  final Function() onAudioPressed;

  const AudioSection({this.audioMessageQty, this.onAudioPressed}) : super();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAudioPressed,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Image.asset(
                'assets/courses/audio.png',
                height: 50,
                width: 50,
              )),
          if (audioMessageQty != null && audioMessageQty > 0)
            Stack(alignment: Alignment.center, children: [
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
            ])
          else
            const SizedBox(),
        ],
      ),
    );
  }
}
