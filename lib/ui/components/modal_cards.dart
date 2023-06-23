import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/points_card_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/collected_card.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/points_card_component.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/models/points_card.dart';

class ModalCards extends StatefulWidget {
  String userId;
  ModalCards({this.userId});

  @override
  _ModalCardsState createState() => _ModalCardsState();
}

class _ModalCardsState extends State<ModalCards> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 100,
        padding: EdgeInsets.zero,
        child: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/courses/gray_background.png'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          child: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: BlocBuilder<PointsCardBloc, PointsCardState>(builder: (context, pointsCardState) {
                if (pointsCardState is PointsCardSuccess) {
                  return Column(
                    children: [
                      Image.asset('assets/courses/horizontal_vector.png', scale: 4, color: OlukoColors.grayColor),
                      Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20, top: 25),
                          child: Row(
                            children: [
                              Text(OlukoLocalizations.get(context, 'cards'),
                                  style: const TextStyle(color: OlukoColors.white, fontSize: OlukoFonts.olukoBigFontSize, fontWeight: FontWeight.w600)),
                              const Expanded(child: SizedBox()),
                              _pointsWidget(pointsCardState.userPoints)
                            ],
                          )),
                      Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Image.asset(
                            'assets/home/gray_horizontal_line.png',
                            color: Colors.white,
                            scale: 5,
                          )),
                      SizedBox(
                          height: MediaQuery.of(context).size.height / 2.05,
                          width: MediaQuery.of(context).size.width - 50,
                          child: _cardsGrid(pointsCardState.pointsCards))
                    ],
                  );
                } else {
                  return OlukoCircularProgressIndicator();
                }
              })),
        ));
  }

  Widget _pointsWidget(int points) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(6.0)),
        color: OlukoColors.blackColorSemiTransparent,
      ),
      child: Padding(
          padding: const EdgeInsets.all(4),
          child: Text(points.toString(), style: OlukoFonts.olukoSuperBigFont(customColor: OlukoColors.lightOrange, customFontWeight: FontWeight.w700))),
    );
  }

  Widget _cardsGrid(List<CollectedCard> cardsList) {
    return GridView.count(
        physics: OlukoNeumorphism.listViewPhysicsEffect,
        padding: const EdgeInsets.only(top: 20),
        mainAxisSpacing: 20,
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        childAspectRatio: 163 / 200,
        children: _buildCardList(cardsList));
  }

  List<Widget> _buildCardList(List<CollectedCard> cards) {
    List<Widget> widgetsList = cards
        .map((card) => PointsCardComponent(
              collectedCard: card,
            ))
        .toList();

    return widgetsList;
  }
}
