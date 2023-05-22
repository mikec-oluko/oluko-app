import 'package:oluko_app/models/workout_schedule.dart';

class WorkoutDay {
  String day;
  DateTime scheduledDay;
  List<WorkoutSchedule> scheduledWorkouts;
  WorkoutDay({this.day, this.scheduledDay, this.scheduledWorkouts});
}
