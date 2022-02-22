import 'package:flutter/cupertino.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/permissions.dart';
import 'package:oluko_app/ui/components/settings_dialog.dart';
import 'package:oluko_app/ui/components/settings_modal_neumorphic.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';

import 'dialog_utils.dart';

class PermissionsUtils {
  static void showSettingsMessage(BuildContext context) {
    if (OlukoNeumorphism.isNeumorphismDesign) {
      BottomDialogUtils.showBottomDialog(context: context, content: SettingsModalNeumorphic(context));
    } else {
      DialogUtils.getDialog(context, [SettingsDialog(context)], showExitButton: false);
    }
  }

  static Future<bool> permissionsEnabled(DeviceContentFrom uploadedFrom, {bool checkMicrophone = true}) async {
    if (!await Permissions.requiredPermissionsEnabled(uploadedFrom, checkMicrophone: checkMicrophone)) {
      return false;
    }
    return true;
  }
}
