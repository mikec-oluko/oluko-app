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
  Future<String> getThumbnailForImage(PickedFile image, int width,
      {int height}) async {
    Image.file(File(image.path));
    if (height == null) {
      var decodedImage =
          await decodeImageFromList(File(image.path).readAsBytesSync());
      double aspectRatio = decodedImage.width / decodedImage.height;
      //The operator '~/' get the closest int to the operation
      height = (width ~/ aspectRatio);
    }
    String thumbnailPath =
        await EncodingProvider.getImageThumb(image.path, width, height);
    return thumbnailPath;
  }
}
