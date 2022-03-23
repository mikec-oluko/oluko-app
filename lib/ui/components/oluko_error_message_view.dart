import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class OlukoErrorMessage extends StatelessWidget {
  final String section;
  final ErrorTypeOption whyIsError;
  OlukoErrorMessage({this.section, this.whyIsError});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: OlukoColors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
                      ? OlukoLocalizations.get(context, 'errorOccurredOn') + this.section
                      : returnErrorText(context, whyIsError),
                  style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  String returnErrorText(BuildContext context, ErrorTypeOption whyIsError) {
    String _contentForTitle;
    if (whyIsError == ErrorTypeOption.noContent) {
      _contentForTitle = OlukoLocalizations.get(context, 'noContent');
    } else {
      _contentForTitle = OlukoLocalizations.get(context, 'errorOccurred');
    }
    return _contentForTitle;
  }
}
