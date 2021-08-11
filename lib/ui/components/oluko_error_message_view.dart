import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class OlukoErrorMessage extends StatelessWidget {
  final String section;
  OlukoErrorMessage({this.section});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: OlukoColors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: OlukoColors.primary,
                size: 25,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  this.section != null
                      ? OlukoLocalizations.of(context).find('errorOcurredOn') +
                          this.section
                      : OlukoLocalizations.of(context).find('errorOcurred'),
                  style: OlukoFonts.olukoMediumFont(
                      customColor: OlukoColors.primary),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
