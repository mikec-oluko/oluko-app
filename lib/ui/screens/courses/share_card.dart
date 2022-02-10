import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class ShareCard extends StatefulWidget {
  final Function() createStory;
  final Function(bool) whistleAction;

  ShareCard({this.createStory, this.whistleAction});

  @override
  _State createState() => _State();
}

class _State extends State<ShareCard> {
  List<Movement> segmentMovements;
  bool _storyEnabled = GlobalConfiguration().getValue('showStories') == 'true';
  bool _whistleEnabled = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: OlukoColors.listGrayColor),
      child: Padding(
        padding: const EdgeInsets.only(right: 15.0, left: 15.0, top: 18, bottom: 12.0),
        child: Column(
          children: [
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      flex: 2,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/assessment/task_response_thumbnail.png',
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                      )),
                  Expanded(
                    flex: 8,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15.0, top: 0),
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              OlukoLocalizations.of(context).find('shareYourVideo'),
                              style: OlukoFonts.olukoBigFont(),
                              textAlign: TextAlign.start,
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                storyButton(),
                                whistleButton(),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
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
                padding: const EdgeInsets.all(8.0),
                child: Row(children: [
                  Text('Coach',
                      style: _whistleEnabled ? OlukoFonts.olukoMediumFont() : OlukoFonts.olukoMediumFont(customColor: Colors.grey)),
                  if (!_whistleEnabled) doubleCheck()
                ]),
              )
            ],
          ),
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
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text('Story', style: _storyEnabled ? OlukoFonts.olukoMediumFont() : OlukoFonts.olukoMediumFont(customColor: Colors.grey)),
                  if (!_storyEnabled) doubleCheck(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget doubleCheck() {
    return Stack(
      children: [
        Image.asset('assets/assessment/check.png', scale: 5),
        Positioned(left: 4, child: Image.asset('assets/assessment/check.png', scale: 5))
      ],
    );
  }
}
