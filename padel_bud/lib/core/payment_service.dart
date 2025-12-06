import 'package:in_app_purchase/in_app_purchase.dart';

class PaymentService {
  static final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  
  /// Product IDs must match those configured in Google Play Console and App Store Connect
  static const String courtBookingProductId = 'court_booking_25';
  static const String matchAcceptanceProductId = 'match_acceptance_20';

  Future<bool> processPayment({
    required String productId,
    required String description,
  }) async {
    try {
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        throw PaymentException('In-app purchases not available');
      }

      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails({productId});
      
      if (response.notFoundIDs.isNotEmpty) {
        throw PaymentException('Product not found in app store');
      }

      final ProductDetails productDetails = response.productDetails.first;
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      return true;
    } catch (e) {
      throw PaymentException('Payment failed: $e');
    }
  }

  /// Listen to purchase updates
  Stream<List<PurchaseDetails>> get purchaseStream {
    return _inAppPurchase.purchaseStream;
  }

  /// Complete a purchase (mark as consumed for consumable products)
  Future<void> completePurchase(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchase);
    }
  }
}

class PaymentException implements Exception {
  final String message;
  PaymentException(this.message);

  @override
  String toString() => message;
}
