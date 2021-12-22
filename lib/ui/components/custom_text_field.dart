import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/keyboard/keyboard_bloc.dart';
class CustomTextField extends StatefulWidget {
  const CustomTextField({Key key,this.label}) : super(key: key);
  final String label;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    final _customKeyboardBloc = BlocProvider.of<KeyboardBloc>(context);
    ScrollController _scrollController = ScrollController();
    return Container(
        decoration: BoxDecoration(
          color: const Color(0xff2b2f35),
          border: Border.all(color: const Color(0xff3d3d3d)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          child: Row(
            children: [
              const Text(
                'Enter score : ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              BlocBuilder<KeyboardBloc, KeyboardState>(
                builder: (context, state) {
                  state.textEditingController.text = state.inputValue;
                  return Expanded(
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 100,
                            child: Scrollbar(
                              child: (() {
                                TextSelection textSelection = state.textEditingController.selection;
                                textSelection = state.textEditingController.selection.copyWith(
                                  baseOffset: state.textEditingController.text.length,
                                  extentOffset: state.textEditingController.text.length,
                                );
                                TextEditingController controler = state.textEditingController;
                                controler.selection = textSelection;
                                return TextField(
                                  scrollController: _scrollController,
                                  controller: controler,
                                  onTap: () => !state.setVisible ? _customKeyboardBloc.add(SetVisible()) : null,
                                  style: const TextStyle(color: Colors.white, fontSize: 30),
                                  focusNode: state.focus,
                                  readOnly: true,
                                  showCursor: true,
                                  decoration: const InputDecoration(border: InputBorder.none),
                                  maxLines: 1,
                                );
                              }()),
                            ),
                          ),
                        ),
                        Label(
                          label: widget.label,
                        )
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ));
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
      onPressed: (){},
      icon:const Icon(Icons.backspace_rounded),
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
  const Label({Key key,this.label}) : super(key: key);

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
            style:const TextStyle(fontSize: 30, fontWeight: FontWeight.w300, color: Colors.white),
          ),
          onPressed: () => onPressed(),
        ),
      ),
    );
  }
}
