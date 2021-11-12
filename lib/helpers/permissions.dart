import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class Permissions {
  static Future<bool> requiredPermissionsEnabled(DeviceContentFrom uploadedFrom) async {
    if (uploadedFrom == DeviceContentFrom.camera) {
      if (await Permission.camera.status.isDenied || await Permission.camera.status.isPermanentlyDenied) {
        return false;
      }
    } else if (uploadedFrom == DeviceContentFrom.gallery) {
      if (Platform.isIOS) {
       if((Platform.version?.split(' ')[0] as double) > 14){
         if (await Permission.photos.status.isDenied || await Permission.photos.status.isPermanentlyDenied) {
          return false;
        }
       }
      }else{
        if (await Permission.storage.status.isDenied || await Permission.storage.status.isPermanentlyDenied) {
          return false;
        }
      }
    }
    return true;
  }
}
