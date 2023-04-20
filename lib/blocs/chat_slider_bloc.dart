import 'package:cloud_firestore/cloud_firestore.dart';
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
  final List<CourseEnrollment> courses;
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
    final List<CourseEnrollment> coursesWithChat = [];

    final List<Future<DocumentSnapshot<Object>>> promises = courseList.map((element) => element.course.reference.get()).toList();
    final List<DocumentSnapshot<Object>> courses = await Future.wait(promises);
    Course courseElement;
    courses.map((course)=> {
      courseElement = Course.fromJson(course.data() as Map<String, dynamic>),
      if (courseElement?.hasChat != false) {
        coursesWithChat.add(courseEnrollments.firstWhere((element) => courseElement.id == element.course.id))
      }
    }).toList();
    
    emit(ChatSliderByUserSuccess(coursesWithChat));
  }
}
