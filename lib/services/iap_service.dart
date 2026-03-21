import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'secure_storage_service.dart';

/// 인앱 결제 서비스 (싱글톤)
class IAPService {
  static final IAPService _instance = IAPService._();
  factory IAPService() => _instance;
  IAPService._();

  // 상품 ID
  static const String removeAdsId = 'flipop_remove_ads';
  static const String avatarPackId = 'flipop_avatar_pack_special';

  static const Set<String> _productIds = {removeAdsId, avatarPackId};

  // 상태
  bool _adsRemoved = false;
  bool get adsRemoved => _adsRemoved;

  bool _avatarPack = false;
  bool get avatarPack => _avatarPack;

  // 상품 정보
  final Map<String, ProductDetails> _products = {};
  ProductDetails? get removeAdsProduct => _products[removeAdsId];
  ProductDetails? get avatarPackProduct => _products[avatarPackId];

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// 앱 시작 시 호출 — 이전 구매 상태 복원 + 스트림 리스너 등록
  Future<void> initialize() async {
    // 캐시된 구매 상태 복원
    _adsRemoved = await SecureStorageService().getAdsRemoved();
    _avatarPack = await SecureStorageService().getAvatarPack();

    final available = await InAppPurchase.instance.isAvailable();
    if (!available) return;

    // 구매 스트림 리스너
    _subscription = InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdated,
      onDone: () => _subscription?.cancel(),
      onError: (_) {},
    );

    // 상품 정보 조회
    await _queryProducts();
  }

  Future<void> _queryProducts() async {
    final response =
        await InAppPurchase.instance.queryProductDetails(_productIds);
    for (final product in response.productDetails) {
      _products[product.id] = product;
    }
  }

  /// 광고 제거 구매
  Future<bool> purchaseRemoveAds() async {
    final product = _products[removeAdsId];
    if (product == null) return false;

    final purchaseParam = PurchaseParam(productDetails: product);
    return InAppPurchase.instance
        .buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// 아바타 팩 구매
  Future<bool> purchaseAvatarPack() async {
    final product = _products[avatarPackId];
    if (product == null) return false;

    final purchaseParam = PurchaseParam(productDetails: product);
    return InAppPurchase.instance
        .buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// 구매 복원
  Future<void> restorePurchases() async {
    await InAppPurchase.instance.restorePurchases();
  }

  /// 구매 스트림 콜백
  void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchase in purchaseDetailsList) {
      _handlePurchase(purchase);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    if (purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored) {
      // 구매 완료 처리
      if (purchase.productID == removeAdsId) {
        _adsRemoved = true;
        await SecureStorageService().setAdsRemoved(true);
      } else if (purchase.productID == avatarPackId) {
        _avatarPack = true;
        await SecureStorageService().setAvatarPack(true);
      }
    }

    if (purchase.pendingCompletePurchase) {
      await InAppPurchase.instance.completePurchase(purchase);
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
