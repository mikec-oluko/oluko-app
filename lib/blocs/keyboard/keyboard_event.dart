part of 'keyboard_bloc.dart';

@immutable
abstract class KeyboardEvent {}

class AddNumber extends KeyboardEvent {
  final String number;
  AddNumber(this.number);
}

class DeleteNumber extends KeyboardEvent {}

class Submit extends KeyboardEvent {}

class SetVisible extends KeyboardEvent {
}
class HideKeyboard extends KeyboardEvent {
}
