import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/segment_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/ui/components/movement_item_bubbles.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_divider.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ClassMovementSection extends StatefulWidget {
  final Class classObj;
  final List<MovementSubmodel> movements;
  final Function() onPressedMovement;
  final PanelController panelController;

  ClassMovementSection({this.classObj, this.onPressedMovement, this.movements, this.panelController});

  @override
  _State createState() => _State();
}

class _State extends State<ClassMovementSection> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (!OlukoNeumorphism.isNeumorphismDesign)
        const Divider(
          color: OlukoColors.grayColor,
          height: 50,
        ),
      Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: Row(children: [
          Text(
            OlukoLocalizations.get(context, 'movesInThisClass'),
            style: OlukoNeumorphism.isNeumorphismDesign
                ? OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w500, customColor: OlukoColors.white)
                : OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w500, customColor: OlukoColors.grayColor),
          ),
          Expanded(child: SizedBox()),
          getViewDetails()
        ]),
      ),
      buildMovementBubbles(),
    ]);
  }

  Widget getViewDetails() {
    return BlocBuilder<SegmentBloc, SegmentState>(builder: (context, segmentState) {
      if (segmentState is GetSegmentsSuccess) {
        return GestureDetector(
            onTap: () => widget.panelController.open(),
            child: SizedBox(
              width: 85,
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  OlukoLocalizations.get(context, 'viewDetails'),
                  style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w500, customColor: OlukoColors.primary),
                ),
              ),
            ));
      } else {
        return Padding(
            padding: EdgeInsets.only(top: 3, right: 6),
            child: Container(height: 15, width: 15, child: OlukoCircularProgressIndicator(personalized: true, width: 2)));
      }
    });
  }

  Widget buildMovementBubbles() {
    return Padding(
        padding: const EdgeInsets.only(top: 25.0),
        child: MovementItemBubbles(showAsGrid: true, onPressed: widget.onPressedMovement, movements: widget.movements, width: ScreenUtils.width(context)));
  }
}
