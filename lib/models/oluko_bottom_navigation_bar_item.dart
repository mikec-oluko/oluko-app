class OlukoBottomNavigationBarItem {
  OlukoBottomNavigationBarItem(
      {this.title,
      this.assetImageUrl,
      this.selected = false,
      this.route,
      this.disabled = false});

  String title;
  String assetImageUrl;
  bool selected;
  String route;
  bool disabled;
}
