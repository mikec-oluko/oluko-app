part of 'keyboard_bloc.dart';

class KeyboardState {
  String inputValue;
  TextEditingController textEditingController;
  String valueSubmited;
  bool setVisible;
  FocusNode focus ;
  KeyboardState(
      {this.inputValue = '',
      this.valueSubmited = '',
      this.setVisible = false,
      this.textEditingController ,
      this.focus});
}

