import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:oluko_app/helpers/enum_helper.dart';
import 'package:oluko_app/models/purchase.dart';
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
Map<PlanDuration, String> shortDurationLabel = {PlanDuration.YEARLY: 'yr', PlanDuration.MONTHLY: 'yr', PlanDuration.DAILY: 'dy'};

class Plan extends Base {
  Plan(
      {this.active,
      this.amount,
      this.amountDecimal,
      this.currency,
      this.description,
      this.interval,
      this.intervalCount,
      this.livemode,
      this.metadata,
      this.name,
      this.object,
      this.type,
      this.appleId,
      this.applePrice,
      String id,
      Timestamp createdAt,
      String createdBy,
      Timestamp updatedAt,
      String updatedBy,
      bool isHidden,
      bool isDeleted})
      : super(id: id, createdBy: createdBy, createdAt: createdAt, updatedAt: updatedAt, updatedBy: updatedBy, isDeleted: isDeleted, isHidden: isHidden);

  bool active;
  int amount;
  String amountDecimal;
  String currency;
  String description;
  String interval;
  int intervalCount;
  bool livemode;
  Map<String, dynamic> metadata;
  String name;
  String object;
  String type;
  String appleId;
  int applePrice;

  factory Plan.fromJson(Map<String, dynamic> json) {
    Plan plan = Plan(
      active: json['active'] is bool ? json['active'] as bool : false,
      amount: json['amount'] is int ? json['amount'] as int : null,
      amountDecimal: json['amount_decimal']?.toString(),
      currency: json['currency']?.toString(),
      description: json['description']?.toString(),
      interval: json['interval']?.toString(),
      intervalCount: json['interval_count'] is int ? json['interval_count'] as int : null,
      livemode: json['livemode'] is bool ? json['livemode'] as bool : false,
      metadata: json['metadata'] as Map<String, dynamic>,
      name: json['name']?.toString(),
      object: json['object']?.toString(),
      type: json['type']?.toString(),
      appleId: json['apple_id']?.toString(),
      applePrice: json['apple_price'] is int ? json['apple_price'] as int : null,
    );

    plan.setBase(json);
    return plan;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> planJson = {
      'active': active,
      'amount': amount,
      'amount_decimal': amountDecimal,
      'currency': currency,
      'description': description,
      'interval': interval,
      'interval_count': intervalCount,
      'livemode': livemode,
      'metadata': metadata,
      'name': name,
      'object': object,
      'type': type,
      'apple_id': appleId,
      'apple_price': applePrice
    };
    planJson.addEntries(super.toJson().entries);
    return planJson;
  }

  bool isCurrentLevel(int currentPlan) {
    if (metadata != null) {
      return double.parse(metadata['level'].toString()) == currentPlan;
    } else {
      return false;
    }
  }

  Purchase mapToPurchase(PurchaseDetails purchaseDetails, Plan plan, String userId) {
    return Purchase(
        appPlanId: purchaseDetails.productID,
        customerId: userId,
        paymentType: 'applePay',
        poNumber: purchaseDetails.purchaseID,
        createdAt:
            int.tryParse(purchaseDetails.transactionDate) is int ? Timestamp.fromMicrosecondsSinceEpoch(int.tryParse(purchaseDetails.transactionDate)) : null,
        createdBy: userId,
        cancelAtPeriodEnd: false,
        currentPeriodEnd: null,
        currentPeriodEndString: null,
        finalAmount: plan.applePrice,
        price: plan.applePrice,
        priceId: null,
        planId: plan.id,
        productDescription: plan.description,
        productId: plan.id,
        platform: Platform.APP,
        productName: plan.name,
        subscriptionId: purchaseDetails.purchaseID, //???
        recurringInterval: plan.interval,
        status: purchaseDetails.status == PurchaseStatus.purchased ? 'active' : 'inactive');
  }
}
