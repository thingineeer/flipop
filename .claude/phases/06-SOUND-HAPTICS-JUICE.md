# Phase 6: 사운드 + 햅틱 + 주스(Juice)

> **목표**: 탭하는 순간 "기분 좋은 감각"을 만들어 중독성 10배 향상
> **게임 디자인 원칙**: "Juice it or lose it" — 피드백 없는 게임은 죽은 게임
> **핵심 패키지**: `audioplayers`, `flutter/services.dart` (HapticFeedback)

---

## 왜 이것이 1순위인가

현재 FLIPOP은 **시각적으로만** 피드백을 주고 있다.
캐주얼 퍼즐 게임의 중독성 80%는 **사운드 + 진동**에서 온다.
애니팡/캔디크러쉬가 중독적인 이유: 터질 때 "팡!" + 진동 + 화면 흔들림.

---

## 사운드 이펙트 목록

### 필수 SE (8개)

| ID | 트리거 | 설명 | 파일명 |
|----|--------|------|--------|
| se_tap | 블록 탭 | 가볍고 경쾌한 "똑" | tap.wav |
| se_pop | 줄 클리어 | 터지는 "팡!" (피치 올라감) | pop.wav |
| se_combo1 | 콤보 x1 | 기본 클리어음 | combo1.wav |
| se_combo2 | 콤보 x2 | 더 화려한 음 | combo2.wav |
| se_combo3 | 콤보 x3+ | 최고조 클리어음 | combo3.wav |
| se_newrow | 새 줄 추가 | 낮은 "쿵" | newrow.wav |
| se_warning | 30초 이하 | 틱틱 시계 소리 | warning.wav |
| se_gameover | 게임 오버 | 짧은 실패음 | gameover.wav |

### 추가 SE (5개)

| ID | 트리거 | 설명 | 파일명 |
|----|--------|------|--------|
| se_special_bomb | 폭탄 블록 폭발 | "콰과광" | bomb.wav |
| se_special_rainbow | 무지개 블록 활성 | 반짝이는 차임 | rainbow.wav |
| se_special_ice | 얼음 블록 깨짐 | "깨지는" 크리스탈 | ice_break.wav |
| se_bonus_time | 시간 보너스 획득 | 밝은 "띵!" | bonus_time.wav |
| se_perfect | 퍼펙트 클리어 | 팡파레 | perfect.wav |

### BGM (2개)

| ID | 상황 | 설명 | 파일명 |
|----|------|------|--------|
| bgm_game | 게임 플레이 | 경쾌한 루프 (60~90초) | bgm_game.mp3 |
| bgm_menu | 메뉴/로비 | 차분한 루프 | bgm_menu.mp3 |

---

## 사운드 에셋 생성 방법

**무료 사운드**: sfxr (레트로 SE 생성기) 또는 freesound.org CC0
**BGM**: 직접 작곡 어려우면 Pixabay Music (로열티 프리)

```bash
# 에셋 폴더 구조
assets/
├── sounds/
│   ├── tap.wav
│   ├── pop.wav
│   ├── combo1.wav
│   ├── combo2.wav
│   ├── combo3.wav
│   ├── newrow.wav
│   ├── warning.wav
│   ├── gameover.wav
│   ├── bomb.wav
│   ├── rainbow.wav
│   ├── ice_break.wav
│   ├── bonus_time.wav
│   └── perfect.wav
└── music/
    ├── bgm_game.mp3
    └── bgm_menu.mp3
```

**임시 대체**: 사운드 에셋이 없으면 코드만 먼저 구현하고,
placeholder wav (짧은 사인파)를 생성해서 넣어라.
```dart
// dart:typed_data로 간단한 wav 파일 생성 가능
// 또는 flutter_beep 패키지로 시스템 사운드 활용
```

---

## 햅틱 피드백

```dart
import 'package:flutter/services.dart';

// 탭: 가벼운 진동
HapticFeedback.lightImpact();

// 줄 클리어: 중간 진동
HapticFeedback.mediumImpact();

// 콤보 x3+: 강한 진동
HapticFeedback.heavyImpact();

// 게임 오버: 경고 진동
HapticFeedback.vibrate();

// 특수 블록: selection click
HapticFeedback.selectionClick();
```

**주의**: `HapticFeedback`은 Flutter 기본 제공. 추가 패키지 불필요.

---

## 화면 흔들림 (Screen Shake)

줄 클리어 + 콤보 시 화면 살짝 흔들림:

```dart
// game_screen.dart에서 게임 그리드를 Transform으로 감싸기
// AnimationController로 0.3초간 ±3px 흔들림
// 콤보가 높을수록 진폭 증가 (combo × 1.5px)
```

---

## 구현: SoundService (신규)

```dart
// lib/services/sound_service.dart
// 싱글톤 패턴 (기존 서비스와 동일)
//
// 기능:
// - playSE(String id) — 효과음 재생
// - playBGM(String id) — BGM 루프 재생
// - stopBGM() — BGM 정지
// - setMusicVolume(double) — 0.0~1.0
// - setSFXVolume(double) — 0.0~1.0
// - isMusicEnabled / isSFXEnabled — 토글
// - 설정 저장: SecureStorageService 연동
//
// 의존성: audioplayers 패키지
```

---

## 구현 순서

```
1. pubspec.yaml — audioplayers 추가
2. assets/ 폴더에 placeholder 사운드 생성 (dart로 wav 생성 또는 시스템 beep)
3. pubspec.yaml — assets 등록
4. lib/services/sound_service.dart — 사운드 서비스 신규
5. lib/ui/game_screen.dart — 탭/클리어/콤보/게임오버에 SE + 햅틱 연결
6. lib/ui/game_screen.dart — 화면 흔들림 (Screen Shake) 추가
7. lib/ui/more_screen.dart — 음악/효과음 토글 설정 추가
8. l10n — "음악", "효과음" 설정 텍스트 4개 언어
9. flutter gen-l10n
10. flutter analyze + flutter test
11. .claude/context/ 업데이트
```

---

## 검증

- 탭할 때 즉시 SE + 햅틱 발생 (지연 < 50ms)
- 콤보 x3 이상 시 화면 흔들림 체감
- 음악/효과음 토글 즉시 반영
- 설정이 앱 재시작 후에도 유지
