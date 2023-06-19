import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:oluko_app/models/utils/json_utils.dart';
import 'package:oluko_app/models/utils/weekdays_helper.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/workout_day.dart';
import 'package:oluko_app/models/workout_schedule.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:rrule/rrule.dart';
import 'package:oluko_app/models/submodels/enrollment_class.dart';

class ScheduleUtils {
  static List<WorkoutDay> getThisWeekClasses(BuildContext context, List<CourseEnrollment> courseEnrollmentList){
    if (courseEnrollmentList.isEmpty){
      return [];
    }
    final List<WorkoutSchedule> workoutSchedules = getThisWeekScheduledWorkouts(context, courseEnrollmentList);
    final List<WorkoutDay> workoutClasses = getScheduledClassesGroupedByDay(workoutSchedules);
    return workoutClasses;
  }

  static List<WorkoutSchedule> getThisWeekScheduledWorkouts(BuildContext context, List<CourseEnrollment> courseEnrollmentList){
    final List<DateTime> thisWeekDates = WeekDaysHelper.getOneWeekDatesFromNow();
    final List<WorkoutSchedule> workoutSchedules = [];
    for (final courseEnrollment in courseEnrollmentList) {
      if (courseEnrollment.classes.isNotEmpty && courseEnrollment.classes.any((element) => element.scheduledDate != null)) {
        workoutSchedules.addAll(courseEnrollment.classes.where((classItem) =>
          classItem.completedAt == null &&
          thisWeekDates.any((weekDay) =>
            classItem.scheduledDate?.toDate()?.year == weekDay.year &&
            classItem.scheduledDate?.toDate()?.month == weekDay.month &&
            classItem.scheduledDate?.toDate()?.day == weekDay.day
          )
        ).map((workoutClassDay) {
          final DateTime scheduledDate = workoutClassDay.scheduledDate.toDate();
          final int classIndex = courseEnrollment.classes.indexOf(workoutClassDay);
          return WorkoutSchedule(
            courseEnrollment: courseEnrollment,
            className: "${courseEnrollment.course.name} ${OlukoLocalizations.get(context, 'class')} ${classIndex + 1}",
            classIndex: classIndex,
            scheduledDate: scheduledDate,
            enrolledDate: courseEnrollment.createdAt?.toDate() ?? DateTime.now(),
            day: OlukoLocalizations.get(context, DateFormat('EEEE').format(scheduledDate).toLowerCase())
          );
        }).toList());
      }
    }
    return workoutSchedules;
  }

  static List<WorkoutDay> getScheduledClassesGroupedByDay(List<WorkoutSchedule> workoutSchedules){
    final List<WorkoutDay> workoutClasses = [];
    if (workoutSchedules.isNotEmpty) {
      workoutSchedules.sort((a, b) => a.enrolledDate.compareTo(b.enrolledDate));
      for (final workoutSchedule in workoutSchedules) {
        final workoutDay = workoutClasses.isNotEmpty ? workoutClasses.firstWhere((x) => x.day == workoutSchedule.day, orElse: () => null) : null;
        if (workoutDay != null){
          workoutDay.scheduledWorkouts.add(workoutSchedule);
        }else{
          final workoutDay = WorkoutDay(day: workoutSchedule.day, scheduledDay: workoutSchedule.scheduledDate, scheduledWorkouts: []);
          workoutDay.scheduledWorkouts.add(workoutSchedule);
          workoutClasses.add(workoutDay);
        }
      }
      workoutClasses.sort((a, b) => a.scheduledDay.compareTo(b.scheduledDay));
    }
    return workoutClasses;
  }

  static void reScheduleClasses(List<EnrollmentClass> classes, List<String> weekDays, int classIndex){
    if (classes[classIndex].scheduledDate == null){
      return;
    }
    
    final bool existsNextCompletedClass = classes.any((classItem) => classes.indexOf(classItem) > classIndex && classItem.completedAt != null);
    final DateTime selectedClassScheduledDate = classes[classIndex].scheduledDate.toDate();
    final DateTime currentDate = DateTime.now();
    final bool isClassTakenOnScheduledDate = selectedClassScheduledDate.year == currentDate.year &&
                                              selectedClassScheduledDate.month == currentDate.month &&
                                              selectedClassScheduledDate.day == currentDate.day;
    final bool shouldReSchedule = weekDays != null && weekDays.isNotEmpty &&
                                  !existsNextCompletedClass &&
                                  !isClassTakenOnScheduledDate;
    if (!shouldReSchedule){
      classes[classIndex].scheduledDate = null;
      return;
    }
    scheduleUncompletedClasses(classes, classIndex, weekDays: weekDays);
  }

  static void unScheduleOldClasses(List<EnrollmentClass> classes, int classIndex){
    if (classes[classIndex].scheduledDate == null){
      return;
    }
    for (int i = 0; i <= classIndex; i++) {
      classes[i].scheduledDate = null;
    }
  }

  static void scheduleUncompletedClasses(List<EnrollmentClass> classes, int classIndex, { List<String> weekDays = const []}){
    final int remainingClassesAmount = classes.where((classItem) => classes.indexOf(classItem) > classIndex &&
                                                                    classItem.completedAt == null).length;
    if (remainingClassesAmount > 0){
      final List<DateTime> scheduledDates = WeekDaysHelper.getRecurringDates(Frequency.daily, remainingClassesAmount, weekDays: weekDays);
      int scheduledDatesIndex = 0;
      for (int i = 0; i < classes.length; i++) {
        if (weekDays.isNotEmpty){
          if (i <= classIndex){
            classes[i].scheduledDate = null;
          }else{
            classes[i].scheduledDate = Timestamp.fromDate(scheduledDates[scheduledDatesIndex]);
            scheduledDatesIndex++;
          }
        }else{
          classes[i].scheduledDate = null;
        }
      }
    }
  }
}
