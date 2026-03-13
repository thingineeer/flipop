# FLIPOP Architecture

> 이 문서는 프로젝트의 고수준 아키텍처를 설명합니다.
> 코드에서 자명하지 않은 **설계 결정의 이유(why)**에 집중합니다.
> 새 코드를 작성하기 전에 반드시 읽어주세요.

---

## 전체 구조

```
lib/
├── main.dart                      # 앱 초기화 + AuthGate (화면 라우팅)
├── di/service_locator.dart        # 수동 DI 컨테이너
│
├── domain/                        # 순수 Dart — 외부 의존성 없음
│   ├── entities/app_user.dart     # 유저 value object
│   ├── repositories/auth_repository.dart  # 추상 인터페이스
│   └── failures/auth_failure.dart # sealed class 에러 타입
│
├── data/                          # Firebase 구현
│   ├── repositories/auth_repository_impl.dart
│   └── datasources/
│       ├── google_sign_in_datasource.dart
│       └── apple_sign_in_datasource.dart
│
├── game/                          # 게임 엔진 — Flutter/Firebase 독립
│   ├── game_state.dart            # 불변 게임 상태 + 모든 규칙
│   └── game_colors.dart           # 색상, 이미지 매핑
│
├── services/                      # Facade 패턴 — UI와 Data 사이 중개
│   ├── auth_service.dart          # AuthRepository facade
│   ├── ad_service.dart            # AdMob (인터스티셜 + 리워드)
│   ├── leaderboard_service.dart   # Firestore 리더보드
│   └── secure_storage_service.dart # Keychain/EncryptedPrefs
│
├── ui/                            # 프레젠테이션 레이어
│   ├── welcome_screen.dart        # 3페이지 온보딩 캐러셀 (최초 1회)
│   ├── home_screen.dart           # 메인 진입 화면 (이후 방문)
│   ├── nickname_screen.dart       # 프로필 설정 (아바타, 국가, 닉네임)
│   ├── game_screen.dart           # 메인 게임 플레이 (~840줄)
│   ├── game_over_overlay.dart     # 게임 오버 다이얼로그
│   ├── onboarding_overlay.dart    # 인게임 튜토리얼 (최초 게임 1회)
│   ├── leaderboard_screen.dart    # 글로벌 랭킹
│   ├── settings_screen.dart       # 계정 관리
│   ├── block_widget.dart          # 개별 블록 렌더링
│   └── pop_particle.dart          # POP 파티클 애니메이션
│
└── l10n/                          # 다국어 (ko, en, ja, zh)
    ├── app_ko.arb                 # 템플릿 (한국어)
    └── app_{en,ja,zh}.arb

functions/src/index.ts             # Cloud Functions (onUserDeleted)
```

---

## 레이어 규칙

```
 ┌─────────────────────┐
 │    UI (Flutter)      │  ← StatefulWidget, AnimationController
 ├─────────────────────┤
 │  Services (Facade)   │  ← 싱글톤, UI 친화적 API
 ├─────────────────────┤
 │ Data (Firebase impl) │  ← FirebaseAuth, Firestore, OAuth
 ├─────────────────────┤
 │  Domain (순수 Dart)  │  ← 엔티티, 추상 인터페이스, 에러 타입
 └─────────────────────┘
 ┌─────────────────────┐
 │  Game (순수 Dart)    │  ← 불변 상태, 규칙 엔진 (UI/Firebase 독립)
 └─────────────────────┘
```

**의존성 방향**: 위 → 아래. 절대 역방향 금지.

- `domain/` 은 `dart:core` 외 import 없음
- `game/` 은 `dart:math` 만 사용
- `data/` 는 `domain/` + Firebase SDK 사용
- `services/` 는 `domain/` + `data/` 사용
- `ui/` 는 `services/` + `game/` + Flutter SDK 사용

---

## 핵심 설계 결정

### 1. GameState가 불변인 이유

`GameState`는 `const` 생성자를 가진 불변 클래스입니다. 모든 조작(탭, 클리어, 중력, 콤보)은 **새 GameState 인스턴스를 반환**합니다.

