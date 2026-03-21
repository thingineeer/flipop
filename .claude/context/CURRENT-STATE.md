# FLIPOP 현재 상태

## 프로젝트 상태: Phase 1~10 전체 완료

### 코드 상태
- `flutter analyze`: ✅ error 0
- `flutter test`: ✅ 162 tests passed
- Flutter SDK: 3.41.4

---

## Phase 1~10 완료 요약

| Phase | 내용 | 핵심 파일 |
|-------|------|----------|
| 1 | 게임 밸런스 | game_state.dart (2색, 가로3+, 120초, 4단계 난이도) |
| 2 | 온보딩 | tutorial_screen.dart (미니 퍼즐 3개 + 가이디드 첫 게임) |
| 3 | 데일리 보너스 | daily_bonus_service.dart (연속 출석 코인) |
| 4 | 데일리 챌린지 | daily_challenge.dart (시드 기반 5종 챌린지) |
| 5 | ASO | 메타데이터 20개 파일 (4언어 키워드/설명) |
| 확장 | IAP | iap_service.dart (광고 제거 $2.99) |
| 확장 | 챌린지 UI | daily_challenge_screen.dart (4탭 main_screen) |
| 확장 | 특수 블록 | BlockType (잠금/폭탄/무지개/얼음, score 3000+) |
| 6 | 사운드 + 햅틱 | sound_service.dart (13 SE + 음악/효과음 토글) |
| 7 | UI 폴리시 | 다크모드 + 점수 카운팅 + 타이머 그라데이션 + BackdropFilter |
| 8 | 소셜 + 바이럴 | share_service.dart (이미지 카드) + review_service.dart + 초대 |
| 9 | 인프라 | remote_config + crashlytics + analytics + 강제업데이트/점검 |
| 10 | 캐릭터 + 업적 | achievement_service.dart (20개 업적) + achievement_screen/popup |

---

## 전체 신규 파일 목록

### 서비스 (8개)
- `lib/services/sound_service.dart`
- `lib/services/share_service.dart`
- `lib/services/review_service.dart`
- `lib/services/remote_config_service.dart`
- `lib/services/analytics_service.dart`
- `lib/services/daily_bonus_service.dart`
- `lib/services/iap_service.dart`
- `lib/services/achievement_service.dart`

### UI (10개)
- `lib/ui/tutorial_screen.dart`
- `lib/ui/daily_challenge_screen.dart`
- `lib/ui/daily_bonus_dialog.dart`
- `lib/ui/banner_ad_widget.dart`
- `lib/ui/share_card_widget.dart`
- `lib/ui/force_update_screen.dart`
- `lib/ui/maintenance_screen.dart`
- `lib/ui/achievement_screen.dart`
- `lib/ui/achievement_popup.dart`

### Domain (2개)
- `lib/domain/entities/purchase.dart`
- `lib/domain/entities/achievement.dart`

### Game (1개)
- `lib/game/daily_challenge.dart`

### 테스트 (1개)
- `test/daily_challenge_test.dart`

### 에셋
- `assets/sounds/` (13개 placeholder WAV)
- ASO 메타데이터 20개 파일

---

## 게임 현재 수치

| 항목 | 값 |
|------|-----|
| 초기 색상 | 2개 (score < 300) → 3색 → 4색 |
| 가로 클리어 | 연속 3+ |
| 타이머 | 120초 |
| 새줄 빈도 | 5→4→3→2턴 |
| 특수 블록 | score 3000+ (잠금/폭탄/무지개/얼음) |
| 탭 | 4개 (게임/챌린지/랭킹/더보기) |
| 광고 | 배너/인터스티셜/리워드/앱오픈 (IAP로 제거 가능) |
| IAP | 광고 제거 $2.99 |
| 데일리 보너스 | 연속 출석 코인 (리워드 광고) |
| 챌린지 | 5종 (타임어택/제한터치/콤보마스터/스피드런/일반) |
| 사운드 | 13 SE + 음악/효과음 토글 |
| 다크 모드 | 시스템 자동 + 수동 토글 |
| 업적 | 20개 (입문5/숙련5/도전5/소셜3/수집2) |
| 공유 | 이미지 카드 캡처 + SNS 공유 |
| 앱 리뷰 | 5번째 게임/신기록/3일 연속 |
| 인프라 | Remote Config + Crashlytics + Analytics |
| 강제 업데이트 | Remote Config 기반 |
| 점검 모드 | Remote Config 기반 |

---

## 자율 개선 루프 로그

