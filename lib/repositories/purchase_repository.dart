import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:oluko_app/models/plan.dart';
import 'package:oluko_app/models/purchase.dart';
import 'package:oluko_app/models/user_response.dart';

class PurchaseRepository {
  FirebaseFirestore firestoreInstance;

  PurchaseRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  PurchaseRepository.test({this.firestoreInstance});

  static Future<Purchase> getLastPurchase(String userId) async {
    final QuerySnapshot<Map<String, dynamic>> purchaseDoc = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
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

  static Future<UserResponse> create(PurchaseDetails purchaseDetails, ProductDetails productDetails, String userId) async {
    final DocumentReference proyectReference = FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId'));
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
    purchase.currentPeriodEnd = DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch;
    await userReference.collection('purchases').doc(purchase.id).set(purchase.toJson());
    await userReference.update({'current_plan': plan.metadata['level']});
    final userDoc = await userReference.get();
    final userJson = userDoc.data() as Map<String, dynamic>;
    return UserResponse.fromJson(userJson);
  }

  static restore(String userId, String productId) async {
    final DocumentReference userReference =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('users').doc(userId);
    QuerySnapshot<Map<String, dynamic>> purchasesSnapshot = await userReference.collection('purchases').where('appPlanId', isEqualTo: productId).get();
    purchasesSnapshot.docs.forEach((purchase) {
      purchase.reference.update({'status': 'inactive', 'is_deleted': true});
    });
    await userReference.update({'current_plan': -1});
  }
}
