import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:oluko_app/models/plan.dart';
import 'package:oluko_app/models/purchase.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/repositories/auth_repository.dart';
import 'package:oluko_app/repositories/plan_repository.dart';
import 'package:oluko_app/repositories/purchase_repository.dart';
import 'package:oluko_app/repositories/user_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class SubscriptionContentState {}

class PurchasePending extends SubscriptionContentState {
  PurchasePending();
}

class PurchaseSuccess extends SubscriptionContentState {
  final UserResponse user;
  PurchaseSuccess({this.user});
}

class PurchaseRestored extends SubscriptionContentState {}

class ManageFromWebState extends SubscriptionContentState {}

class FailureState extends SubscriptionContentState {
  final dynamic exception;
  FailureState({this.exception});
}

class SubscriptionContentLoading extends SubscriptionContentState {}

class SubscriptionContentInitialized extends SubscriptionContentState {
  List<Plan> plans;
  UserResponse user;
  SubscriptionContentInitialized({this.plans, this.user});
}

class SubscriptionContentBloc extends Cubit<SubscriptionContentState> {
  SubscriptionContentBloc() : super(SubscriptionContentLoading());

  final InAppPurchase inAppPurchase = InAppPurchase.instance;

  bool available = true;
  List<ProductDetails> products = [];
  List<PurchaseDetails> purchases = [];
  StreamSubscription<List<PurchaseDetails>> subscription;

  void initState(bool fromRegister) {
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
    getProductsForUser(fromRegister);
  }

  void dispose() {
    if (subscription != null) {
      subscription.cancel();
    }
  }

  void getProductsForUser(bool fromRegister) async {
    try {
      final String userId = AuthRepository.getLoggedUser().uid;
      await initAndEmit(userId);
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(FailureState(exception: exception));
      rethrow;
    }
  }

  Future<void> initAndEmit(String userId) async {
    final List<Plan> plans = await PlanRepository.getAll();
    final UserResponse user = await UserRepository().getById(userId);
    if (plans != null && plans.isNotEmpty) {
      final List<ProductDetails> appleProducts = await getProducts(plans.map((e) => e.appleId).toSet());
      products = appleProducts;
    }
    emit(SubscriptionContentInitialized(plans: plans, user: user));
  }

  Future<void> subscriptionPlatform(String userId) async {
    final Purchase lastPurchase = await PurchaseRepository.getLastPurchase(userId);
    if (lastPurchase != null) {
      if (lastPurchase.platform != Platform.APP) {
        emit(ManageFromWebState());
      }
    }
  }

  void listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      final ProductDetails productDetails = products?.firstWhere(
        (product) => product.id == purchaseDetails.productID,
        orElse: () => null,
      );
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          emit(PurchasePending());
          break;
        case PurchaseStatus.purchased:
          try {
            final String userId = (purchaseDetails as dynamic)?.skPaymentTransaction?.payment?.applicationUsername?.toString();
            final UserResponse user = await PurchaseRepository.create(purchaseDetails, productDetails, userId);
            emit(PurchaseSuccess(user: user));
          } catch (e) {
            emit(FailureState(exception: e));
          }
          break;
        case PurchaseStatus.restored:
          break;
        case PurchaseStatus.error:
          emit(FailureState());
          break;
        default:
          break;
      }

      if (purchaseDetails.pendingCompletePurchase && purchaseDetails.status != PurchaseStatus.restored) {
        await inAppPurchase.completePurchase(purchaseDetails);
      }
    });
  }

  Future<List<ProductDetails>> getProducts(Set<String> productIds) async {
    final ProductDetailsResponse response = await inAppPurchase.queryProductDetails(productIds);
    return response.productDetails;
  }

  Future<void> subscribe(Plan plan, String userId) async {
    emit(SubscriptionContentLoading());
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
    try {
      inAppPurchase
          .buyNonConsumable(
        purchaseParam: purchaseParam,
      )
          .catchError((exception) {
        final PurchaseDetails purchaseDetails =
            PurchaseDetails(productID: product.id, status: PurchaseStatus.canceled, transactionDate: null, verificationData: null);
        inAppPurchase.completePurchase(purchaseDetails);
        emit(FailureState(exception: exception));
      });
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      emit(FailureState(exception: exception));
      rethrow;
    }
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
      final DateTime date = DateTime.fromMillisecondsSinceEpoch(
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
