import 'package:flutter/material.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/ui/components/title_body.dart';

import 'course_card.dart';

class CarouselSection extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final Function() onOptionTap;
  final String optionLabel;

  CarouselSection(
      {this.title, this.children, this.onOptionTap, this.optionLabel});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<CarouselSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TitleBody(widget.title),
            GestureDetector(
              onTap: () => widget.onOptionTap(),
              child: Text(
                widget.optionLabel != null ? widget.optionLabel : '',
                style: TextStyle(color: OlukoColors.primary, fontSize: 20),
              ),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Container(
              height: 200,
              child: Align(
                alignment: Alignment.centerLeft,
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: widget.children,
                ),
              )),
        )
      ]),
    );
  }
}
