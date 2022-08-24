import 'package:cloud_firestore/cloud_firestore.dart';
import 'base.dart';

enum Platform { WEB, APP }

class Purchase extends Base {
  Purchase(
      {this.paymentType,
      this.planId,
      this.appPlanId,
      this.cancelAtPeriodEnd,
      this.couponId,
      this.couponName,
      this.currentPeriodEndString,
      this.currentPeriodEnd,
      this.customerId,
      this.finalAmount,
      this.platform,
      this.poNumber,
      this.price,
      this.priceId,
      this.productDescription,
      this.productId,
      this.productName,
      this.recurringInterval,
      this.status,
      this.subscriptionId,
      this.walletName,
      String id,
      Timestamp createdAt,
      String createdBy,
      Timestamp updatedAt,
      String updatedBy,
      bool isHidden,
      bool isDeleted})
      : super(id: id, createdBy: createdBy, createdAt: createdAt, updatedAt: updatedAt, updatedBy: updatedBy, isDeleted: isDeleted, isHidden: isHidden);

  String customerId;
  String paymentType;
  String planId;
  String poNumber;
  int finalAmount;
  int price;
  String recurringInterval;
  String priceId;
  String subscriptionId;
  String currentPeriodEndString;
  int currentPeriodEnd;
  bool cancelAtPeriodEnd;
  String status;
  String productName;
  String productDescription;
  String productId;
  String walletName;
  String appPlanId;
  String couponName;
  String couponId;
  Platform platform;

  factory Purchase.fromJson(Map<String, dynamic> json) {
    Purchase purchase = Purchase(
      customerId: json['customer_id']?.toString(),
      paymentType: json['payment_type']?.toString(),
      planId: json['plan_id']?.toString(),
      poNumber: json['poNumber']?.toString(),
      finalAmount: json['final_amount'] is int ? json['final_amount'] as int : null,
      price: json['price'] is int ? json['price'] as int : null,
      recurringInterval: json['recurring_interval']?.toString(),
      priceId: json['priceId']?.toString(),
      subscriptionId: json['subscription_id']?.toString(),
      currentPeriodEnd: json['current_period_end'] is int ? json['current_period_end'] as int : null,
      currentPeriodEndString: json['current_period_end_string']?.toString(),
      cancelAtPeriodEnd: json['cancel_at_period_end'] is bool ? json['cancel_at_period_end'] as bool : false,
      status: json['status']?.toString(),
      productName: json['product_name']?.toString(),
      productDescription: json['product_description']?.toString(),
      productId: json['product_id']?.toString(),
      walletName: json['walletName']?.toString(),
      appPlanId: json['appPlanId']?.toString(),
      couponName: json['couponName']?.toString(),
      couponId: json['couponId']?.toString(),
      platform: json['platform'] == null ? null : Platform.values[json['platform'] as int],
    );

    purchase.setBase(json);
    return purchase;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> purchaseJson = {
      'customer_id': customerId,
      'payment_type': paymentType,
      'plan_id': planId,
      'poNumber': poNumber,
      'final_amount': finalAmount,
      'price': price,
      'recurring_interval': recurringInterval,
      'priceId': priceId,
      'subscription_id': subscriptionId,
      'current_period_end': currentPeriodEnd,
      'current_period_end_string': currentPeriodEndString,
      'cancel_at_period_end': cancelAtPeriodEnd,
      'status': status,
      'product_name': productName,
      'product_description': productDescription,
      'product_id': productId,
      'walletName': walletName,
      'appPlanId': appPlanId,
      'couponName': couponName,
      'couponId': couponId,
      'platform': platform.index,
    };
    purchaseJson.addEntries(super.toJson().entries);
    return purchaseJson;
  }
}
