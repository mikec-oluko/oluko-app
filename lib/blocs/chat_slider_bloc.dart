import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/repositories/course_enrollment_repository.dart';

abstract class ChatSliderState {}

class ChatSliderLoading extends ChatSliderState {}

class Failure extends ChatSliderState {
  final dynamic exception;
  Failure({this.exception});
}

class ChatSliderByUserSuccess extends ChatSliderState {
  final List<Course> courses;
  ChatSliderByUserSuccess(this.courses);
}

class GetChatSliderUpdate extends ChatSliderState {
  final List<Course> courses;
  GetChatSliderUpdate({this.courses});
}

class ChatSliderBloc extends Cubit<ChatSliderState> {
  ChatSliderBloc() : super(ChatSliderLoading());

  Future getCoursesWithChatByUserId(String userId) async {
    final List<CourseEnrollment> courseEnrollments = await CourseEnrollmentRepository.getUserCourseEnrollments(userId);
    final List<CourseEnrollment> courseList = courseEnrollments.where((element) => element.isUnenrolled != true).toList();
    final List<Course> coursesWithChat = [];

    for (final element in courseList) {
      final courseData = (await element.course.reference.get()).data() as Map<String, dynamic>;
      Course courseElement = Course.fromJson(courseData);
      if (courseElement?.hasChat != false) {
        coursesWithChat.add(courseElement);
      }
    }

    emit(ChatSliderByUserSuccess(coursesWithChat));
  }
}
