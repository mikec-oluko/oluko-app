import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/coach_media.dart';
import 'package:oluko_app/repositories/coach_media_repository.dart';

abstract class CoachMediaState {}

class Loading extends CoachMediaState {}

class CoachMediaContentSuccess extends CoachMediaState {
  CoachMediaContentSuccess({this.coachMediaContent});
  final List<CoachMedia> coachMediaContent;
}

class CoachMediaDispose extends CoachMediaState {
  CoachMediaDispose({this.coachMediaDisposeValue});
  final List<CoachMedia> coachMediaDisposeValue;
}

class CoachMediaContent extends CoachMediaState {
  CoachMediaContent({this.coachMediaContent});
  final List<CoachMedia> coachMediaContent;
}

class CoachMediaFailure extends CoachMediaState {
  CoachMediaFailure({this.exception});
  final dynamic exception;
}

class CoachMediaBloc extends Cubit<CoachMediaState> {
  final CoachMediaRepository _coachMediaRepository = CoachMediaRepository();
  CoachMediaBloc() : super(Loading());

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> subscription;

  @override
  void dispose() {
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
    }
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> getStream(String coachId) {
    return subscription ??= _coachMediaRepository.getCoachUploadedMediaStream(coachId).listen((snapshot) {
      final Set<CoachMedia> coachMediaContent = {};

      if (snapshot.docs.isNotEmpty) {
        for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
          final Map<String, dynamic> content = doc.data() as Map<String, dynamic>;
          coachMediaContent.add(CoachMedia.fromJson(content));
        }
        emit(CoachMediaContentSuccess(coachMediaContent: coachMediaContent.toList()));
      }
    });
  }
}
