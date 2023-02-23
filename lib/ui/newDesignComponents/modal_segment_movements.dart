import 'dart:ui';
import 'package:flutter/material.dart';

class MovementsModal {
  static modalContent({BuildContext context, List<Widget> content}) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext _) {
          return ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: ListView(
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                    shrinkWrap: true,
                    children: content,
                  ),
                ),
              ));
        });
  }
}
