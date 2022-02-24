import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

class ContentFromGalleyService {
  static Future<Uint8List> getFirstVideoGallery() async {
    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList();
    for (final assetPathEntity in albums) {
      List<AssetEntity> entity = await assetPathEntity.getAssetListPaged(0, 1);
      if (entity[0].duration > 1) {
        return entity[0].thumbDataWithSize(90, 90);
      }
    }
    return null;
  }
  static Future<Uint8List> getFirstImageGallery() async {
    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList();
    for (final assetPathEntity in albums) {
      List<AssetEntity> entity = await assetPathEntity.getAssetListPaged(0, 1);
      if (entity[0]!=null&& entity[0].duration==0) {
        return entity[0].thumbDataWithSize(90, 90);
      }
    }
    return null;
  }
}