```
2026-03-15 루프1: DailyBonusDialog 연결
  - 무엇을: game_screen initState에서 DailyBonusDialog.showIfAvailable() 호출
  - 왜: 데일리 보너스 시스템이 존재하지만 유저에게 표시되지 않았음
  - 결과: 162 tests, analyze 0

2026-03-15 루프2: initState colorCount 불일치 수정
  - 무엇을: GameState.newGame(colorCount:3) → GameState.newGame() (기본 2색)
  - 왜: Phase 1에서 기본값 2로 변경했지만 initState에서 3으로 오버라이드
  - 결과: 162 tests, analyze 0

2026-03-15 루프3: 온보딩 깜빡임 방지
  - 무엇을: _showOnboarding 초기값 true → false, 로직 반전
  - 왜: 튜토리얼 완료 후 구 온보딩이 async 체크 전에 잠깐 표시
  - 결과: 162 tests, analyze 0

2026-03-15 루프4: 챌린지 추가 시도 리워드 광고
  - 무엇을: 3회 시도 소진 후 "광고 보고 +1회" 버튼 추가
  - 왜: 리워드 광고 수익 포인트 누락, 챌린지 참여 증대
  - 결과: 162 tests, analyze 0

2026-03-15 루프5~6: Analytics 직접 호출 → AnalyticsService 래퍼 통일
  - 무엇을: game_screen/game_over_overlay/more_screen에서 FirebaseAnalytics import 제거
  - 왜: UI→Firebase 직접 의존 위반 (아키텍처 규칙)
  - 결과: 162 tests, UI 레이어에서 Firebase import 0개

2026-03-15 루프7: 업적 조건 테스트 21개 추가
  - 무엇을: test/achievement_test.dart 신규 (20개 업적 조건 + 경계값 테스트)
  - 왜: 업적 서비스에 테스트 커버리지 없음
  - 결과: 183 tests, analyze 0

2026-03-15 루프8: 오픈소스 라이선스 페이지
  - 무엇을: MoreScreen에 showLicensePage() + l10n 4언어
  - 왜: 앱스토어 심사 대비
  - 결과: 183 tests, analyze 0

2026-03-15 루프10: 게임오버 코인 리워드 광고 버튼
  - 무엇을: 게임오버 화면에 "광고 보고 +30 코인" 버튼 추가
  - 왜: 리워드 광고 수익 포인트 누락 (공정성 유지)
  - 결과: 183 tests, analyze 0

2026-03-15 루프11: 첫 3게임 광고 보호
  - 무엇을: 인터스티셜 광고 첫 3게임 스킵 로직 추가
  - 왜: 온보딩 중 광고 표시로 이탈 방지
  - 결과: 183 tests, analyze 0

2026-03-15 루프12: nearCompleteRows 테스트 5개 추가
  - 무엇을: 힌트 시스템 경계값 테스트 (4/5, 5/5, 3/5, 빈행, 다중행)
  - 왜: 핵심 게임 기능에 테스트 없음
  - 결과: 188 tests, analyze 0

2026-03-15 루프13: 블록 이미지 precache
  - 무엇을: AuthGate에서 블록 이미지 12종 미리 캐싱
  - 왜: 첫 렌더링 시 이미지 깜빡임 방지
  - 결과: 188 tests, analyze 0

2026-03-15 루프14: 아바타 팩 IAP UI 연결
  - 무엇을: MoreScreen에 "스페셜 아바타 팩 $1.99" IAP 버튼 + l10n 4언어
  - 왜: avatarPackId가 정의됐지만 구매 UI 없음 (수익 누락)
  - 결과: 188 tests, analyze 0

2026-03-15 루프15: 챌린지 사운드 추가
  - 무엇을: daily_challenge_screen에 탭/클리어/콤보/게임오버 SE 추가
  - 왜: 챌린지 화면만 무음 (일관성 없음)
  - 결과: 188 tests, analyze 0

2026-03-15 루프16: SoundService 초기화 누락 수정
  - 무엇을: main.dart에 SoundService().initialize() 추가
  - 왜: 설정 복원 안 됨 (앱 재시작 시 리셋 버그)
  - 결과: 188 tests, analyze 0

2026-03-15 루프17: 챌린지 Analytics 추가
  - 무엇을: 챌린지 시작/완료 AnalyticsService 이벤트 추가
  - 왜: 챌린지 데이터 수집 안 됨 (수익 최적화 불가)
  - 결과: 188 tests, analyze 0
```
