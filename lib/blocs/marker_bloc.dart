import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/marker.dart';
import 'package:oluko_app/repositories/marker_repository.dart';

abstract class MarkerState {
  final List<Marker> markerList;
  MarkerState({this.markerList});
}

class Loading extends MarkerState {}

class MarkersSuccess extends MarkerState {
  final List<Marker> markers;
  MarkersSuccess({this.markers}) : super(markerList: markers);
}

class Failure extends MarkerState {
  final Exception exception;
  Failure({this.exception});
}

class MarkerBloc extends Cubit<MarkerState> {
  MarkerBloc() : super(Loading());

  List<Marker> _markerList = [];

  void createMarker(double position, DocumentReference reference) async {
    if (!(state is MarkersSuccess)) {
      emit(Loading());
    }
    try {
      Marker marker = Marker(position: position);
      Marker newMarker = await MarkerRepository.createMarker(marker, reference);
      _markerList.insert(0, newMarker);
      emit(MarkersSuccess(markers: _markerList));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }

  void getMarkers(DocumentReference reference) async {
    if (!(state is MarkersSuccess)) {
      emit(Loading());
    }
    try {
      _markerList = await MarkerRepository.getMarkers(reference);
      emit(MarkersSuccess(markers: _markerList));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }
}
