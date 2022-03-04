import 'package:oluko_app/routes.dart';

class OlukoBottomNavigationBarItem {
  OlukoBottomNavigationBarItem(
      {this.title,
      this.selectedAssetImageUrl,
      this.disabledAssetImageUrl,
      this.selected = false,
      this.route,
      this.disabled = false});

  String title;
  String selectedAssetImageUrl;
  String disabledAssetImageUrl;
  bool selected;
  RouteEnum route;
  bool disabled;
}
