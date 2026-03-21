/// 구매 상태 엔티티
class PurchaseState {
  final bool adsRemoved; // 광고 제거 구매 여부
  final bool avatarPack; // 아바타 팩 구매 여부

  const PurchaseState({
    this.adsRemoved = false,
    this.avatarPack = false,
  });
}
