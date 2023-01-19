import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class FullScreenLoadingComponent extends StatelessWidget {
  const FullScreenLoadingComponent({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: ScreenUtils.width(context),
        height: ScreenUtils.height(context),
        color: OlukoNeumorphismColors.appBackgroundColor,
        child: OlukoCircularProgressIndicator());
  }
}
