import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/title_body.dart';

class CarouselSmallSection extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final Function() onOptionTap;
  final String optionLabel;
  final String routeToGo;

  CarouselSmallSection(
      {this.title,
      this.children,
      this.onOptionTap,
      this.optionLabel,
      this.routeToGo});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<CarouselSmallSection> {
  final String _viewAll = "View All";
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: TitleBody(widget.title),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, widget.routeToGo),
                child: Text(
                  _viewAll,
                  style: TextStyle(color: OlukoColors.primary),
                ),
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
