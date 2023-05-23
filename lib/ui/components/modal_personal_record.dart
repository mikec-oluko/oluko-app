import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/personal_record_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/personal_record.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/segment_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';

class ModalPersonalRecord extends StatefulWidget {
  String segmentId;
  String userId;
  ModalPersonalRecord({this.segmentId, this.userId});

  @override
  _ModalPersonalRecordState createState() => _ModalPersonalRecordState();
}

class _ModalPersonalRecordState extends State<ModalPersonalRecord> {
  @override
  Widget build(BuildContext context) {
    BlocProvider.of<PersonalRecordBloc>(context).get(widget.segmentId, widget.userId);
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 100,
      padding: EdgeInsets.zero,
      child: BlocBuilder<PersonalRecordBloc, PersonalRecordState>(builder: (context, personalRecordState) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            gradient: OlukoNeumorphism.olukoNeumorphicGradientDark(),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15, top: 35),
                    child: Text(OlukoLocalizations.get(context, 'personalRecord'),
                        style: const TextStyle(color: OlukoColors.grayColor, fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              if (personalRecordState is PersonalRecordSuccess) personalRecordGrid(personalRecordState.personalRecords) else const SizedBox()
            ],
          ),
        );
      }),
    );
  }

  Widget personalRecordGrid(List<PersonalRecord> personalRecords) {
    if (personalRecords.isNotEmpty) {
      return Container(
          height: ScreenUtils.height(context) / 1.8,
          width: ScreenUtils.width(context),
          child: ListView(addAutomaticKeepAlives: false, addRepaintBoundaries: false, children: getPRWidgets(personalRecords)));
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20, top: 10),
        child: TitleBody(OlukoLocalizations.get(context, 'noPersonalRecords')),
      );
    }
  }

  List<Widget> getPRWidgets(List<PersonalRecord> personalRecords) {
    List<Widget> PRWidgets = personalRecords
        .map((record) => Column(
              children: [
                const Divider(height: 4, thickness: 0, color: OlukoColors.muted),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(record.value.toString() + " " + SegmentUtils.getParamLabel(record.parameter),
                            style: const TextStyle(color: OlukoColors.white, fontSize: 17, fontWeight: FontWeight.w400)),
                        Text(TimeConverter.returnDateOnStringFormat(dateToFormat: record.createdAt, context: context),
                            style: const TextStyle(color: OlukoColors.grayColor, fontSize: 12, fontWeight: FontWeight.w400))
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: ClipRRect(borderRadius: BorderRadius.circular(4), child: getPRImage(record)),
                  ),
                ])
              ],
            ))
        .toList();
    return PRWidgets;
  }

  Widget getPRImage(PersonalRecord record) {
    if (record.doneFromProfile != null && record.doneFromProfile) {
      return record.segmentImage != null
          ? Image(image: CachedNetworkImageProvider(record.segmentImage), fit: BoxFit.cover, width: 65, height: 90)
          : SizedBox.shrink();
    } else {
      return record.courseImage != null
          ? Image(image: CachedNetworkImageProvider(record.courseImage), fit: BoxFit.cover, width: 65, height: 90)
          : SizedBox.shrink();
    }
  }
}
