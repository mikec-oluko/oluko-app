import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class ShareCard extends StatefulWidget {
  ShareCard();

  @override
  _State createState() => _State();
}

class _State extends State<ShareCard> {
  List<Movement> segmentMovements;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: OlukoColors.listGrayColor),
      child: Padding(
        padding: const EdgeInsets.only(
            right: 15.0, left: 15.0, top: 18, bottom: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      flex: 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
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
                              OlukoLocalizations.of(context)
                                  .find('shareYourVideo'),
                              style: OlukoFonts.olukoBigFont(),
                              textAlign: TextAlign.start,
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/courses/story.png',
                                        scale: 8.4,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('Story',
                                            style:
                                                OlukoFonts.olukoMediumFont()),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8.0, bottom: 2.0),
                                          child: Image.asset(
                                            'assets/courses/whistle.png',
                                            scale: 8,
                                          )),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('Coach',
                                            style:
                                                OlukoFonts.olukoMediumFont()),
                                      )
                                    ],
                                  ),
                                ),
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
}
