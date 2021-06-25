import 'package:flutter/material.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/ui/components/title_body.dart';

class CarouselSmallSection extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final Function() onOptionTap;
  final String optionLabel;

  CarouselSmallSection(
      {this.title, this.children, this.onOptionTap, this.optionLabel});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<CarouselSmallSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TitleBody(widget.title),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Text(
                "View All",
                style: TextStyle(color: OlukoColors.primary),
              ),
            ),
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
              height: 120,
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
