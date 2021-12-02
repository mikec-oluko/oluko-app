import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nil/nil.dart';
import 'package:oluko_app/blocs/done_challenge_users_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/submodels/user_submodel.dart';
import 'package:oluko_app/ui/components/audio_section.dart';
import 'package:oluko_app/ui/components/people_section.dart';
import 'package:oluko_app/ui/components/segment_step_section.dart';
import 'package:oluko_app/ui/components/vertical_divider.dart' as verticalDivider;
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/segment_utils.dart';

class SegmentImageSection extends StatefulWidget {
  final Function() onPressed;
  final Segment segment;
  final bool showBackButton;
  final int currentSegmentStep;
  final int totalSegmentStep;
  final String userId;
  final Function() audioAction;
  final Function(List<UserSubmodel> users, List<UserSubmodel> favorites) peopleAction;
  final Function() clockAction;

  SegmentImageSection(
      {this.onPressed = null,
      this.segment,
      this.showBackButton = true,
      this.currentSegmentStep,
      this.totalSegmentStep,
      this.userId,
      this.audioAction,
      this.clockAction,
      this.peopleAction,
      Key key})
      : super(key: key);

  @override
  _SegmentImageSectionState createState() => _SegmentImageSectionState();
}

class _SegmentImageSectionState extends State<SegmentImageSection> {
  @override
  void initState() {
    BlocProvider.of<DoneChallengeUsersBloc>(context).get(widget.segment.id, widget.userId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return imageWithButtons();
  }

  Widget imageWithButtons() {
    return Stack(children: [
      imageSection(),
      topButtons(),
      if (widget.segment.isChallenge) challengeButtons(),
      Padding(
          padding: const EdgeInsets.only(top: 270, right: 15, left: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.segment.isChallenge
                    ? (OlukoLocalizations.get(context, 'challengeTitle') + widget.segment.name)
                    : widget.segment.name,
                style: OlukoFonts.olukoTitleFont(custoFontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                widget.segment.description,
                style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.w400),
              ),
              SegmentStepSection(currentSegmentStep: widget.currentSegmentStep, totalSegmentStep: widget.totalSegmentStep),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: SegmentUtils.getSegmentSummary(widget.segment, context, OlukoColors.white))),
            ],
          ))
    ]);
  }

  Widget topButtons() {
    return Padding(
        padding: const EdgeInsets.only(top: 15),
        child: Row(
          children: [
            if (widget.showBackButton)
              IconButton(
                  icon: const Icon(Icons.chevron_left, size: 35, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                    if (widget.onPressed != null) {
                      widget.onPressed();
                    }
                  })
            else
              const SizedBox(),
            const Expanded(child: SizedBox()),
            Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Stack(alignment: Alignment.center, children: [
                  Image.asset(
                    'assets/courses/outlined_camera.png',
                    scale: 3,
                  ),
                  const Padding(padding: EdgeInsets.only(top: 1), child: Icon(Icons.circle_outlined, size: 16, color: OlukoColors.primary))
                ]))
          ],
        ));
  }

  Widget imageSection() {
    return Stack(alignment: Alignment.center, children: [
      AspectRatio(
          aspectRatio: 3 / 4,
          child: () {
            if (widget.segment.image != null) {
              return Image.network(
                widget.segment.image,
                fit: BoxFit.cover,
              );
            } else {
              return nil;
            }
          }()),
      Image.asset(
        'assets/courses/degraded.png',
        scale: 4,
      ),
    ]);
  }

  Widget challengeButtons() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 190),
      child: Column(children: [
        Row(children: [
          GestureDetector(onTap: widget.audioAction, child: const AudioSection(audioMessageQty: 10)),
          const verticalDivider.VerticalDivider(
            width: 30,
            height: 60,
          ),
          BlocBuilder<DoneChallengeUsersBloc, DoneChallengeUsersState>(builder: (context, doneChallengeUsersState) {
            if (doneChallengeUsersState is DoneChallengeUsersSuccess) {
              final int favorites = doneChallengeUsersState.favoriteUsers != null ? doneChallengeUsersState.favoriteUsers.length : 0;
              final int normalUsers = doneChallengeUsersState.users != null ? doneChallengeUsersState.users.length : 0;
              final int qty = favorites + normalUsers;
              return GestureDetector(
                  onTap: () => widget.peopleAction(doneChallengeUsersState.users, doneChallengeUsersState.favoriteUsers),
                  child: PeopleSection(peopleQty: qty, isChallenge: widget.segment.isChallenge));
            } else {
              return PeopleSection(peopleQty: 0, isChallenge: widget.segment.isChallenge);
            }
          }),
          const verticalDivider.VerticalDivider(
            width: 30,
            height: 60,
          ),
          GestureDetector(onTap: widget.clockAction, child: clockSection()),
        ])
      ]),
    );
  }

  Widget clockSection() {
    return Container(
      width: 60,
      child: Column(children: [
        Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Image.asset(
              'assets/courses/clock.png',
              height: 24,
              width: 27,
            )),
        const SizedBox(height: 5),
        Text(
          OlukoLocalizations.get(context, 'personalRecord'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: Colors.white),
        )
      ]),
    );
  }
}
