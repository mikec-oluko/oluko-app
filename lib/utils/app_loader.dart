import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

class AppLoader {
  static startLoading(BuildContext context) {
    Loader.show(context, progressIndicator: CircularProgressIndicator(), isAppbarOverlay: true);
  }

  static stopLoading() {
    Loader.hide();
  }
}
