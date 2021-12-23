import 'dart:io';

import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:permission_handler/permission_handler.dart';

class Permissions {
  static Future<bool> requiredPermissionsEnabled(DeviceContentFrom uploadedFrom, {bool checkMicrophone = true}) async {
    if (checkMicrophone) {
      await Permission.microphone.request();
    }
    if (uploadedFrom == DeviceContentFrom.camera) {
      await Permission.camera.request();
      var aux = await Permission.camera.status.isDenied;
      var aux2 = await Permission.camera.status.isPermanentlyDenied;
      if (await Permission.camera.status.isDenied ||
          await Permission.camera.status.isPermanentlyDenied ||
          checkMicrophone && (await Permission.microphone.status.isDenied || await Permission.microphone.status.isPermanentlyDenied)) {
        return false;
      }
    } else if (uploadedFrom == DeviceContentFrom.gallery) {
      if (Platform.isAndroid) {
        await Permission.storage.request();
        if (await Permission.storage.status.isDenied || await Permission.storage.status.isPermanentlyDenied) {
          return false;
        }
      } else {
        await Permission.photos.request();
        if (await Permission.photos.status.isDenied || await Permission.photos.status.isPermanentlyDenied) {
          return false;
        }
      }
    }
    return true;
  }
}
