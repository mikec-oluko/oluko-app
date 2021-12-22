import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/keyboard/keyboard_bloc.dart';

import 'custom_text_field.dart';

class CustomKeyboard extends StatelessWidget {
  const CustomKeyboard({
    Key key,
     this.boxDecoration,
    
  })  :super(key: key);

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
      ]),
    );
  }
}
