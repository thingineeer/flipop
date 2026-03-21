# Phase 9: 운영 인프라 + 모니터링

> **목표**: 출시 후 "눈감고도 운영 가능한" 기반 구축
> **원칙**: 앱 업데이트 없이 서버에서 밸런스 조정 가능

---

## A. Firebase Remote Config

앱 업데이트 없이 서버에서 조정 가능한 값들:

```json
{
  "game_initial_timer_seconds": 120,
  "game_add_row_phase_a": 5,
  "game_add_row_phase_b": 4,
  "game_add_row_phase_c": 3,
  "game_add_row_phase_d": 2,
  "game_colors_phase_a": 2,
  "game_colors_phase_b": 3,
  "game_score_phase_a_max": 299,
  "game_score_phase_b_max": 699,
  "combo_bonus_1": 3,
  "combo_bonus_2": 5,
  "combo_bonus_3": 8,
  "combo_bonus_5": 12,
  "ad_interstitial_frequency": 2,
  "ad_show_after_games": 3,
  "reward_max_per_game": 2,
  "daily_bonus_day1_coins": 50,
  "daily_bonus_day7_coins": 200,
  "event_banner_text": "",
  "event_banner_enabled": false,
  "maintenance_mode": false,
  "force_update_version": "1.0.0"
}
```

### 구현:
```
pubspec.yaml: firebase_remote_config 추가
lib/services/remote_config_service.dart (신규)
  - 싱글톤, main.dart에서 초기화
  - fetchAndActivate() + 기본값 세팅
  - game_state.dart에서 하드코딩 상수 → RemoteConfig 참조
  - 12시간마다 자동 갱신 (minimumFetchInterval)
```

---

## B. Crashlytics + Performance

### Crashlytics:
```
pubspec.yaml: firebase_crashlytics 추가
main.dart:
  - FlutterError.onError → Crashlytics 전송
  - PlatformDispatcher.onError → 비동기 에러 캡처
  - 커스텀 키: uid, gameState, score, phase
```

### Performance Monitoring:
```
pubspec.yaml: firebase_performance 추가
커스텀 트레이스:
  - game_load: 게임 화면 로딩 시간
  - ad_load_interstitial: 인터스티셜 로드 시간
  - ad_load_rewarded: 리워드 로드 시간
  - leaderboard_fetch: 리더보드 조회 시간
  - iap_purchase_flow: IAP 결제 완료 시간
```

---

## C. Analytics 이벤트 정리

### 핵심 이벤트 (10개):
```
1. game_start       — {mode: normal|challenge, colors: 2|3|4}
2. game_over        — {score, combo_max, reason, duration, mode}
3. line_clear       — {combo, lines, score_gained}
4. tutorial_complete — {step: 1|2|3, duration}
5. ad_watched       — {type: interstitial|rewarded|banner, placement}
6. iap_purchase     — {product_id, price}
7. daily_bonus_claim — {day_streak, coins_earned}
8. challenge_complete — {type, score, rank}
9. share_score      — {platform, score}
10. app_review_shown — {trigger: 5th_game|new_best|3day_streak}
```

### 유저 프로퍼티:
```
- total_games_played
- best_score
- days_active
- is_premium (광고 제거 구매)
- preferred_language
```

---

## D. 강제 업데이트 + 점검 모드

```dart
// Remote Config에서:
// force_update_version: "1.1.0" → 현재 버전 < 1.1.0이면 업데이트 강제
// maintenance_mode: true → 점검 화면 표시

// lib/ui/force_update_screen.dart (신규)
// lib/ui/maintenance_screen.dart (신규)
// main.dart AuthGate에서 체크
```

---

## E. 개인정보 처리방침 + 이용약관

```
lib/ui/more_screen.dart에서 링크:
  - 개인정보 처리방침 (WebView 또는 외부 URL)
  - 이용약관
  - 오픈소스 라이선스 (showLicensePage())

필요 파일:
  - 웹 호스팅 (Firebase Hosting 또는 GitHub Pages)
  - privacy-policy.html (4개 언어)
  - terms-of-service.html (4개 언어)
```

---

## 구현 순서

```
1. pubspec.yaml — firebase_remote_config, firebase_crashlytics, firebase_performance
2. lib/services/remote_config_service.dart — Remote Config 서비스
3. lib/game/game_state.dart — 하드코딩 상수를 Remote Config 참조로 변경
4. lib/main.dart — Crashlytics + Performance 초기화
5. lib/services/analytics_service.dart (신규 또는 기존 확장) — 10개 이벤트 정리
6. lib/ui/force_update_screen.dart — 강제 업데이트 화면
7. lib/ui/maintenance_screen.dart — 점검 모드 화면
8. lib/ui/more_screen.dart — 개인정보/이용약관/오픈소스 라이선스 링크
9. flutter analyze + flutter test
10. .claude/context/ 업데이트
```
