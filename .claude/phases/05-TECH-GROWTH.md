# Phase 5: 기술 최적화 + 성장

> **목표**: 퍼포먼스 최적화, ASO, 바이럴 장치, 운영 자동화
> **의존**: Phase 1~4 완료 후
> **원칙**: 측정 → 개선 → 측정 반복

---

## A. 퍼포먼스 최적화

### A-1. 렌더링 최적화
```
문제: 5×7 그리드 + 애니메이션 + 파티클 → 저사양 기기 프레임 드롭 가능
해결:
  1. RepaintBoundary 적용 — 각 블록/행 단위 격리
  2. const 위젯 최대 활용 — 변경 안 되는 UI 요소
  3. AnimationController 풀링 — 파티클 효과용
  4. 이미지 에셋 캐싱 — precacheImage 활용

측정: flutter run --profile → DevTools Performance 탭
목표: 60fps 유지 (저사양 기기 포함)
```

### A-2. 앱 크기 최적화
```
현재: 이미지 에셋 (블록 이미지 12종 × 4색)
해결:
  1. WebP 변환 (PNG 대비 30% 감소)
  2. --split-debug-info + --obfuscate (릴리스)
  3. --tree-shake-icons
  4. 사용하지 않는 패키지 제거

목표: 앱 크기 < 30MB
```

### A-3. Firebase 최적화
```
해결:
  1. Firestore 읽기 최소화 — 리더보드 캐싱 (5분 TTL)
  2. 오프라인 지원 — Firestore 로컬 캐시 활성화
  3. Cloud Functions 콜드 스타트 — min_instances=1 (비용 vs 속도)
  4. Analytics 이벤트 정리 — 핵심 이벤트만 (10개 이하)
```

---

## B. ASO (App Store Optimization)

### B-1. 스토어 메타데이터 최적화
```
현재: 4개 언어 메타데이터 존재 (fastlane)
개선:
  1. 키워드 리서치 (각 언어별)
     - ko: 퍼즐게임, 블록게임, 캐주얼, 두뇌, 시간떼우기
     - en: puzzle, block, casual, brain, matching
     - ja: パズル, ブロック, カジュアル, 脳トレ
     - zh: 拼图, 方块, 休闲, 益智
  2. 스크린샷 5장 (각 언어)
     - 1: 게임플레이 핵심
     - 2: 콤보 클리어 순간
     - 3: 캐릭터 컬렉션
     - 4: 데일리 챌린지
     - 5: 리더보드/대결

수정 파일:
  - ios/fastlane/metadata/*/description.txt
  - ios/fastlane/metadata/*/keywords.txt
  - android/fastlane/metadata/*/full_description.txt
  - android/fastlane/metadata/*/short_description.txt
```

### B-2. 앱 이벤트 활용
```
iOS: App Store 인앱 이벤트
  - 주간 데일리 챌린지 하이라이트
  - 시즌 이벤트 (명절, 기념일)

Android: LiveOps 카드
  - 유사 방식
```

---

## C. 바이럴/공유 장치

### C-1. 스코어 공유 카드
```
게임오버 시 "공유" 버튼:
  - 커스텀 이미지 생성 (캔버스 렌더링)
  - 내 캐릭터 + 점수 + 날짜 + FLIPOP 로고
  - SNS 공유 (share_plus 활용)
  - 딥링크 포함 → 앱 설치 유도

구현:
  - lib/services/share_service.dart (신규)
  - lib/ui/share_card_widget.dart (신규)
  - RepaintBoundary → toImage → 파일 저장 → share
```

### C-2. 초대 보상
```
친구 초대 (딥링크):
  - 초대한 사람: 50 코인 + 아바타 조각
  - 초대받은 사람: 첫 게임 리워드 광고 1회 무료
  - Firebase Dynamic Links (또는 대체)

구현:
  - lib/services/referral_service.dart (신규)
  - functions/src/processReferral.ts (신규)
```

---

## D. 운영 자동화

### D-1. Firebase Remote Config
```
서버 사이드 밸런스 조정 (앱 업데이트 없이):
  - 타이머 기본값
  - 새줄 추가 빈도
  - 콤보 보너스 시간
  - 광고 빈도
  - 이벤트 배너 텍스트

구현:
  - lib/services/remote_config_service.dart (신규)
  - game_state.dart에서 하드코딩 상수 → RemoteConfig 참조
```

### D-2. Crashlytics + Performance
```
추가 의존성:
  - firebase_crashlytics
  - firebase_performance

모니터링:
  - 크래시 리포트 자동 수집
  - 게임 로딩 시간 트레이스
  - 광고 로드 성공률 트레이스
```

---

## 구현 순서

```
1. 퍼포먼스 최적화 (RepaintBoundary, 캐싱)
2. 앱 크기 최적화 (WebP, tree-shake)
3. Firebase Remote Config
4. 스코어 공유 카드
5. ASO 메타데이터 업데이트
6. Crashlytics + Performance 추가
7. flutter analyze + flutter test
```
