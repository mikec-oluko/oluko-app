import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class Permissions {
  static Future<bool> requiredPermissionsEnabled(DeviceContentFrom uploadedFrom, {bool checkMicrophone = true}) async {
    if (uploadedFrom == DeviceContentFrom.camera) {
      if (await Permission.camera.status.isDenied ||
          await Permission.camera.status.isPermanentlyDenied ||
          checkMicrophone && (await Permission.microphone.status.isDenied || await Permission.microphone.status.isPermanentlyDenied)) {
        return false;
      }
    } else if (uploadedFrom == DeviceContentFrom.gallery) {
      if(await Permission.storage.status.isDenied && await Permission.storage.status.isPermanentlyDenied){
        return false;
      }
    }
    return true;
  }
}
