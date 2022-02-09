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
  String route;
  bool disabled;
}
