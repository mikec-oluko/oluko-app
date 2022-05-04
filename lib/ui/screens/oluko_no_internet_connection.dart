import 'package:flutter/material.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_no_internet_component.dart';

class OlukoNoInternetConnectionPage extends StatelessWidget {
  const OlukoNoInternetConnectionPage() : super();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: const OlukoNoInternetConectionComponent(
        contentFor: NoInternetContentEnum.fullscreen,
      ),
    );
  }
}
