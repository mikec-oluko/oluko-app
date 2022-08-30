import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:oluko_app/models/plan.dart';
import 'package:oluko_app/models/purchase.dart';

class PurchaseRepository {
  FirebaseFirestore firestoreInstance;

  PurchaseRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  PurchaseRepository.test({this.firestoreInstance});

  static Future<Purchase> getLastPurchase(String userId) async {
    final QuerySnapshot<Map<String, dynamic>> purchaseDoc = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('users')
        .doc(userId)
        .collection('purchases')
        .orderBy('created_at', descending: true)
        .limit(1)
        .get();
    try {
      final Map<String, dynamic> purchaseJson = purchaseDoc?.docs?.first?.data();
      if (purchaseJson != null) {
        return Purchase.fromJson(purchaseJson);
      }
    } catch (e) {
      return null;
    }

    return null;
  }

  static create(PurchaseDetails purchaseDetails, ProductDetails productDetails) async {
    final DocumentReference proyectReference = FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getValue('projectId'));
    final String userId = (purchaseDetails as dynamic)?.skPaymentTransaction?.payment?.applicationUsername?.toString();
    final DocumentReference userReference = proyectReference.collection('users').doc(userId);
    final QuerySnapshot<Map<String, dynamic>> planDocRef =
        await proyectReference.collection('plans').where('apple_id', isEqualTo: purchaseDetails.productID).get();
    final Map<String, dynamic> planJson = planDocRef?.docs?.first?.data();
    final Plan plan = Plan.fromJson(planJson);
    final Purchase purchase = plan.mapToPurchase(purchaseDetails, plan, userId);
    purchase.id = proyectReference.collection('purchases').doc().id;
    if (productDetails != null) {
      purchase.finalAmount = productDetails.rawPrice is int || productDetails.rawPrice is double ? productDetails.rawPrice.toInt() : purchase.finalAmount;
    }
    await proyectReference.collection('purchases').doc(purchase.id).set(purchase.toJson());
    await userReference.collection('purchases').doc(purchase.id).set(purchase.toJson());
    await userReference.update({'current_plan': plan.metadata['level']});
  }
}
