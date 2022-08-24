import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:oluko_app/models/plan.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/auth_repository.dart';
import 'package:oluko_app/repositories/plan_repository.dart';
import 'package:oluko_app/repositories/purchase_repository.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class SubscriptionContentState {}

class LoadingState extends SubscriptionContentState {}

class GoToHomeState extends SubscriptionContentState {}

class GoBackState extends SubscriptionContentState {}

class PurchasePending extends SubscriptionContentState {
  PurchasePending();
}

class PurchaseSuccess extends SubscriptionContentState {}

class PurchaseRestored extends SubscriptionContentState {}

class PurchaseFailed extends SubscriptionContentState {}

class Failure extends SubscriptionContentState {
  final dynamic exception;
  Failure({this.exception});
}

class SubscriptionContentLoading extends SubscriptionContentState {}

class SubscriptionContentInitialized extends SubscriptionContentState {
  List<Plan> plans;
  UserResponse user;
  SubscriptionContentInitialized({this.plans, this.user});
}

class SubscriptionContentFailed extends SubscriptionContentState {
  final dynamic exception;
  SubscriptionContentFailed({this.exception});
}

class SubscriptionContentBloc extends Cubit<SubscriptionContentState> {
  SubscriptionContentBloc() : super(SubscriptionContentLoading());

  final InAppPurchase inAppPurchase = InAppPurchase.instance;

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
    try {
      final List<Plan> plans = await PlanRepository.getAll();
      final UserResponse user = await UserRepository().getById(AuthRepository.getLoggedUser().uid);
      if (plans != null && plans.isNotEmpty) {
        final List<ProductDetails> appleProducts = await getProducts(plans.map((e) => e.id).toSet());
        products = appleProducts;
      }

      emit(SubscriptionContentInitialized(plans: plans, user: user));
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(SubscriptionContentFailed(exception: exception));
      rethrow;
    }
  }

  void listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          emit(PurchasePending());
          break;
        case PurchaseStatus.purchased:
          emit(PurchaseSuccess());
          await PurchaseRepository.create(purchaseDetails);
          break;
        case PurchaseStatus.restored:
          emit(PurchaseRestored());
          break;
        case PurchaseStatus.error:
          emit(PurchaseFailed());
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
    emit(LoadingState());
    ProductDetails product = products?.firstWhere(
      (product) => product.id == plan.appleId,
      orElse: () => null,
    );
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

  void emitSubscriptionContentLoading() {
    emit(SubscriptionContentLoading());
  }
}
