import 'dart:async';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/plan.dart';
import 'package:oluko_app/models/purchase.dart';
import 'package:oluko_app/repositories/purchase_repository.dart';

abstract class MarketState {}

class LoadingState extends MarketState {}

class MarketSuccess extends MarketState {
  MarketSuccess();
}

class Failure extends MarketState {
  final dynamic exception;
  Failure({this.exception});
}

class MarketBloc extends Cubit<MarketState> {
  MarketBloc() : super(LoadingState());
  final InAppPurchase inAppPurchase = InAppPurchase.instance;

  bool available = true;
  List<ProductDetails> products = [];
  List<PurchaseDetails> purchases = [];
  StreamSubscription<List<PurchaseDetails>> subscription;

  void initState(List<Plan> plans) {
    final Stream<List<PurchaseDetails>> purchaseUpdated = inAppPurchase.purchaseStream;
    subscription = purchaseUpdated.listen(
      (purchaseDetailsList) {
        purchases.addAll(purchaseDetailsList);
        listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () {
        subscription.cancel();
      },
      onError: (error) {
        subscription.cancel();
      },
    );

    initialize(plans);
  }

  void dispose() {
    if (subscription != null) {
      subscription.cancel();
    }
  }

  void initialize(List<Plan> plans) async {
    if (plans != null && plans.isNotEmpty) {
      final List<ProductDetails> appleProducts = await getProducts(plans.map((e) => e.id).toSet());
      products = appleProducts;
    }
  }

  void listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          //  _showPendingUI();
          break;
        case PurchaseStatus.purchased:
          PurchaseRepository.create(purchaseDetails);
          break;
        case PurchaseStatus.restored:
          // bool valid = await _verifyPurchase(purchaseDetails);
          // if (!valid) {
          //   _handleInvalidPurchase(purchaseDetails);
          // }
          break;
        case PurchaseStatus.error:
          print(purchaseDetails.error);
          // _handleError(purchaseDetails.error!);
          break;
        default:
          break;
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await inAppPurchase.completePurchase(purchaseDetails);
      }
    });
  }

  Future<List<ProductDetails>> getProducts(Set<String> productIds) async {
    final ProductDetailsResponse response = await inAppPurchase.queryProductDetails(productIds);
    return response.productDetails;
  }

  Future<void> subscribe(Plan plan, String userId) async {
    ProductDetails product = products?.firstWhere((product) => product.id == plan.appleId, orElse: () => null,);
    if (product == null) {
      products = await getProducts(
        <String>{plan.appleId},
      );
      if (products != null && products.isNotEmpty) {
        product = products.first;
      }
    }
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product, applicationUserName: userId);
    inAppPurchase.buyNonConsumable(
      purchaseParam: purchaseParam,
    );
  }

  ListTile buildPurchase(PurchaseDetails purchase) {
    if (purchase.error != null) {
      return ListTile(
        title: Text('${purchase.error}'),
        subtitle: Text(purchase.status.toString()),
      );
    }

    String transactionDate;
    if (purchase.status == PurchaseStatus.purchased) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(
        int.parse(purchase.transactionDate),
      );
      transactionDate = ' @ ${DateFormat('yyyy-MM-dd HH:mm:ss').format(date)}';
    }

    return ListTile(
      title: Text('${purchase.productID} ${transactionDate ?? ''}'),
      subtitle: Text(purchase.status.toString()),
    );
  }
}
