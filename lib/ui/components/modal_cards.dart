import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/points_card_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/points_card_component.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

import '../../models/points_card.dart';

class ModalCards extends StatefulWidget {
  String userId;
  ModalCards({this.userId});

  @override
  _ModalCardsState createState() => _ModalCardsState();
}

class _ModalCardsState extends State<ModalCards> {
  @override
  Widget build(BuildContext context) {
    //BlocProvider.of<PointsCardBloc>(context).get(widget.userId);
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
              child: Column(
                children: [
                  Image.asset('assets/courses/horizontal_vector.png', scale: 4, color: OlukoColors.grayColor),
                  Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 25),
                      child: Row(
                        children: [
                          Text(OlukoLocalizations.get(context, 'cards'),
                              style: const TextStyle(color: OlukoColors.white, fontSize: OlukoFonts.olukoBigFontSize, fontWeight: FontWeight.w600)),
                          const Expanded(child: SizedBox()),
                          _pointsWidget()
                        ],
                      )),
                  Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Image.asset(
                        'assets/home/gray_horizontal_line.png',
                        color: Colors.white,
                        scale: 5,
                      )),
                  BlocBuilder<PointsCardBloc, PointsCardState>(builder: (context, pointsCardState) {
                    if (pointsCardState is PointsCardSuccess) {
                      return Container(height: 450, width: MediaQuery.of(context).size.width - 50, child: _cardsGrid(pointsCardState.pointsCards));
                    } else {
                      return const SizedBox();
                    }
                  })
                ],
              )),
        ));
  }

  Widget _pointsWidget() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(6.0)),
        color: OlukoColors.blackColorSemiTransparent,
      ),
      child: Padding(
          padding: const EdgeInsets.all(4),
          child: Text('256', style: OlukoFonts.olukoSuperBigFont(customColor: OlukoColors.lightOrange, customFontWeight: FontWeight.w700))),
    );
  }

  Widget _cardsGrid(List<PointsCard> cardsList) {
    return GridView.count(mainAxisSpacing: 20, crossAxisCount: 2, crossAxisSpacing: 12, children: _buildCardList(cardsList));
  }

  List<Widget> _cardsList(List<PointsCard> cards) {
    List<Widget> widgetsList = [];
    cards.forEach((element) {
      widgetsList.add(PointsCardComponent(
        pointsCard: element,
      ));
    });
    return widgetsList;
  }

  List<Widget> _buildCardList(List<PointsCard> cards) {
    List<Widget> widgetsList = cards
        .map((card) => PointsCardComponent(
              pointsCard: card,
            ))
        .toList();

    return widgetsList;
  }

  /*Widget cardsGrid(List<PointsCard> cards) {
    if (cards.isNotEmpty) {
      return GridView.count(
        padding: const EdgeInsets.only(top: 10),
        childAspectRatio: 0.7,
        crossAxisCount: 4,
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        children: cards
            .map(
              (cardElement) => {PointsCardComponent(pointsCard: cardElement)},
            )
            .toList(),
      );
    } else {
      return SizedBox();
    }
  }*/
}
