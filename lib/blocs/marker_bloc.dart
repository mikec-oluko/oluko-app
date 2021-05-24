import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/marker.dart';
import 'package:oluko_app/repositories/marker_repository.dart';

abstract class MarkerState {}

class Loading extends MarkerState {}

class MarkersSuccess extends MarkerState {
  final List<Marker> markers;

  MarkersSuccess({this.markers});
}

class MarkerSuccess extends MarkerState {
  final Marker marker;

  MarkerSuccess({this.marker});
}

class Failure extends MarkerState {
  final Exception exception;

  Failure({this.exception});
}

class MarkerBloc extends Cubit<MarkerState> {
  final _markerRepository = MarkerRepository();

  MarkerBloc() : super(Loading());

  void createMarker(double position, String videoId) async {
    if (!(state is MarkerSuccess)) {
      emit(Loading());
    }
    try {
      Marker marker = Marker(position: position, videoId: videoId);
      Marker newMarker = await _markerRepository.createMarker(videoId, marker);
      emit(MarkerSuccess(marker: newMarker));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }

  void getVideoMarkers(String videoId) async {
    if (!(state is MarkersSuccess)) {
      emit(Loading());
    }
    try {
      final markers = await _markerRepository.getVideoMarkers(videoId);
      emit(MarkersSuccess(markers: markers));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }
}
