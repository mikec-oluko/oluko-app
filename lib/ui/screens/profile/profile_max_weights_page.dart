import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/profile/max_weights_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/custom_keyboard.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/movement_utils.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class ProfileMaxWeightsPage extends StatefulWidget {
  final UserResponse user;

  const ProfileMaxWeightsPage({
    this.user,
    Key key,
  }) : super(key: key);

  @override
  _ProfileMaxWeightsPageState createState() => _ProfileMaxWeightsPageState();
}

class _ProfileMaxWeightsPageState extends State<ProfileMaxWeightsPage> {
  FocusNode focusNode = FocusNode();
  TextEditingController textController = TextEditingController();
  final ValueNotifier<String> _selectedMovementNotifier = ValueNotifier(null);
  String unity;
  
  @override
  initState() {
    super.initState();
    BlocProvider.of<MaxWeightsBloc>(context).getMaxWeightMovements(widget.user.id);
    unity = widget.user?.useImperialSystem == true ? 'LBs' : 'Kg';
  }

  void _openKeyboard(Movement movement, Map<String, int> weightMap, List<Movement> movements) {
    BottomDialogUtils.showBottomDialog(
      barrierColor: false,
      context: context,
      onDismissAction: () => {_selectedMovementNotifier.value = null},
      content: Container(
        height: ScreenUtils.height(context) * 0.47,
        child: CustomKeyboard(
          boxDecoration: OlukoNeumorphism.boxDecorationForKeyboard(),
          controller: textController,
          focus: focusNode,
          showInput: true,
          textStartInput: 'Enter weight:',
          textEndInput: unity,
          onSubmit: () {
            Navigator.pop(context);
            focusNode.unfocus();
            int weightLBs = !widget.user.useImperialSystem ? MovementUtils.kilogramToLbs(int.parse(textController.text)) : int.parse(textController.text);
            weightMap[movement.id] = weightLBs;
            BlocProvider.of<MaxWeightsBloc>(context).setMaxWeightByUserIdAndMovementId(widget.user.id, movement.id, weightLBs);
            BlocProvider.of<MaxWeightsBloc>(context).emitMaxWeightsMovements(movements, weightMap);
            textController.text = '';
            _selectedMovementNotifier.value = null;
          },
        ),
      ),
    );
  }

  Widget _setWeight(Movement movement, Map<String, int> weightMap, List<Movement> movements, Color color) {
    final int weight = weightMap[movement.id] ?? 0;
    final int weightLBs = widget.user.useImperialSystem ? weight : MovementUtils.lbsToKilogram(weight);
    final String screenWeight = weightLBs == 0 ? 'Set' : '$weightLBs $unity';
    return GestureDetector(
      onTap: () {
        _openKeyboard(movement, weightMap, movements);
        _selectedMovementNotifier.value = movement.id;
      },
      child: Row(
        children: <Widget>[
          Text(
            screenWeight,
            style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w400),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios_rounded, color: color, size: 17),
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
      appBar: OlukoAppBar(showBackButton: true, title: 'Max Weights', showTitle: true, onPressed: () => Navigator.pop(context)),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Set Max Weights',
                style: TextStyle(fontSize: 18, color: OlukoColors.white),
              ),
            ),
          ),
          BlocBuilder<MaxWeightsBloc, MaxWeightsState>(
            builder: (context, state) {
              if (state is MaxWeightsLoading) {
                return Center(child: CircularProgressIndicator());
              }
              if (state is MaxWeightsMovements && state.movements.isEmpty) {
                return const Center(child: Text('There are no max weights to set'));
              }
              if (state is MaxWeightsMovements && state.movements.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.movements.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                        child: ValueListenableBuilder(
                          valueListenable: _selectedMovementNotifier,
                          builder: (context, selectedMovementId, _) {
                            Color textColor;
                            if (selectedMovementId == null) {
                              textColor = OlukoColors.white;
                            } else {
                              textColor = selectedMovementId == state.movements[index].id ? OlukoColors.white : OlukoColors.grayColor;
                            }
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(state.movements[index].name, style: TextStyle(fontSize: 18, color: textColor, fontWeight: FontWeight.w300)),
                                _setWeight(state.movements[index], state.maxWeightsMap, state.movements, textColor),
                              ],
                            );
                          },
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
