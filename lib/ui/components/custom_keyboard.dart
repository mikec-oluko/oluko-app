import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/keyboard/keyboard_bloc.dart';

class CustomKeyboard extends StatelessWidget {
  const CustomKeyboard({Key key, this.boxDecoration}) : super(key: key);
  final BoxDecoration boxDecoration;

  @override
  Widget build(BuildContext context) {
    final _customKeyboardBloc = BlocProvider.of<KeyboardBloc>(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: boxDecoration,
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          NumberPanel(
            text: '1',
            onPressed: () => _customKeyboardBloc.add(AddNumber('1')),
          ),
          NumberPanel(
            text: '2',
            onPressed: () => _customKeyboardBloc.add(AddNumber('2')),
          ),
          NumberPanel(
            text: '3',
            onPressed: () => _customKeyboardBloc.add(AddNumber('3')),
          ),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          NumberPanel(
            text: '4',
            onPressed: () => _customKeyboardBloc.add(AddNumber('4')),
          ),
          NumberPanel(
            text: '5',
            onPressed: () => _customKeyboardBloc.add(AddNumber('5')),
          ),
          NumberPanel(
            text: '6',
            onPressed: () => _customKeyboardBloc.add(AddNumber('6')),
          ),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          NumberPanel(
            text: '7',
            onPressed: () => _customKeyboardBloc.add(AddNumber('7')),
          ),
          NumberPanel(
            text: '8',
            onPressed: () => _customKeyboardBloc.add(AddNumber('8')),
          ),
          NumberPanel(
            text: '9',
            onPressed: () => _customKeyboardBloc.add(AddNumber('9')),
          ),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Expanded(child: DeleteButton(onBackspace: () => {_customKeyboardBloc.add(DeleteNumber())})),
          NumberPanel(
            text: '0',
            onPressed: () => _customKeyboardBloc.add(AddNumber('0')),
          ),
          Expanded(
            child: DoneButton(onPressed: () => _customKeyboardBloc.add(Submit())),
          )
        ]),
        SizedBox(
          height: 80,
        )
      ]),
    );
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
