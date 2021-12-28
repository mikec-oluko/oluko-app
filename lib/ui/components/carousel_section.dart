import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class CarouselSection extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  final Function() onOptionTap;
  final String optionLabel;
  final double height;
  final double width;

  CarouselSection({this.title, this.subtitle, this.children, this.onOptionTap, this.optionLabel, this.height, this.width});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<CarouselSection> {
  @override
  Widget build(BuildContext context) {
    return widget.children.isNotEmpty
        ? Container(
            height: widget.height,
            child: Column(children: [
              Flexible(
                flex: 1,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widget.title != null
                        ? Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TitleBody(widget.title),
                                // TextButton(
                                //   onPressed: () {
                                //     // goToRoute(widget.routeToGo);
                                //   },
                                //   child: Text(
                                //     OlukoLocalizations.get(context, 'viewAll'),
                                //     style: TextStyle(color: OlukoColors.primary),
                                //   ),
                                // ),
                              ],
                            ),
                          )
                        : SizedBox(),
                    widget.subtitle != null ? TitleBody(widget.title) : SizedBox(),
                    GestureDetector(
                      onTap: () => widget.onOptionTap(),
                      child: widget.optionLabel != null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 3.0),
                              child: Text(
                                widget.optionLabel != null ? widget.optionLabel : '',
                                style: TextStyle(color: OlukoColors.primary, fontSize: 18),
                              ),
                            )
                          : SizedBox(),
                    )
                  ],
                ),
              ),
              Flexible(
                flex: 9,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                      child: Align(
                    alignment: Alignment.centerLeft,
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: widget.children,
                    ),
                  )),
                ),
              )
            ]),
          )
        : SizedBox.shrink();
  }
}
