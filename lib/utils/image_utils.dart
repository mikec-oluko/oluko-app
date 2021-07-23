import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/helpers/encoding_provider.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';

class ImageUtils {
  ///Used as a loading placeholder when a NetworkImage is loading
  static Widget frameBuilder(
      context, Widget child, int frame, bool wasSynchronouslyLoaded,
      {double height = 120, double width}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        frame == null
            ? Container(height: height, child: OlukoCircularProgressIndicator())
            : SizedBox(),
        AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOut,
            child: child),
      ],
    );
  }

  ///Generate a thumbnail for an Image with the specified width & height.
  Future<Image> getThumbnailForImage(
      PickedFile image, int width, int height) async {
    String thumbnailPath =
        await EncodingProvider.getImageThumb(image.path, width, height);
    return Image.file(File(thumbnailPath));
  }
}
