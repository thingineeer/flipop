# FLIPOP Phase 6~10 병렬 실행 프롬프트

> Phase 6~10을 최대한 병렬로 돌리되, 의존성이 있는 것만 순차 처리한다.

---

## 의존성 맵

```
Phase 6 (사운드/햅틱) ──┐
Phase 7 (UI 폴리시)  ──┼── 서로 독립 → 병렬 가능
Phase 9 (인프라)     ──┘
                         ↓
Phase 8 (소셜/바이럴) ── Phase 7 UI 완료 후 (공유 카드가 게임오버 UI에 의존)
Phase 10 (캐릭터/업적) ── Phase 6, 7 완료 후 (사운드/UI 이펙트 활용)
```

---

## 복붙용 프롬프트 (Claude Code에 붙여넣기)

```
FLIPOP Phase 6~10을 실행한다. 병렬 가능한 작업은 나눠서 처리해.

작업 전 반드시 읽어:
1. .claude/context/CURRENT-STATE.md
2. .claude/context/DECISIONS.md

== 병렬 그룹 A (동시 진행) ==

[에이전트 1: 사운드 엔지니어]
.claude/phases/06-SOUND-HAPTICS-JUICE.md 읽고 구현.
- SoundService 신규 생성
- audioplayers 패키지 추가
- placeholder wav 파일 생성 (dart:typed_data로 사인파 wav)
- 햅틱 피드백 (HapticFeedback) 연결
- 화면 흔들림 (Screen Shake)
- MoreScreen에 음악/효과음 토글
- l10n 4개 언어 업데이트

[에이전트 2: UI 디자이너]
.claude/phases/07-UI-POLISH.md 읽고 구현.
- 블록 탭 피드백 + 플립 애니메이션
- 파티클 12개 + 광선 이펙트
- 중력 바운스 애니메이션
- 게임오버 블러 + 카운팅
- 타이머 그라데이션
- 다크 모드 팔레트 + 토글
- l10n 4개 언어 업데이트

[에이전트 3: 인프라 엔지니어]
.claude/phases/09-INFRA-MONITORING.md 읽고 구현.
- Remote Config 서비스 (game_state 하드코딩 → 동적)
- Crashlytics + Performance 초기화
- Analytics 10개 이벤트 정리
- 강제 업데이트 + 점검 모드 화면
- 개인정보/이용약관 링크
- l10n 4개 언어 업데이트

== 병렬 그룹 B (그룹 A 완료 후) ==

[에이전트 4: 그로스 해커]
.claude/phases/08-SOCIAL-VIRAL.md 읽고 구현.
- 스코어 공유 카드 (RepaintBoundary → PNG → share_plus)
- 게임오버에 공유 버튼 연결
- 푸시 알림 (FCM + flutter_local_notifications)
- 앱 리뷰 요청 (in_app_review)
- MoreScreen에 알림 토글 + 초대 버튼
- l10n 4개 언어 업데이트

[에이전트 5: 게임 디자이너]
.claude/phases/10-CHARACTER-ACHIEVEMENT.md 읽고 구현.
- 아바타 성장 시스템 (12종, 레벨 1~5)
- 업적 시스템 (20개)
- 코인 샵
- avatar_collection_screen, achievement_screen, coin_shop_screen
- MoreScreen 프로필 허브 확장
- l10n 4개 언어 업데이트 (80키+ 대량)

== 전체 완료 후 ==

통합 검증:
- flutter analyze (error 0)
- flutter test (전체 통과)
- 충돌하는 MoreScreen 변경 머지 확인
- l10n 키 중복 없는지 확인
- .claude/context/CURRENT-STATE.md 최종 업데이트
- .claude/context/DECISIONS.md 업데이트

물어보지 말고 Phase 10까지 전부 끝내. 각 Phase마다 flutter analyze + flutter test 확인.
context 파일들은 전체 완료 후 한 번에 업데이트해도 됨.
```

---

## 주의사항

### l10n 충돌 방지
5개 에이전트가 동시에 ARB 파일을 수정하면 충돌한다.
→ 각 에이전트는 **고유 프리픽스**로 키를 생성:
```
Phase 6: sound_*  (sound_music, sound_sfx, ...)
Phase 7: ui_*     (ui_darkMode, ui_theme, ...)
Phase 8: social_* (social_share, social_invite, ...)
Phase 9: infra_*  (infra_update, infra_maintenance, ...)
Phase 10: meta_*  (meta_achievement_*, meta_avatar_*, ...)
```

### MoreScreen 충돌 방지
여러 Phase가 more_screen.dart에 항목을 추가한다.
→ 마지막에 한 번에 정리하는 통합 단계 필요.

### pubspec.yaml 충돌 방지
여러 Phase가 패키지를 추가한다.
→ 그룹 A에서 한 번에 추가:
```yaml
audioplayers: ^6.0.0
google_fonts: ^6.0.0
firebase_remote_config: ^5.0.0
firebase_crashlytics: ^4.0.0
firebase_performance: ^0.10.0
firebase_messaging: ^15.0.0
flutter_local_notifications: ^18.0.0
in_app_review: ^2.0.0
```

---

## 단일 세션이 부족할 때

컨텍스트가 부족해지면:

```
.claude/context/CURRENT-STATE.md 읽어.
남은 Phase부터 이어서 진행해.
물어보지 말고 끝까지.
```
