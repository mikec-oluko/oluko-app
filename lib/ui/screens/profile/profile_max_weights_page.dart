import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/profile/max_weights_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/custom_keyboard.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class ProfileMaxWeightsPage extends StatefulWidget {
  const ProfileMaxWeightsPage() : super();

  @override
  _ProfileMaxWeightsPageState createState() => _ProfileMaxWeightsPageState();
}

class _ProfileMaxWeightsPageState extends State<ProfileMaxWeightsPage> {
  FocusNode focusNode = FocusNode();
  TextEditingController textController = TextEditingController();
  @override
  initState() {
    super.initState();
    BlocProvider.of<MaxWeightsBloc>(context).getRecommendedWeightMovements();
  }

  void _openKeyboard() {
    BottomDialogUtils.showBottomDialog(
      barrierColor: false,
      context: context,
      content: Container(
        height: ScreenUtils.height(context) * 0.4,
        child: CustomKeyboard(
          boxDecoration: OlukoNeumorphism.boxDecorationForKeyboard(),
          controller: textController,
          focus: focusNode,
          onSubmit: () {
            Navigator.pop(context);
            focusNode.unfocus();
          },
        ),
      ),
    );
  }
  
  Widget _setWeight() {
    return GestureDetector(
      onTap: () {
        _openKeyboard();
      },
      child: Row(
        children: <Widget>[
          Text(
            '300 Lbs',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios_rounded, color: OlukoColors.white, size: 17), 
            onPressed: null,
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
      appBar: OlukoAppBar(
        showBackButton: true,
        title: 'Max Weights',
        showTitle: true,
        onPressed: () =>  Navigator.pop(context)),
      body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Set Max Weights',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            BlocBuilder<MaxWeightsBloc, MaxWeightsState>(
              builder: (context, state) {
                if(state is MaxWeightsLoading){
                  return Center(child: CircularProgressIndicator());
                }
                if(state is MaxWeightsMovements && state.movements.isEmpty){
                  return const Center(child: Text('There are no max weights to set'));
                }
                if(state is MaxWeightsMovements && state.movements.isNotEmpty){
                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.movements.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 8.0, bottom: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(state.movements[index].name, style: const TextStyle(fontSize: 16, color: Colors.white)),
                              _setWeight(),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
    );
  }
}