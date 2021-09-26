import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/helpers/enum_helper.dart';
import 'package:oluko_app/utils/info_dialog.dart';

import 'base.dart';

enum PlanFeature { ACCESS_CONTENT, CONNECT_COACH_TWICE_WEEK, CONNECT_COACH_TWICE_MONTH }

enum PlanDuration { YEARLY, MONTHLY, DAILY }

Map<PlanFeature, String> featureLabel = {
  PlanFeature.ACCESS_CONTENT: 'Access to all content',
  PlanFeature.CONNECT_COACH_TWICE_WEEK: 'Connect with coach twice a month',
  PlanFeature.CONNECT_COACH_TWICE_MONTH: 'Connect with coach twice a week'
};

Map<PlanDuration, String> durationLabel = {PlanDuration.YEARLY: 'Year', PlanDuration.MONTHLY: 'Month', PlanDuration.DAILY: 'Day'};

class Plan extends Base {
  Plan(
      {this.duration,
      this.features,
      this.infoDialog,
      this.price,
      this.recurrent,
      this.title,
      this.backgroundImage,
      this.metadata,
      String id,
      Timestamp createdAt,
      String createdBy,
      Timestamp updatedAt,
      String updatedBy,
      bool isHidden,
      bool isDeleted})
      : super(
            id: id,
            createdBy: createdBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            updatedBy: updatedBy,
            isDeleted: isDeleted,
            isHidden: isHidden);

  PlanDuration duration;
  List<PlanFeature> features;
  InfoDialog infoDialog;
  num price;
  bool recurrent;
  String title;
  String backgroundImage;
  Map<String, String> metadata;

  factory Plan.fromJson(Map<String, dynamic> json) {
    Plan plan = Plan(
        duration: EnumHelper.enumFromString<PlanDuration>(PlanDuration.values, json['duration'].toString()),
        features: List.from(json['features'] as Iterable)
            .map((e) => EnumHelper.enumFromString<PlanFeature>(PlanFeature.values, e.toString()))
            .toList(),
        infoDialog: json['info_dialog'] != null ? InfoDialog.fromJson(json['info_dialog'] as Map<String, dynamic>) : null,
        price: json['price'] as num,
        recurrent: json['recurrent'] as bool,
        title: json['title'].toString(),
        backgroundImage: json['background_image'].toString(),
        metadata: json['metadata'] as Map<String, String>);
    plan.setBase(json);
    return plan;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> planJson = {
      'duration': EnumHelper.enumToString(duration),
      'features': features.map((feature) => EnumHelper.enumToString(feature)).toList(),
      'info_dialog': infoDialog.toJson(),
      'price': price,
      'recurrent': recurrent,
      'title': title,
      'background_image': backgroundImage,
      'metadata': metadata
    };
    planJson.addEntries(super.toJson().entries);
    return planJson;
  }

  bool isCurrentLevel(double currentPlan) {
    if (metadata != null) {
      return (double.parse(metadata['level']) == currentPlan);
    } else {
      return false;
    }
  }
}
