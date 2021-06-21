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

      if (taskIds.indexOf(task.key) != -1) {
        tasksToShow.add(task);
      }
    });
    return tasksToShow;
  }

  static List<Task> sortByAssessmentIndex(
      List<Task> tasks, Assessment assessment) {
    tasks.sort((Task taskA, Task taskB) {
      AssessmentTask assessmentTaskA = assessment.tasks
          .firstWhere((AssessmentTask element) => element.taskId == taskA.key);
      AssessmentTask assessmentTaskB = assessment.tasks
          .firstWhere((AssessmentTask element) => element.taskId == taskB.key);
      return assessmentTaskA.index.compareTo(assessmentTaskB.index);
    });
    return tasks;
  }
}
