import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

part 'keyboard_event.dart';
part 'keyboard_state.dart';

class KeyboardBloc extends Bloc<KeyboardEvent, KeyboardState> {
  KeyboardBloc() : super(KeyboardState(textEditingController: TextEditingController(), focus: FocusNode())) {
    on<AddNumber>((event, emit) => _insertText(event.number));
    on<DeleteNumber>((event, emit) => {_backspace()});
    on<Submit>((event, emit) => emit(_submit()));
    on<SetVisible>((event, emit) => emit(_setVisible()));
  }
  KeyboardState _setVisible() {
    state.focus.requestFocus();
    return KeyboardState(
        inputValue: state.textEditingController.text,
        valueSubmited: state.valueSubmited,
        setVisible: true,
        textEditingController: state.textEditingController,
        focus: state.focus);
  }

  KeyboardState _submit() {
    FocusNode newFocus = state.focus;
    newFocus.unfocus();
    return KeyboardState(
        valueSubmited: state.inputValue,
        inputValue: state.inputValue,
        setVisible: false,
        focus: newFocus,
        textEditingController: state.textEditingController);
  }

  void _insertText(String myText) {
    TextEditingController _controller = state.textEditingController;
    String text = state.textEditingController.text;
    final textSelection = state.textEditingController.selection;
    String newText;
    if (textSelection.start >= 0 && textSelection.end >= 0) {
      newText = text.replaceRange(
        textSelection.start,
        textSelection.end,
        myText,
      );
      final myTextLength = myText.length;
      _controller.text = newText;
      _controller.selection = textSelection.copyWith(
        baseOffset: textSelection.start + myTextLength,
        extentOffset: textSelection.start + myTextLength,
      );
    } else {
      newText = text.replaceRange(
        0,
        0,
        myText,
      );
      final myTextLength = myText.length;
      _controller.text = newText;
      _controller.selection = textSelection.copyWith(
        baseOffset: textSelection.start + 1 + myTextLength,
        extentOffset: textSelection.start + 1 + myTextLength,
      );
    }
    state.focus.requestFocus();
    state.textEditingController = _controller;
    state.inputValue = newText;
  }

  void _backspace() {
    TextEditingController _controller = state.textEditingController;
    final text = _controller.text;
    final textSelection = _controller.selection;
    final selectionLength = textSelection.end - textSelection.start;
    // There is a selection.
    if (selectionLength > 0) {
      final newText = text.replaceRange(
        textSelection.start,
        textSelection.end,
        '',
      );
      _controller.text = newText;
      _controller.selection = textSelection.copyWith(
        baseOffset: textSelection.start,
        extentOffset: textSelection.start,
      );
      return;
    }
    // The cursor is at the beginning.
    if (textSelection.start <= 0) {
      return;
    }
    // Delete the previous character

    final newStart = textSelection.start - 1;
    final newEnd = textSelection.start;
    final newText = text.replaceRange(
      newStart,
      newEnd,
      '',
    );
    _controller.text = newText;
    _controller.selection = textSelection.copyWith(
      baseOffset: newStart,
      extentOffset: newStart,
    );
    state.textEditingController = _controller;
    state.inputValue = _controller.text;
  }

  KeyboardState _hide() {
    return KeyboardState(
        valueSubmited: state.inputValue,
        inputValue: state.inputValue,
        setVisible: false,
        focus: state.focus,
        textEditingController: state.textEditingController);
  }
}
