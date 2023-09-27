import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:permission_handler/permission_handler.dart';

class Permissions {
  static Future<bool> requiredPermissionsEnabled(DeviceContentFrom uploadedFrom, {bool checkMicrophone = true}) async {
    if (checkMicrophone) {
      await Permission.microphone.request();
    }
    if (uploadedFrom == DeviceContentFrom.camera) {
      await Permission.camera.request();
      if (await Permission.camera.status.isDenied ||
          await Permission.camera.status.isPermanentlyDenied ||
          (checkMicrophone && (await Permission.microphone.status.isDenied || await Permission.microphone.status.isPermanentlyDenied))) {
        return false;
      }
    } else if (uploadedFrom == DeviceContentFrom.gallery) {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt <= 32) {
          await Permission.storage.request();
          if (await Permission.storage.status.isDenied || await Permission.storage.status.isPermanentlyDenied) {
            return false;
          }
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

  static Future<void> askForPermissions({bool checkCamera = true, bool checkPhotos = true, bool checkMicrophone = true}) async {
    if (checkCamera) {
      await Permission.camera.request();
    }
    if (checkPhotos) {
      if (Platform.isAndroid) {
        await Permission.storage.request();
      } else {
        await Permission.photos.request();
      }
    }
    if (checkMicrophone) {
      await Permission.microphone.request();
    }
  }
}