**왜?**
- UI에서 `setState(() { _state = _state.tap(row, col); })` 패턴으로 깔끔한 상태 관리
- 실행 취소(undo) 구현이 필요할 때 이전 상태를 스택에 보관하면 됨
- 테스트에서 입력-출력 검증이 용이 (사이드 이펙트 없음)
- `revive()`, `withScore()`, `withGameOver()` 등 체이닝 가능

### 2. Services가 Facade 패턴인 이유

`AuthService`는 `AuthRepository`를 내부적으로 사용하지만, UI에는 더 간단한 API를 노출합니다. `currentUser`, `nickname`, `avatarId` 등을 캐시하여 UI에서 매번 비동기 호출하지 않아도 됩니다.

**왜?**
- 기존 UI 코드의 수정을 최소화하면서 Clean Architecture 도입
- `AuthService().isSignedIn` 같은 동기 API를 UI에서 바로 사용
- 리포지토리 교체 시 Service만 수정하면 UI 코드는 불변

### 3. 수동 DI (ServiceLocator)

`get_it` 등의 패키지 대신 수동 DI를 선택했습니다.

**왜?**
- 의존성이 `AuthRepository` 1개뿐이라 오버엔지니어링 방지
- "지루한 기술" 원칙: 외부 패키지 하나 줄이면 유지보수 부담 감소
- 타입 안전성 보장 (ServiceLocator 필드가 컴파일 타임에 검증됨)

### 4. sealed class AuthFailure

`sealed class`로 에러 타입을 정의하여 `switch`문에서 exhaustive 검사가 가능합니다.

**왜?**
- `catch (e) { ... }` 대신 타입별 분기 처리 강제
- 새 에러 타입 추가 시 처리하지 않은 곳에서 컴파일 에러 발생
- 사용자에게 보여줄 메시지가 에러 타입에 내장

### 5. 광고 전략

- **인터스티셜**: 게임 오버 직후 1회 (플레이 중 절대 노출 안 함)
- **리워드**: 이어하기, 시간 보너스, 점수 2배 — 각 게임당 1회씩
- 디버그 모드에서는 Google 테스트 광고 ID 사용

**왜?**
- PRD 원칙 "존중하는 광고": 플레이 중 광고 없음
- 리워드는 유저 선택으로만 노출 → 이탈 방지

---

## 화면 흐름

```
앱 시작
  │
  ├─ Firebase 초기화
  ├─ AdMob 초기화
  ├─ ServiceLocator 초기화
  │
  └─ AuthGate (main.dart)
      │
      ├─ 로그인됨 + 프로필 있음 → GameScreen
      ├─ 로그인됨 + 프로필 없음 → NicknameScreen → GameScreen
      ├─ 비로그인 + Welcome 봄 → HomeScreen
      └─ 비로그인 + Welcome 안 봄 → WelcomeScreen
                                      │
                                      ├─ 소셜 로그인 → NicknameScreen
                                      └─ 건너뛰기 → GameScreen
```

---

## Firestore 스키마

### `users/{uid}`
```
{
  nickname: string,
  avatarId: "cat" | "puppy" | "bunny" | "frog",
  countryCode: string (ISO 3166-1 alpha-2),
  createdAt: timestamp,
  updatedAt: timestamp
}
```

### `leaderboard/{uid}`
```
{
  nickname: string,
  avatarId: string,
  bestScore: number,
  countryCode: string?,
  updatedAt: timestamp
}
```

---

## 테스트 전략

- `test/game_state_test.dart`: 게임 엔진 유닛 테스트 (124개)
  - 탭 → 색 순환 검증
  - 줄 클리어 → 점수/콤보 검증
  - 중력, 오버플로, 리바이브 검증
- `test/widget_test.dart`: 앱 시작 스모크 테스트

**테스트 원칙**:
- GameState(순수 로직)은 100% 유닛 테스트
- UI/Firebase 통합 테스트는 추후 추가 예정
- `flutter test`가 CI 게이트
