import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class Permissions {
  static Future<bool> requiredPermissionsEnabled(DeviceContentFrom uploadedFrom, {bool checkMicrophone = true}) async {
    if (checkMicrophone) {
      await Permission.microphone.request();
    }
    if (uploadedFrom == DeviceContentFrom.camera) {
      await Permission.camera.request();
      if (await Permission.camera.status.isDenied ||
          await Permission.camera.status.isPermanentlyDenied ||
          checkMicrophone && (await Permission.microphone.status.isDenied || await Permission.microphone.status.isPermanentlyDenied)) {
        return false;
      }
    } else if (uploadedFrom == DeviceContentFrom.gallery) {
      await Permission.storage.request();
      if (Platform.isIOS) {
        if (double.tryParse(Platform.operatingSystemVersion?.split('.')[0]) >= 14) {
          if (await Permission.photos.status.isDenied || await Permission.photos.status.isPermanentlyDenied) {
            return false;
          }
        } else {
          return validateStorage();
        }
      } else {
        return validateStorage();
      }
    }
    return true;
  }

  static Future<bool> validateStorage() async {
    return !await Permission.storage.status.isDenied && !await Permission.storage.status.isPermanentlyDenied;
  }
}
