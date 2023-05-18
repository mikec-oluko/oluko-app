import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:oluko_app/models/utils/weekdays_helper.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/workout_day.dart';
import 'package:oluko_app/models/workout_schedule.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

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
    final List<DateTime> thisWeekDates = WeekDaysHelper.getCurrentWeekDates();
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
            enrolledDate: courseEnrollment.createdAt.toDate(),
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
}
