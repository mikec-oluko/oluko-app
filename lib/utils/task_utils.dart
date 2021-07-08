import 'package:mvt_fitness/models/assessment.dart';
import 'package:mvt_fitness/models/assessment_task.dart';
import 'package:mvt_fitness/models/task.dart';

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
      AssessmentTask assessmentTaskA = assessment.tasks
          .firstWhere((AssessmentTask element) => element.taskId == taskA.id);
      AssessmentTask assessmentTaskB = assessment.tasks
          .firstWhere((AssessmentTask element) => element.taskId == taskB.id);
      return assessmentTaskA.index.compareTo(assessmentTaskB.index);
    });
    return tasks;
  }
}
