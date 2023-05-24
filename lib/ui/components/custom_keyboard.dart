import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class CustomKeyboard extends StatefulWidget {
  TextEditingController controller;
  final BoxDecoration boxDecoration;
  FocusNode focus;
  Function onSubmit;
  Function onChanged;
  bool showInput;
  String textStartInput;
  String textEndInput;
  CustomKeyboard(
      {Key key,
      this.boxDecoration,
      this.controller,
      this.focus,
      this.onSubmit,
      this.onChanged,
      this.showInput = false,
      this.textStartInput = '',
      this.textEndInput = ''})
      : super(key: key);

  @override
  State<CustomKeyboard> createState() => _CustomKeyboardState();
}

class _CustomKeyboardState extends State<CustomKeyboard> {
  @override
  Widget build(BuildContext context) {
    widget.focus.requestFocus();
    return Column(
      children: [
        if (widget.showInput) _input(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: widget.boxDecoration,
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              NumberPanel(
                text: '1',
                onPressed: () => _insertText('1'),
              ),
              NumberPanel(
                text: '2',
                onPressed: () => _insertText('2'),
              ),
              NumberPanel(
                text: '3',
                onPressed: () => _insertText('3'),
              ),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              NumberPanel(
                text: '4',
                onPressed: () => _insertText('4'),
              ),
              NumberPanel(
                text: '5',
                onPressed: () => _insertText('5'),
              ),
              NumberPanel(
                text: '6',
                onPressed: () => _insertText('6'),
              ),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              NumberPanel(
                text: '7',
                onPressed: () => _insertText('7'),
              ),
              NumberPanel(
                text: '8',
                onPressed: () => _insertText('8'),
              ),
              NumberPanel(
                text: '9',
                onPressed: () => _insertText('9'),
              ),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Expanded(child: DeleteButton(onBackspace: () => _backspace())),
              NumberPanel(
                text: '0',
                onPressed: () => _insertText('0'),
              ),
              Expanded(
                child: DoneButton(onPressed: () => widget.onSubmit()),
              )
            ]),
            const SizedBox(
              height: 15,
            )
          ]),
        ),
      ],
    );
  }

  Widget _input() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          color: Colors.black,
          padding: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18.0),
            child: Row(
              children: <Widget>[
                Text(
                  widget.textStartInput,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth / 2,
                  ),
                  child: IntrinsicWidth(
                    child: TextField(
                      controller: widget.controller,
                       focusNode: widget.focus,
                      readOnly: true,
                      showCursor: true,
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w500),
                      decoration: const InputDecoration(
                        fillColor: Colors.transparent,
                        filled: true,
                        border: InputBorder.none,
                      ),
                      textAlignVertical: TextAlignVertical.center,
                    ),
                  ),
                ),
                Text(
                  widget.textEndInput,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _insertText(String myText) {
    TextEditingController _controller = widget.controller;
    String text = widget.controller.text;
    final textSelection = widget.controller.selection;
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
    widget.focus.requestFocus();
    widget.controller = _controller;
    if (widget.onChanged != null) {
      widget.onChanged();
    }
    // state.textScrollController?.animateTo(1000, duration: Duration(milliseconds: 1), curve: Curves.bounceIn);
  }

  void _backspace() {
    TextEditingController _controller = widget.controller;
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
    widget.controller = _controller;
  }
}

class DeleteButton extends StatelessWidget {
  const DeleteButton({
    Key key,
    this.onBackspace,
  }) : super(key: key);
  final VoidCallback onBackspace;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onBackspace,
      icon: const Icon(Icons.backspace_rounded),
      color: const Color(0xffacb292),
      iconSize: 40,
    );
  }
}

class DoneButton extends StatelessWidget {
  const DoneButton({
    Key key,
    this.onPressed,
  }) : super(key: key);
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xffacb292), borderRadius: BorderRadius.circular(5)),
      child: TextButton(
        child: const Text(
          'Done',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300, color: Color(0xff16171b)),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class Label extends StatelessWidget {
  final String label;
  const Label({Key key, this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ));
  }
}

class NumberPanel extends StatelessWidget {
  final String text;
  final Function onPressed;
  const NumberPanel({
    Key key,
    this.text,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(5),
        child: TextButton(
          child: Text(
            text,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w300, color: Colors.white),
          ),
          onPressed: () => onPressed(),
        ),
      ),
    );
  }
}
