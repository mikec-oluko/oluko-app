import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/assessment_task.dart';
import 'package:oluko_app/models/task.dart';

class TaskUtils {
  static List<Task> filterByAssessment(
      List<Task> tasks, Assessment assessment) {
    List<Task> tasksToShow = [];
    tasks.forEach((Task task) {
      List<String> taskIds = assessment.tasks
          .map((AssessmentTask assessmentTask) => assessmentTask.taskId)
          .toList();

      if (taskIds.indexOf(task.id) != -1) {
        tasksToShow.add(task);
      }
    });
    return tasksToShow;
  }

  static List<Task> sortByAssessmentIndex(
      List<Task> tasks, Assessment assessment) {
    tasks.sort((Task taskA, Task taskB) {
      int assessmentTaskA = assessment.tasks
          .indexWhere((AssessmentTask element) => element.taskId == taskA.id);
      int assessmentTaskB = assessment.tasks
          .indexWhere((AssessmentTask element) => element.taskId == taskB.id);
      return assessmentTaskA.compareTo(assessmentTaskB);
    });
    return tasks;
  }
}
