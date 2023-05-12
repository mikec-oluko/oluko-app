import 'package:oluko_app/models/workout_schedule.dart';

class WorkoutDay {
  String day;
  List<WorkoutSchedule> scheduledWorkouts;
  WorkoutDay({this.day, this.scheduledWorkouts});
}
