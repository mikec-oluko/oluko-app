import 'dart:async';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  final String coreID = 'oluko_1999_1m';
  final String coachID = 'oluko_9999_1m';
  final String coachPlusID = 'oluko_19999_1m';

  bool available = true;
  List<ProductDetails> products = [];
  List<PurchaseDetails> purchases = [];
  StreamSubscription<List<PurchaseDetails>> subscription;

  void initState() {
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

    initialize();
  }

  void dispose() {
    if (subscription != null) {
      subscription.cancel();
    }
  }

  void initialize() async {
    final List<ProductDetails> appleProducts = await getProducts(
      <String>{coreID, coachID, coachPlusID},
    );
    products = appleProducts;
  }

  void listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          //  _showPendingUI();
          break;
        case PurchaseStatus.purchased:
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

  Future<void> subscribe(String productId) async {
    ProductDetails product = products?.firstWhere((product) => product.id == productId);
    if (product == null) {
      products = await getProducts(
        <String>{productId},
      );
      if (products != null && products.isNotEmpty) {
        product = products.first;
      }
    }
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    inAppPurchase.buyNonConsumable(
      purchaseParam: purchaseParam,
    );
  }

  ListTile buildProduct(ProductDetails product) {
    return ListTile(
      leading: const Icon(Icons.attach_money),
      title: Text('${product.title} - ${product.price}'),
      subtitle: Text(product.description),
      trailing: ElevatedButton(
        onPressed: () {
          subscribe(product.id);
        },
        child: const Text(
          'Subscribe',
        ),
      ),
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
