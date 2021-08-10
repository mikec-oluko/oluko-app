
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/models/task_submission.dart';

class TaskSubmissionService {
    static TaskSubmission getTaskSubmissionOfTask(
      Task task, List<TaskSubmission> taskSubmissions) {
    for (TaskSubmission taskSubmission in taskSubmissions) {
      if (taskSubmission.task.id == task.id) {
        return taskSubmission;
      }
    }
    return null;
  }
}