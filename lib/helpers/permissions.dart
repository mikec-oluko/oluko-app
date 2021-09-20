import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:permission_handler/permission_handler.dart';

class Permissions {
  static Future<bool> requiredPermissionsEnabled(DeviceContentFrom uploadedFrom) async {
    if (uploadedFrom == DeviceContentFrom.gallery) {
      if (await Permission.camera.status.isDenied || await Permission.camera.status.isPermanentlyDenied) {
        return false;
      }
    } else if (uploadedFrom == DeviceContentFrom.camera) {
      if (await Permission.camera.status.isDenied || await Permission.camera.status.isPermanentlyDenied) {
        return false;
      }
    }
    return true;
  }
}
