# Phase 8: 소셜 + 바이럴 + 공유

> **목표**: 유저가 자발적으로 앱을 퍼뜨리는 장치 구축
> **KPI**: 공유율 5%+, 초대 전환율 10%+

---

## A. 스코어 공유 카드

게임오버 시 "공유" 버튼 → 커스텀 이미지 생성 → SNS 공유

### 공유 카드 디자인:
```
┌─────────────────────────────┐
│  FLIPOP 로고 (상단 가운데)   │
│                              │
│     🐱  내 아바타 (큼직)     │
│     닉네임                   │
│                              │
│     ⭐ 3,250점 ⭐            │
│     COMBO x7 달성!           │
│                              │
│  "이 점수 깰 수 있어?"       │
│  [앱스토어 QR/딥링크]        │
│                              │
│  2026.03.15                  │
└─────────────────────────────┘
```

### 구현:
```dart
// lib/services/share_service.dart (신규)
// 1. RepaintBoundary로 카드 위젯 → 이미지 캡처
// 2. getTemporaryDirectory()에 PNG 저장
// 3. share_plus로 이미지 + 텍스트 공유
// 4. 딥링크: https://flipop.app/invite?ref={uid} (Firebase Dynamic Links 또는 앱링크)

// lib/ui/share_card_widget.dart (신규)
// - StatelessWidget, 공유용 카드 렌더링
// - 아바타 + 점수 + 콤보 + 날짜 + FLIPOP 브랜딩
// - 배경: 그라데이션 (게임 테마 색)
```

### 공유 트리거:
```
1. 게임오버 화면: "공유" 버튼 (항상 표시)
2. 최고점수 갱신 시: "자랑하기!" 강조 버튼
3. 데일리 챌린지 1위: 자동 공유 제안
4. 업적 달성: 공유 옵션
```

---

## B. 푸시 알림 (Firebase Cloud Messaging)

### 알림 유형:
```
1. 데일리 챌린지 알림 (매일 오전 9시)
   "오늘의 챌린지가 시작됐어요! 🎮"

2. 연속 출석 리마인더 (24시간 미접속 시)
   "코인 보너스가 기다리고 있어요! Day 5 보상 놓치지 마세요"

3. 친구 점수 추월 알림 (향후)
   "[닉네임]님이 당신의 기록을 깼습니다!"
```

### 구현:
```
pubspec.yaml: firebase_messaging 추가
lib/services/notification_service.dart (신규)
  - FCM 토큰 관리
  - 로컬 알림 스케줄링 (flutter_local_notifications)
  - 알림 권한 요청 (첫 게임 완료 후, NOT 앱 시작 시)
  - MoreScreen에서 알림 ON/OFF 토글
```

---

## C. 앱 리뷰 요청

```dart
// in_app_review 패키지 사용
// 타이밍:
// - 5번째 게임 완료 후 (초기 호감 형성 후)
// - 최고점수 갱신 직후 (감정이 가장 긍정적일 때)
// - 3일 연속 접속 후
// - 한 번 요청 후 30일간 재요청 금지
//
// Apple/Google 가이드라인:
// - 연간 3회 제한 (iOS)
// - 커스텀 리뷰 팝업 금지, 네이티브 API만 사용
```

---

## D. 초대 / 레퍼럴 시스템 (간단 버전)

```
플로우:
1. MoreScreen → "친구 초대" 버튼
2. 고유 초대 링크 생성 (uid 기반)
3. share_plus로 링크 공유
4. 초대받은 사람이 앱 설치 + 첫 게임 완료
5. 양쪽 모두 50 코인 보상

기술:
  - Firebase Dynamic Links (deprecated → App Links / Universal Links로 대체)
  - 또는 단순 딥링크 + Firestore에서 ref 추적
  - functions/src/processReferral.ts — 레퍼럴 처리

주의: 복잡한 레퍼럴 시스템은 MVP 이후. 지금은 공유 링크 + 코인만.
```

---

## 구현 순서

```
1. lib/ui/share_card_widget.dart — 공유 카드 위젯
2. lib/services/share_service.dart — 이미지 캡처 + 공유
3. lib/ui/game_over_overlay.dart — 공유 버튼 연결
4. pubspec.yaml — firebase_messaging, flutter_local_notifications, in_app_review
5. lib/services/notification_service.dart — FCM + 로컬 알림
6. lib/ui/more_screen.dart — 알림 토글 + 초대 버튼
7. 앱 리뷰 요청 로직 (5번째 게임/최고점수/3일 연속)
8. l10n — 공유/알림/초대 텍스트 4개 언어
9. flutter gen-l10n
10. flutter analyze + flutter test
11. .claude/context/ 업데이트
```
