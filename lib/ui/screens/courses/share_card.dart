import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class ShareCard extends StatefulWidget {
  final Function() createStory;
  final Function(bool) whistleAction;
  final String videoRecordedThumbnail;

  ShareCard({this.createStory, this.whistleAction, this.videoRecordedThumbnail});

  @override
  _State createState() => _State();
}

class _State extends State<ShareCard> {
  List<Movement> segmentMovements;
  bool _storyEnabled = GlobalConfiguration().getString('showStories') == 'true';
  bool _whistleEnabled = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDarker),
      child: Padding(
        padding: const EdgeInsets.only(right: 15.0, left: 25.0, top: 12, bottom: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        OlukoLocalizations.of(context).find('shareYourVideo'),
                        style: OlukoFonts.olukoBigFont(),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      thumbnailImage(),
                      SizedBox(
                        width: 40,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          neumorphicStoryButton(),
                          SizedBox(
                            width: 40,
                          ),
                          neumorphicWhistleButton(),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget thumbnailImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(5)),
      child: Container(
          width: 80,
          height: 120,
          child: widget.videoRecordedThumbnail != null
              ? Image(
                  image: CachedNetworkImageProvider(widget.videoRecordedThumbnail),
                )
              : Image.asset(
                  'assets/assessment/workout_finished.png',
                  scale: 1,
                )),
    );
  }

  void _onTap() {
    if (_storyEnabled) {
      widget.createStory();
    }
    setState(() => _storyEnabled = false);
  }

  Widget whistleButton() {
    return GestureDetector(
        onTap: () {
          if (!_whistleEnabled) {
            widget.whistleAction(true);
          } else {
            widget.whistleAction(false);
          }

          setState(() => _whistleEnabled = !_whistleEnabled);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 2.0),
                  child: Image.asset(
                    'assets/courses/whistle.png',
                    scale: 8,
                    color: _whistleEnabled ? null : Colors.grey,
                  )),
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                child: Row(children: [
                  Text('Coach', style: _whistleEnabled ? OlukoFonts.olukoMediumFont() : OlukoFonts.olukoMediumFont(customColor: Colors.grey)),
                  if (!_whistleEnabled) doubleCheck()
                ]),
              )
            ],
          ),
        ));
  }

  Widget neumorphicWhistleButton() {
    return GestureDetector(
        /* 
        commented for now, because segments are uploaded automatically to coach
         onTap: () {
          if (!_whistleEnabled) {
            widget.whistleAction(true);
          } else {
            widget.whistleAction(false);
          }

          setState(() => _whistleEnabled = !_whistleEnabled);
        },*/
        child: Column(
      children: [
        Neumorphic(
          style: OlukoNeumorphism.getNeumorphicStyleForCircleElementNegativeDepth().copyWith(
            lightSource: LightSource.bottom,
            intensity: 1,
            color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
            border: NeumorphicBorder(width: 1, color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                if (_whistleEnabled)
                  Image.asset(
                    'assets/bottom_navigation_bar/selected_coach.png',
                    scale: 2.6,
                  )
                else
                  Image.asset(
                    'assets/bottom_navigation_bar/coach_neumorphic.png',
                    scale: 3,
                  )
              ],
            ),
          ),
        ),
        Row(children: [
          Text('Coach', style: _whistleEnabled ? OlukoFonts.olukoMediumFont() : OlukoFonts.olukoMediumFont(customColor: Colors.grey)),
          if (!_whistleEnabled) doubleCheck()
        ])
      ],
    ));
  }

  Widget storyButton() {
    return GestureDetector(
      onTap: _storyEnabled ? _onTap : null,
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Column(
          children: [
            Image.asset(
              'assets/courses/story.png',
              scale: 8.4,
              color: _storyEnabled ? null : Colors.grey,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
              child: Row(
                children: [
                  Text('Story', style: _storyEnabled ? OlukoFonts.olukoMediumFont() : OlukoFonts.olukoMediumFont(customColor: Colors.grey)),
                  if (!_storyEnabled && GlobalConfiguration().getString('showStories') == 'true') doubleCheck(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget neumorphicStoryButton() {
    return GestureDetector(
      onTap: _storyEnabled ? _onTap : null,
      child: Column(
        children: [
          Neumorphic(
            style: OlukoNeumorphism.getNeumorphicStyleForCircleElementNegativeDepth().copyWith(
              lightSource: LightSource.bottom,
              intensity: 1,
              color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
              border: NeumorphicBorder(width: 1, color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  if (_storyEnabled)
                    Image.asset(
                      'assets/courses/neumorphic_story.png',
                      scale: 3,
                    )
                  else
                    Image.asset(
                      'assets/courses/story.png',
                      scale: 9,
                      color: Colors.grey,
                    ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Text('Story', style: _storyEnabled ? OlukoFonts.olukoMediumFont() : OlukoFonts.olukoMediumFont(customColor: Colors.grey)),
              if (!_storyEnabled && GlobalConfiguration().getString('showStories') == 'true') doubleCheck() else SizedBox()
            ],
          ),
        ],
      ),
    );
  }

  Widget doubleCheck() {
    return Stack(
      children: [Image.asset('assets/assessment/check.png', scale: 5), Positioned(left: 4, child: Image.asset('assets/assessment/check.png', scale: 5))],
    );
  }
}
