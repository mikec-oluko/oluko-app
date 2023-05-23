import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/profile/max_weights_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';

class ProfileMaxWeightsPage extends StatefulWidget {
  const ProfileMaxWeightsPage() : super();

  @override
  _ProfileMaxWeightsPageState createState() => _ProfileMaxWeightsPageState();
}

class _ProfileMaxWeightsPageState extends State<ProfileMaxWeightsPage> {

  @override
  initState() {
    super.initState();
    BlocProvider.of<MaxWeightsBloc>(context).getRecommendedWeightMovements();
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
          Padding(
            padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 20.0, bottom: 0.0),
            child: const Align(
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
                  padding: const EdgeInsets.only(left: 0.0, right: 0.0, top: 16.0, bottom: 0.0),
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
                            //Text(state.movements[index].recommendedWeight.toString(), style: TextStyle(fontSize: 18)),
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