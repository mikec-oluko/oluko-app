import 'package:flutter_bloc/flutter_bloc.dart';

class AmrapRound{
  int amrapValue;
  AmrapRound({
    this.amrapValue,
  });
}

class AmrapRoundUpdate extends AmrapRound{
  int amrapValue;
  AmrapRoundUpdate({
    this.amrapValue,
  });
}

class AmrapRoundBloc extends Cubit<AmrapRound> {
  AmrapRoundBloc() : super(AmrapRound(amrapValue: 0));

  void set(int value) => emit(AmrapRound(amrapValue: value));

  void get() => emit(AmrapRound(amrapValue: state.amrapValue));

  void update() => emit(AmrapRoundUpdate(amrapValue: state.amrapValue));
}
