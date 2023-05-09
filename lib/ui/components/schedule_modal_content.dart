import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/utils/weekdays_helper.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_divider.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:rrule/rrule.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/recommendation_bloc.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/utils/sound_player.dart';
import 'package:oluko_app/models/course_enrollment.dart';

class ScheduleModalContent extends StatefulWidget {
  final Course course;
  final CourseEnrollment courseEnrollment;
  final User user;
  final int totalClasses;
  final dynamic firstAppInteractionAt;
  final bool isCoachRecommendation;
  final AuthBloc blocAuth;
  final CourseEnrollmentBloc blocCourseEnrollment;
  final RecommendationBloc blocRecommendation;
  final VoidCallback onEnrollAction;
  final VoidCallback onUpdateScheduleAction;
  final bool disableAction;

  const ScheduleModalContent({this.course, this.user, this.totalClasses, this.firstAppInteractionAt, this.isCoachRecommendation,
                        this.disableAction, this.blocAuth, this.blocCourseEnrollment, this.blocRecommendation, this.onEnrollAction,
                        this.courseEnrollment, this.onUpdateScheduleAction,});
  @override
  _ScheduleModalContentState createState() => _ScheduleModalContentState();
}

class _ScheduleModalContentState extends State<ScheduleModalContent> {

  final SoundPlayer _soundPlayer = SoundPlayer();
  List<DateTime> scheduledDates = [];

  @override
  void initState() {
    super.initState();
    WeekDaysHelper.reinitializeSelectedWeekDays();
    if (widget.courseEnrollment != null && widget.courseEnrollment.weekDays != null &&
        widget.courseEnrollment.weekDays.isNotEmpty){
        WeekDaysHelper.setSelectedWeekdays(widget.courseEnrollment.weekDays);
        scheduledDates = WeekDaysHelper.getRecurringDates(Frequency.daily, widget.totalClasses);
    }
    if (widget.course != null){
      _soundPlayer.init(SessionCategory.playback);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showScheduleDialog(context);
      },
      child: _showScheduleDialog(context),
    );
  }

  @override
  void dispose() {
    _soundPlayer?.dispose();
    super.dispose();
  }

  Widget _showScheduleDialog(BuildContext context){
    return Container(
            height: 500,
            decoration: const BoxDecoration(
              borderRadius: BorderRadiusDirectional.vertical(top: Radius.circular(20)),
              color:OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      OlukoLocalizations.get(context, 'setYourSchedule'),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  //TODO - Add line below when it's defined
                    // Align(
                    //   alignment: Alignment.centerLeft,
                    //   child: Container(
                    //     padding: const EdgeInsets.all(15),
                    //     width: MediaQuery.of(context).size.width,
                    //     decoration: const BoxDecoration(
                    //       borderRadius: BorderRadius.all(Radius.circular(12)),
                    //       color:OlukoColors.grayColorFadeTop,
                    //     ),
                    //     child: Text(
                    //       OlukoLocalizations.get(context, 'setYourSchedule'),
                    //       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: OlukoColors.white),
                    //     ),
                    //   ),
                    // ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: ListView.builder(
                        itemCount: WeekDaysHelper.weekdaysList.length,
                        itemBuilder: (context, index) {
                          return SizedBox(
                            height: 35,
                            child: Theme(
                              data: ThemeData(
                                unselectedWidgetColor: OlukoColors.grayColor,
                                backgroundColor: OlukoColors.white,
                              ),
                              child: StatefulBuilder(
                                builder: (BuildContext context, StateSetter setState) {
                                  return CheckboxListTile(
                                    checkColor: OlukoColors.black,
                                    activeColor: OlukoColors.primary,
                                    contentPadding: EdgeInsets.zero,
                                    title: Transform.translate(
                                      offset: const Offset(-10, 0),
                                      child: Text(
                                        OlukoLocalizations.get(context, WeekDaysHelper.weekdaysList[index]['name'].toString()),
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    controlAffinity: ListTileControlAffinity.leading,
                                    value: WeekDaysHelper.selectedWeekdays[index]['selected'] as bool,
                                    onChanged: (value) {
                                      setScheduledDates(index, value);
                                    },
                                    side: const BorderSide(
                                        color: OlukoColors.grayColor,
                                    ),
                                    checkboxShape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const OlukoNeumorphicDivider(isFadeOut: true,),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 60,
                            child: GestureDetector(
                              onTap: () {
                                skipSchedule(context);
                              },
                              child: Text(
                                OlukoLocalizations.get(context, 'skip'),
                                style: OlukoFonts.olukoBigFont(
                                  customFontWeight: FontWeight.w600,
                                  customColor: OlukoColors.grayColor,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            child: OlukoNeumorphicPrimaryButton(
                              isExpanded: false,
                              thinPadding: true,
                              title: OlukoLocalizations.get(context, 'save'),
                              onPressed: () {
                                scheduleCourse(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
  }

  Future<void> scheduleCourse(BuildContext context) async {
    if (widget.courseEnrollment == null){
      enrollCourse(context);
    }else{
      updateSchedule(context);
    }
    Navigator.pop(context);
  }

  Future<void> enrollCourse(BuildContext context) async {
    if (widget.disableAction == false) {
      if (widget.firstAppInteractionAt == null) {
        widget.blocAuth.storeFirstsUserInteraction(userIteraction: UserInteractionEnum.firstAppInteraction);
      }
      widget.blocCourseEnrollment.create(widget.user, widget.course);
      if (!widget.isCoachRecommendation) {
        widget.blocRecommendation.removeRecomendedCourse(widget.user.uid, widget.course.id);
      }
      await _soundPlayer.playAsset(soundEnum: SoundsEnum.enroll);
    }
    widget.onEnrollAction();
  }

  Future<void> skipSchedule(BuildContext context) async {
    if (widget.courseEnrollment == null){
      widget.course.scheduledDates = [];
      widget.course.weekDays = [];
      enrollCourse(context);
    }else{
      scheduledDates = [];
      widget.courseEnrollment.weekDays = [];
      updateSchedule(context);
    }
    Navigator.pop(context);
  }

  Future<void> updateSchedule(BuildContext context) async {
    widget.blocCourseEnrollment.scheduleCourse(widget.courseEnrollment, scheduledDates);
    widget.onUpdateScheduleAction();
  }

  void setScheduledDates(int index, bool value){
    setState(() {
      WeekDaysHelper.selectedWeekdays[index]['selected'] = value;
      if (widget.courseEnrollment != null){
        widget.courseEnrollment.weekDays = WeekDaysHelper.selectedWeekdays
                            .where((item) => item['selected'] as bool == true)
                            .map((item) => item['day'].toString())
                            .toList();
        scheduledDates = WeekDaysHelper.getRecurringDates(Frequency.daily, widget.totalClasses);
      }else{
        widget.course.weekDays = WeekDaysHelper.selectedWeekdays
                            .where((item) => item['selected'] as bool == true)
                            .map((item) => item['day'].toString())
                            .toList();
        widget.course.scheduledDates = WeekDaysHelper.getRecurringDates(Frequency.daily, widget.totalClasses);
      }
    });
  }

}
