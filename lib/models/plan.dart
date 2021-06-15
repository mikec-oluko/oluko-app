import 'package:oluko_app/helpers/enum_helper.dart';
import 'package:oluko_app/models/info_dialog.dart';

enum PlanFeature {
  ACCESS_CONTENT,
  CONNECT_COACH_TWICE_WEEK,
  CONNECT_COACH_TWICE_MONTH
}

enum PlanDuration { YEARLY, MONTHLY, DAILY }

Map<PlanFeature, String> featureLabel = {
  PlanFeature.ACCESS_CONTENT: 'Access to all content',
  PlanFeature.CONNECT_COACH_TWICE_WEEK: 'Connect with coach twice a month',
  PlanFeature.CONNECT_COACH_TWICE_MONTH: 'Connect with coach twice a week'
};

Map<PlanDuration, String> durationLabel = {
  PlanDuration.YEARLY: 'Year',
  PlanDuration.MONTHLY: 'Month',
  PlanDuration.DAILY: 'Day'
};

class Plan {
  Plan(
      {this.duration,
      this.features,
      this.infoDialog,
      this.price,
      this.recurrent,
      this.title,
      this.backgroundImage});

  PlanDuration duration;
  List<PlanFeature> features;
  InfoDialog infoDialog;
  num price;
  bool recurrent;
  String title;
  String backgroundImage;

  Plan.fromJson(Map json)
      : duration = EnumHelper.enumFromString<PlanDuration>(
            PlanDuration.values, json['duration']),
        features = List.from(json['features'])
            .map((e) =>
                EnumHelper.enumFromString<PlanFeature>(PlanFeature.values, e))
            .toList(),
        infoDialog = json['info_dialog'] != null
            ? InfoDialog.fromJson(json['info_dialog'])
            : null,
        price = json['price'],
        recurrent = json['recurrent'],
        title = json['title'],
        backgroundImage = json['background_image'];

  Map<String, dynamic> toJson() => {
        'duration': EnumHelper.enumToString(duration),
        'features': features
            .map((feature) => EnumHelper.enumToString(feature))
            .toList(),
        'info_dialog': infoDialog.toJson(),
        'price': price,
        'recurrent': recurrent,
        'title': title,
        'background_image': backgroundImage
      };
}
