import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/ui/components/oluko_image_bar.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class ClassSectionExpansionPanel extends StatefulWidget {
  final Class classObj;
  final int index;
  final int total;
  final double classProgresss;
  final Function() onPressed;

  const ClassSectionExpansionPanel({this.classObj, this.index, this.total, this.classProgresss, this.onPressed});

  @override
  _State createState() => _State();
}

class _State extends State<ClassSectionExpansionPanel> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.only(top: 15, bottom: 15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: Image.network(
                      widget.classObj.image,
                      height: 90,
                      width: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: OlukoNeumorphism.isNeumorphismDesign
                          ? [
                              Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: Text(
                                    "${OlukoLocalizations.get(context, 'class').toUpperCase()} ${widget.index + 1}/${widget.total}",
                                    style: OlukoFonts.olukoSmallFont(custoFontWeight: FontWeight.bold, customColor: OlukoColors.yellow),
                                  )),
                              Padding(
                                padding: const EdgeInsets.only(left: 15.0, top: 5, bottom: 0),
                                child: Text(
                                  widget.classObj.name,
                                  style: OlukoFonts.olukoSmallFont(custoFontWeight: FontWeight.bold, customColor: OlukoColors.white),
                                ),
                              ),
                            ]
                          : [
                              Padding(
                                padding: const EdgeInsets.only(left: 15.0, top: 0, bottom: 10),
                                child: Text(
                                  widget.classObj.name,
                                  style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.w500, customColor: OlukoColors.grayColor),
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: Text(
                                    "${OlukoLocalizations.get(context, 'class').toUpperCase()} ${widget.index + 1}/${widget.total}",
                                    style: OlukoFonts.olukoSmallFont(custoFontWeight: FontWeight.bold, customColor: OlukoColors.white),
                                  )),
                            ],
                    ),
                  ),
                ],
              ),
              OlukoNeumorphism.isNeumorphismDesign
                  ? SizedBox()
                  : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0, bottom: 0, right: 10),
                              child: () {
                                if (widget.classObj.description != null) {
                                  return Text(widget.classObj.description,
                                      style: OlukoFonts.olukoMediumFont(
                                          custoFontWeight: FontWeight.normal, customColor: OlukoColors.grayColor));
                                } else {
                                  return const SizedBox();
                                }
                              }(),
                            ),
                          ],
                        ),
                      ),
                    ]),
            ],
          ),
        ),
      ),
    );
  }
}
