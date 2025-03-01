import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';

class CardHorizontal extends StatelessWidget {
  CardHorizontal({this.title = "Placeholder Title", this.cta = "", this.img = "https://via.placeholder.com/200", this.tap = defaultFunc});

  final String cta;
  final String img;
  final void Function() tap;
  final String title;

  static void defaultFunc() {
    print("the function works!");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 130,
        child: GestureDetector(
          onTap: tap,
          child: Card(
            elevation: 0.6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6.0))),
            child: Row(
              children: [
                Flexible(
                  flex: 1,
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(6.0), bottomLeft: Radius.circular(6.0)),
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(img),
                            fit: BoxFit.cover,
                          ))),
                ),
                Flexible(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: TextStyle(color: OlukoColors.header, fontSize: 13)),
                          Text(cta, style: TextStyle(color: OlukoColors.primary, fontSize: 11, fontWeight: FontWeight.w600))
                        ],
                      ),
                    ))
              ],
            ),
          ),
        ));
  }
}
