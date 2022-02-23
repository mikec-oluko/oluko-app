import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

class AssesmentService {
  static Future<Uint8List> getFirstVideoGallery() async {
    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList();
    for (final assetPathEntity in albums) {
      List<AssetEntity> photo = await assetPathEntity.getAssetListPaged(0, 1);
      if (photo[0].duration > 1) {
        return photo[0].thumbDataWithSize(90, 90);
      }
    }
    return null;
  }
}
