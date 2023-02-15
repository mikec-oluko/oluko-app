import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class NotEnrolledComponent extends StatefulWidget {
  const NotEnrolledComponent() : super();

  @override
  State<NotEnrolledComponent> createState() => _NotEnrolledComponentState();
}

class _NotEnrolledComponentState extends State<NotEnrolledComponent> {
  bool _isBottomTabActive = true;
  String mediaURL;
  bool isVideoVisible = true;

  @override
  Widget build(BuildContext context) {
    return _getEnrollAndPlusButtonContent(context);
  }

  Container _getEnrollAndPlusButtonContent(BuildContext context) {
    return Container(
      height: ScreenUtils.height(context) / 1.5,
      color: OlukoNeumorphismColors.appBackgroundColor,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: ScreenUtils.height(context) * 0.15),
            child: Image.asset(
              OlukoNeumorphism.mvtLogo,
              scale: 2,
            ),
          ),
          SizedBox(
            height: ScreenUtils.height(context) / 5,
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                routeLabels[RouteEnum.courses],
                arguments: {
                  'homeEnrollTocourse': true,
                  'showBottomTab': () => setState(() {
                        _isBottomTabActive = !_isBottomTabActive;
                      })
                },
              );
            },
            child: Neumorphic(
              style: OlukoNeumorphism.getNeumorphicStyleForCircleElement(),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Image.asset(
                  'assets/home/plus.png',
                  scale: 4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
