import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/favorite.dart';
import 'package:oluko_app/models/sound.dart';
import 'package:oluko_app/repositories/favorite_repository.dart';
import 'package:oluko_app/repositories/project_configuration_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class ProjectConfigurationState {}

class Loading extends ProjectConfigurationState {}

class ProjectConfigurationuccess extends ProjectConfigurationState {}

class Failure extends ProjectConfigurationState {
  final dynamic exception;

  Failure({this.exception});
}

class ProjectConfigurationBloc extends Cubit<ProjectConfigurationState> {
  ProjectConfigurationBloc() : super(Loading());

  static Object courseConfiguration;

  void dispose() {
    if (courseConfiguration != null) {
      courseConfiguration = null;
    }
  }

  Object getCourseConfiguration() async {
    try {
      return courseConfiguration ??= await ProjectConfigurationRepository.getCourseConfiguration();
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(Failure(exception: exception));
      rethrow;
    }
  }

  List<Sound> getSegmentClockSounds() {
    if (courseConfiguration == null) {
      getCourseConfiguration();
    }

    return ((ProjectConfigurationBloc.courseConfiguration as Map)['sounds_configuration']['segment_clock_sounds'] as List)
        .map((sound) => Sound.fromJson(sound as Map))
        .toList();
  }

  Map getSoundsConfiguration() {
    if (courseConfiguration == null) {
      getCourseConfiguration();
    }
    if (courseConfiguration != null && courseConfiguration is Map) {
      final soundConfiguration = (courseConfiguration as Map)['sounds_configuration'];
      if (soundConfiguration != null && soundConfiguration is Map) {
        return soundConfiguration;
      }
    }
    return null;
  }
}
