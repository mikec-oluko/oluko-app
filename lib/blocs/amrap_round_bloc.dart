import 'package:flutter_bloc/flutter_bloc.dart';

class AmrapRound {
  int amrapValue;
  AmrapRound({
    this.amrapValue,
  });
}

const int _defaultStateValue = 0;

class AmrapRoundBloc extends Cubit<AmrapRound> {
  AmrapRoundBloc() : super(AmrapRound(amrapValue: _defaultStateValue));

  void set(int value) => emit(AmrapRound(amrapValue: value));
  void get() => emit(AmrapRound(amrapValue: state.amrapValue));
  void emitDefault() => emit(AmrapRound(amrapValue: _defaultStateValue));
}
