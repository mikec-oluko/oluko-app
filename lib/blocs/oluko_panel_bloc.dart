import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/helpers/enum_collection.dart';

abstract class OlukoPanelState {}

class OlukoPanelLoading extends OlukoPanelState {
  final double maxHeight;
  OlukoPanelLoading({this.maxHeight});
}

class OlukoPanelOpen extends OlukoPanelState {
  final double maxHeight;
  OlukoPanelOpen({this.maxHeight});
}

class OlukoPanelClose extends OlukoPanelState {
  final double maxHeight;
  OlukoPanelClose({this.maxHeight});
}

class OlukoPanelHide extends OlukoPanelState {}

class OlukoPanelShow extends OlukoPanelState {
  final double maxHeight;
  OlukoPanelShow({this.maxHeight});
}

class OlukoPanelSucess extends OlukoPanelState {
  final double maxHeight;
  OlukoPanelSucess({this.maxHeight});
}

class OlukoPanelError extends OlukoPanelState {
  final double maxHeight;
  OlukoPanelError({this.maxHeight});
}

class OlukoPanelBloc extends Cubit<OlukoPanelState> {
  OlukoPanelBloc() : super(OlukoPanelClose());

  void setNewState({OlukoPanelAction action, double maxHeight}) {
    switch (action) {
      case OlukoPanelAction.close:
        emit(OlukoPanelClose(maxHeight: maxHeight));
        break;
      case OlukoPanelAction.open:
        emit(OlukoPanelOpen(maxHeight: maxHeight));
        break;
      case OlukoPanelAction.hide:
        emit(OlukoPanelHide());
        break;
      case OlukoPanelAction.show:
        emit(OlukoPanelShow(maxHeight: maxHeight));
        break;
      case OlukoPanelAction.loading:
        emit(OlukoPanelLoading(maxHeight: maxHeight));
        break;
      case OlukoPanelAction.error:
        emit(OlukoPanelError(maxHeight: maxHeight));
        break;
      case OlukoPanelAction.success:
        emit(OlukoPanelSucess(maxHeight: maxHeight));
        break;
    }
  }
}
