# FLIPOP — Claude Code 작업 지침

> 블록을 탭해서 색을 순환시키고, 가로줄을 같은 색으로 맞추는 캐주얼 퍼즐 게임
> Flutter (Dart) + Firebase + AdMob | 1인 개발

---

## 아키텍처 개요

`ARCHITECTURE.md` 참조. 핵심 레이어:

```
Domain (순수 Dart) → Data (Firebase) → Services (Facade) → UI (Flutter)
```

**불변 규칙**:
- Domain 레이어는 Flutter/Firebase 의존성 금지
- UI에서 Firebase 직접 호출 금지 (Services를 거침)
- GameState는 **불변 객체** — 모든 변환은 새 인스턴스 반환
- 싱글톤 서비스는 `factory` 패턴 사용

---

## 핵심 파일 맵

| 영역 | 파일 | 역할 |
|------|------|------|
| 엔트리 | `lib/main.dart` | App init + AuthGate (화면 분기) |
| 게임 엔진 | `lib/game/game_state.dart` | 불변 게임 상태, 그리드 로직 |
| 게임 비주얼 | `lib/game/game_colors.dart` | 색상 팔레트, 블록 이미지 매핑 |
| Domain | `lib/domain/` | 엔티티, 추상 리포지토리, sealed 에러 |
| Data | `lib/data/` | Firebase 구현체, OAuth 데이터소스 |
| Services | `lib/services/` | AuthService(facade), AdService, LeaderboardService |
| DI | `lib/di/service_locator.dart` | 수동 의존성 주입 |
| UI | `lib/ui/` | 10개 화면/위젯 |
| l10n | `lib/l10n/` | 4개 언어 (ko, en, ja, zh) |
| Functions | `functions/src/index.ts` | onUserDeleted 트리거 |

---

## 문서 구조

```
docs/
├── design-docs/       → 설계 결정 기록
├── exec-plans/        → 실행 계획 (active/ completed/)
├── product-specs/     → 기획서, PRD
├── generated/         → 자동 생성 스키마 등
└── references/        → 외부 참조 자료
```

상세: `docs/PLANS.md`, `docs/DESIGN.md`

---

## 개발 규칙

### Git
- **Author**: `thingineeer <dlaudwls1203@gmail.com>` — 예외 없음
- Co-Authored-By 금지 (AI 관련 문구 절대 포함 금지)
- 커밋 메시지: 한글 또는 conventional commits
- push는 명시적 요청 시에만

### 코드
- `flutter analyze` error 0 유지
- `flutter test` 전체 통과 유지
- 시키지 않은 작업 하지 말 것
- 과도한 리팩토링, 추가 기능 금지

### 배포
- iOS: `cd ios && fastlane beta` (TestFlight)
- Android: `cd android && fastlane internal` (내부 테스트)
- 메타데이터: iOS 4개 언어 (en-US, ko, ja, zh-Hans), Android 4개 (en-US, ko-KR, ja-JP, zh-CN)

### l10n
- 템플릿: `lib/l10n/app_ko.arb`
- `flutter gen-l10n` 후 생성 파일 커밋
- 새 키 추가 시 4개 ARB 모두 업데이트

---

## 게임 메커닉 요약

- **그리드**: 5열 × 7행 (가시 6행 + 버퍼 1행)
- **색 순환**: 탭 → 상하좌우 인접 블록 다음 색으로 (Red→Blue→Yellow→Red)
- **클리어**: 가로줄 같은 색 → POP + 중력 + 연쇄 콤보
- **타이머**: 90초, 콤보 시 보너스 시간
- **게임 오버**: 타이머 만료 또는 그리드 오버플로
- **리워드 광고**: 이어하기(30초 부활), 시간+30초, 점수 2배 — 각 게임당 1회

---

## 자주 실행하는 명령

```bash
flutter analyze                  # 정적 분석
flutter test                     # 전체 테스트
flutter gen-l10n                 # l10n 재생성
flutter run                      # 디버그 실행
cd ios && fastlane beta          # TestFlight 업로드
cd android && fastlane internal  # Play Store 내부 테스트
```
