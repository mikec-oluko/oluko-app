import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

class LoaderService {
  static startLoading(context) {
    Loader.show(context, progressIndicator: CircularProgressIndicator());
  }

  static stopLoading() {
    Loader.hide();
  }
}
