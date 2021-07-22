import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/title_body.dart';

class CarouselSection extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final Function() onOptionTap;
  final String optionLabel;
  final double height;
  final double width;

  CarouselSection(
      {this.title,
      this.children,
      this.onOptionTap,
      this.optionLabel,
      this.height,
      this.width});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<CarouselSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      child: Column(children: [
        Flexible(
          flex: 1,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TitleBody(widget.title),
              GestureDetector(
                onTap: () => widget.onOptionTap(),
                child: Padding(
                  padding: const EdgeInsets.only(top: 3.0),
                  child: Text(
                    '',
                    // Removed for MVP --------  widget.optionLabel != null ? widget.optionLabel : '',
                    style: TextStyle(color: OlukoColors.primary, fontSize: 18),
                  ),
                ),
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
    );
  }
}
