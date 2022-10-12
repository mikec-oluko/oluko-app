import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/assessment_assignment.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/assessment_assignment_repository.dart';
import 'package:oluko_app/routes.dart';

class RouteService {
  static Future<String> getInitialRoute(User alreadyLoggedUser, bool isFirstTime, UserResponse alreadyLoggedUserResponse) async {
    if (alreadyLoggedUser == null) {
      if (isFirstTime != null && isFirstTime && OlukoNeumorphism.isNeumorphismDesign) {
        return routeLabels[RouteEnum.introVideo];
      } else {
        if (OlukoNeumorphism.isNeumorphismDesign) {
          return routeLabels[RouteEnum.loginNeumorphic];
        } else {
          return routeLabels[RouteEnum.signUp];
        }
      }
    } else {
      if (alreadyLoggedUserResponse.currentPlan < 0 || alreadyLoggedUserResponse.currentPlan == null) {
        if (Platform.isIOS || Platform.isMacOS) {
          return routeLabels[RouteEnum.profileSubscription];
        } else {
          if (OlukoNeumorphism.isNeumorphismDesign) {
            return routeLabels[RouteEnum.loginNeumorphic];
          } else {
            return routeLabels[RouteEnum.signUp];
          }
        }
      }
        return routeLabels[RouteEnum.root];
    }
  }
}
