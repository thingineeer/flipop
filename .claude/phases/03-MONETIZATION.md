# Phase 3: 수익화 전략 강화

> **목표**: 월 $50 수익 달성 (DAU 200~300 기준)
> **핵심 파일**: `lib/services/ad_service.dart`, 신규 IAP 서비스, `lib/ui/game_over_overlay.dart`
> **의존**: Phase 1, 2 완료 후

---

## 현재 수익 구조

| 광고 유형 | 구현 상태 | 문제 |
|-----------|----------|------|
| 배너 (320×50) | MainScreen 하단 상시 | eCPM 낮음, 위치 최적화 안됨 |
| 인터스티셜 | 게임오버 3회마다 | 빈도 너무 낮음, 사용자 이탈 유발 |
| 리워드 | 3종 (부활/시간/점수2배) | 1회 제한, 동기 부여 약함 |
| App Open | 포그라운드 복귀 시 | OK |

**예상 현재 월 수익 (DAU 100 기준): ~$5**

---

## 목표 수익 구조 ($50/월)

### A. 광고 최적화 ($35/월)

#### A-1. 배너 광고 개선
```
현재: 320×50 고정 하단
변경:
  - 적응형 배너 (Adaptive Banner) 사용 → eCPM 30~50% 향상
  - 게임 화면에서는 숨김 (게임 집중도 향상 → 세션 길이 증가)
  - 리더보드/설정 화면에서만 표시
목표: $8/월
```

#### A-2. 인터스티셜 최적화
```
현재: 3회 게임오버마다
변경:
  - 2회 게임오버마다 (빈도 증가)
  - 단, "자연스러운 break" 타이밍에만 (게임오버 결과 확인 후)
  - 연속 2회 표시 금지 (최소 1게임 간격)
  - 첫 3게임은 표시 안 함 (온보딩 보호)
목표: $12/월
```

#### A-3. 리워드 광고 강화
```
현재: 게임당 1회, 3종택1
변경:
  - 게임당 최대 2회로 확대
  - 리워드 종류 추가:
    1. 부활 (30초 + 상단줄 클리어) — 유지
    2. 시간 +30초 — 유지
    3. 점수 2배 — 유지
    4. [신규] "힌트 폭탄" — 최적의 탭 위치 3곳 표시
    5. [신규] "색 변환" — 랜덤 블록 5개를 원하는 색으로
  - 게임 외 리워드:
    6. 매일 첫 리워드 광고 → "데일리 보너스" (아바타 해금 포인트)
목표: $15/월
```

### B. IAP (인앱 결제) ($15/월)

#### B-1. 광고 제거 ($2.99/회)
```
구현:
  - 비소모품 (Non-consumable)
  - 배너, 인터스티셜 제거
  - 리워드 광고는 유지 (사용자 선택)
  - StoreKit 2 (iOS) + Google Play Billing (Android)

필요 파일:
  - lib/services/iap_service.dart (신규)
  - lib/domain/entities/purchase.dart (신규)

예상: 월 5명 구매 = $15 → 보수적으로 $10/월
```

#### B-2. 코스메틱 아이템 팩 ($0.99~$1.99)
```
구현:
  - 아바타 언락 팩 (특별 캐릭터 4종)
  - 블록 스킨 팩 (네온, 파스텔, 모노크롬)
  - 소모품 아님 — 한번 구매하면 영구

현재 avatar_data.dart에 이미 12종 정의됨 (dragon, unicorn, phoenix, robot 등)
  → 이를 IAP 해금 아이템으로 활용

예상: 월 5명 × $0.99 = $5/월
```

---

## 구현 상세

### 신규: `lib/services/iap_service.dart`

```dart
// 싱글톤 패턴 (기존 서비스와 동일)
// 의존성: in_app_purchase 패키지
//
// 기능:
// - 상품 목록 조회
// - 구매 처리 (영수증 검증은 서버사이드 — Cloud Functions)
// - 구매 상태 확인 (광고 제거 여부)
// - 구매 복원
//
// 상품 ID:
// - flipop_remove_ads (비소모품)
// - flipop_avatar_pack_special (비소모품)
// - flipop_skin_pack_neon (비소모품)
```

