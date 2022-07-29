import 'package:oluko_app/models/submodels/alert.dart';

class RoundsAlerts {
  List<Alert> alerts;

  RoundsAlerts({this.alerts});

  factory RoundsAlerts.fromJson(Map<String, dynamic> json) {
    return RoundsAlerts(
      alerts: json['alerts'] == null
          ? null
          : List<Alert>.from(
              (json['alerts'] as Iterable).map((alert) => alert == null ? null : Alert.fromJson(alert as Map<String, dynamic>))),
    );
  }

  Map<String, dynamic> toJson() => {
        'alerts': alerts == null ? null : List<dynamic>.from(alerts.map((alert) => alert.toJson())),
      };
}
