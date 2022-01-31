import 'package:chewie/src/animated_play_pause.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';

class OlukoCenterPlayButton extends StatefulWidget {
  OlukoCenterPlayButton({
    Key key,
    this.backgroundColor,
    this.iconColor,
    this.show,
    this.isPlaying,
    this.isFinished,
    this.onPressed,
  }) : super(key: key);

  final Color backgroundColor;
  final Color iconColor;
  final bool show;
  final bool isPlaying, isFinished;
  final VoidCallback onPressed;

  @override
  State<OlukoCenterPlayButton> createState() => _OlukoCenterPlayButtonState();
}

class _OlukoCenterPlayButtonState extends State<OlukoCenterPlayButton> {
  bool _play = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: AnimatedOpacity(
          opacity: widget.show ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _play = !_play;
              });
              widget.onPressed();
            },
            child: SizedBox(
              height: 52,
              width: 52,
              child: OlukoBlurredButton(
                childContent: widget.isFinished
                    ? Icon(Icons.replay, color: widget.iconColor)
                    : _play
                        ? Image.asset(
                            'assets/courses/white_play.png',
                            scale: 3.5,
                          )
                        : Image.asset(
                            'assets/courses/white_pause.png',
                            scale: 3.5,
                          )
                /*AnimatedPlayPause(//todo:change icon
                            color: iconColor,
                            playing: isPlaying,
                          )*/
                ,
                //onPressed: onPressed,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