### 신규: `functions/src/verifyPurchase.ts`

```typescript
// Cloud Function: 영수증 검증
// - iOS: App Store Server API v2
// - Android: Google Play Developer API
// - 검증 후 Firestore users/{uid}/purchases 에 기록
```

### 수정: `lib/services/ad_service.dart`

```dart
// 변경 사항:
// 1. IAPService 의존 — 광고 제거 구매 여부 확인
// 2. 인터스티셜 빈도: 3→2 게임오버마다
// 3. 리워드 횟수: 1→2 회/게임
// 4. 적응형 배너 사용
// 5. 게임 중 배너 숨김 로직
```

### 수정: `lib/ui/game_over_overlay.dart`

```dart
// 변경 사항:
// 1. 리워드 옵션 UI 확장 (5종 → 아이콘 그리드)
// 2. "광고 제거" 프로모션 배너 (3게임마다 표시)
// 3. 데일리 보너스 알림
```

### 수정: `pubspec.yaml`

```yaml
# 추가 의존성:
in_app_purchase: ^3.2.0
```

---

## 데일리 보너스 시스템 (리텐션 + 수익)

```
Day 1: 리워드 광고 1회 시청 → 50 코인
Day 2: 리워드 광고 1회 시청 → 75 코인
Day 3: 리워드 광고 1회 시청 → 100 코인 + 랜덤 아바타 조각
Day 7: 리워드 광고 1회 시청 → 200 코인 + 아바타 해금
Day 14: 특별 보상
Day 30: 전설 아바타 해금

코인 용도:
  - 아바타 조각 수집 → 해금
  - 게임 내 파워업 구매 (힌트 1회, 색변환 1회)
  - IAP로도 코인 구매 가능 ($0.99 = 500코인)
```

**구현**: SecureStorage에 연속 출석일/코인 저장, Firestore에 백업.

---

## 구현 순서

```
1. pubspec.yaml — in_app_purchase 추가
2. lib/services/iap_service.dart — IAP 서비스 신규
3. lib/domain/entities/purchase.dart — 구매 엔티티
4. lib/services/ad_service.dart — 광고 최적화 (빈도, 적응형배너, 리워드 확장)
5. lib/ui/game_over_overlay.dart — 리워드 UI 확장
6. lib/ui/game_screen.dart — 게임 중 배너 숨김, 힌트폭탄/색변환 리워드 구현
7. lib/services/daily_bonus_service.dart — 데일리 보너스 (신규)
8. lib/ui/daily_bonus_dialog.dart — 데일리 보너스 UI (신규)
9. functions/src/verifyPurchase.ts — 영수증 검증 (신규)
10. l10n — 4개 언어 업데이트
11. flutter gen-l10n
12. flutter analyze + flutter test
```

---

## $50/월 달성 시나리오

```
전제: DAU 250명, 일 세션 3회

배너:    250 × 3 × 0.35 (view rate) × $2 eCPM / 1000 = $0.53/일 → $16/월
인터스티셜: 250 × 1.5 (게임/세션) × 0.5 (2게임당1) × $5 eCPM / 1000 = $0.94/일 → $28/월
리워드:  250 × 0.3 (시청률) × $10 eCPM / 1000 = $0.75/일 → $23/월

IAP:     월 3명 × $2.99 (광고제거) = $9/월
         월 3명 × $0.99 (코스메틱) = $3/월

총계: $79/월 (보수적 70% 적용 → $55/월)
```

---

## 주의사항

- **Apple 심사 가이드라인 준수**: 리워드 광고는 "보상을 주는 선택적 광고"로 명확히
- **Google Play 정책**: 인터스티셜은 "자연스러운 전환점"에만
- **첫 3게임은 광고 없음**: 온보딩 보호
- **광고 제거 구매자**: 배너+인터스티셜만 제거, 리워드는 선택 유지
- **COPPA 준수**: 아동 대상이 아님을 명시 (파스텔 톤이지만 전 연령)
