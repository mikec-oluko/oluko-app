import 'package:cloud_firestore/cloud_firestore.dart';
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

  MarkerBloc() : super(Loading());

  void createMarker(double position, DocumentReference reference) async {
    if (!(state is MarkerSuccess)) {
      emit(Loading());
    }
    try {
      Marker marker = Marker(position: position);
      Marker newMarker = await MarkerRepository.createMarker(marker, reference);
      emit(MarkerSuccess(marker: newMarker));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }

  void getMarkers(DocumentReference reference) async {
    if (!(state is MarkersSuccess)) {
      emit(Loading());
    }
    try {
      final markers = await MarkerRepository.getMarkers(reference);
      emit(MarkersSuccess(markers: markers));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }
}
