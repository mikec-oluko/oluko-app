import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/personal_record_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/submodels/personal_record.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
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
    BlocProvider.of<PersonalRecordBloc>(context).get(widget.segmentId, widget.userId, context);
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 100,
      padding: EdgeInsets.zero,
      child: BlocBuilder<PersonalRecordBloc, PersonalRecordState>(builder: (context, personalRecordState) {
        return Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/courses/gray_background.png'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
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
              if (personalRecordState is PersonalRecordSuccess)
                personalRecordGrid(personalRecordState.personalRecords)
              else
                const SizedBox()
            ],
          ),
        );
      }),
    );
  }

  Widget personalRecordGrid(List<PersonalRecord> personalRecords) {
    if (personalRecords.isNotEmpty) {
      return GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 1,
          children: personalRecords
              .map((record) => Column(
                    children: [
                      const Divider(height: 4, thickness: 0, color: OlukoColors.muted),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(record.title,
                                  style: const TextStyle(color: OlukoColors.white, fontSize: 17, fontWeight: FontWeight.w400)),
                              Text(record.date,
                                  style: const TextStyle(color: OlukoColors.grayColor, fontSize: 12, fontWeight: FontWeight.w400))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: record.image != null
                                  ? Image.network(record.image, fit: BoxFit.cover, width: 65, height: 90)
                                  : SizedBox.shrink()),
                        ),
                      ])
                    ],
                  ))
              .toList());
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20, top: 10),
        child: TitleBody(OlukoLocalizations.get(context, 'noPersonalRecords')),
      );
    }
  }
}
