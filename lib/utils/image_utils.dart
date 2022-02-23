import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;

class ImageUtils {
  static const String jpgFormat = '.jpg';
  static const String jpegFormat = '.jepg';

  ///Used as a loading placeholder when a NetworkImage is loading
  static Widget frameBuilder(context, Widget child, int frame, bool wasSynchronouslyLoaded, {double height = 120, double width}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        frame == null ? Container(height: height, child: OlukoCircularProgressIndicator()) : SizedBox(),
        AnimatedOpacity(opacity: frame == null ? 0 : 1, duration: Duration(milliseconds: 500), curve: Curves.easeOut, child: child),
      ],
    );
  }

  ///Generate a thumbnail for an Image with the specified width & height.
  Future<String> getThumbnailForImage(XFile image, int width, {int height}) async {
    //Image.file(File(image.path)); TODO: does nothing?
    var calculatedHeight = height;
    if (height == null) {
      var decodedImage = await decodeImageFromList(File(image.path).readAsBytesSync());
      double aspectRatio = decodedImage.width / decodedImage.height;
      //The operator '~/' get the closest int to the operation
      calculatedHeight = (width ~/ aspectRatio);
    }
    var thumbnailPath = p.withoutExtension(image.path) + '_thumbnail.' + p.extension(image.path);
    var thumbnail = await FlutterImageCompress.compressAndGetFile(image.path, thumbnailPath, minWidth: width, minHeight: calculatedHeight);
    return thumbnail.path;
  }
}
