# FLIPOP — Claude Code 작업 지침

> 블록을 탭해서 색을 순환시키고, 가로줄을 같은 색으로 맞추는 캐주얼 퍼즐 게임
> Flutter (Dart) + Firebase + AdMob | 1인 개발

---

## 하네스 엔지니어링 프로토콜

**모든 작업은 `.claude/` 디렉토리의 지시서를 따른다.**

### 작업 시작 전 필수 순서:
```
1. cat .claude/context/CURRENT-STATE.md   → 현재 진행 상태 확인
2. cat .claude/context/DECISIONS.md       → 기존 설계 결정 확인
3. cat .claude/HARNESS.md                 → 전체 실행 계획 확인
4. cat .claude/phases/[현재-Phase].md     → 해당 Phase 상세 지시 확인
5. flutter analyze && flutter test        → 코드 건강 상태 확인
```

### 작업 완료 후 필수:
```
1. flutter analyze (error 0)
2. flutter test (전체 통과)
3. .claude/context/CURRENT-STATE.md 업데이트 (완료 사항 기록)
4. .claude/context/DECISIONS.md 업데이트 (설계 결정 기록)
```

### 자체 리뷰 루프:
변경 후 `git diff`로 전체 변경 사항을 리뷰하고, 불필요한 변경이 없는지 확인.
테스트가 깨지면 즉시 수정. 새 기능에는 반드시 테스트 추가.

---

## 아키텍처 (불변)

`ARCHITECTURE.md` 참조. 레이어: `Domain → Data → Services → UI`

**절대 규칙**:
- Domain 레이어: Flutter/Firebase 의존성 금지
- UI: Firebase 직접 호출 금지 (Services 경유)
- GameState: **불변 객체** — 모든 변환은 새 인스턴스 반환
- 싱글톤 서비스: `factory` 패턴

---

## 핵심 파일 맵

| 영역 | 파일 | 역할 |
|------|------|------|
| 엔트리 | `lib/main.dart` | App init + AuthGate |
| 게임 엔진 | `lib/game/game_state.dart` | 불변 게임 상태, 그리드 로직 |
| 게임 비주얼 | `lib/game/game_colors.dart` | 색상 팔레트, 블록 이미지 |
| Domain | `lib/domain/` | 엔티티, 리포지토리, sealed 에러 |
| Data | `lib/data/` | Firebase 구현체 |
| Services | `lib/services/` | Auth/Ad/Leaderboard |
| UI | `lib/ui/` | 10개 화면/위젯 |
| l10n | `lib/l10n/` | 4개 언어 (ko, en, ja, zh) |
| 하네스 | `.claude/` | Phase별 실행 지시서 + 상태 추적 |

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

### l10n
- 템플릿: `lib/l10n/app_ko.arb`
- 새 키 추가 시 **4개 ARB 모두 업데이트** + `flutter gen-l10n`

### 배포
- iOS: `cd ios && fastlane beta`
- Android: `cd android && fastlane internal`

---

## 자주 실행하는 명령

```bash
flutter analyze                  # 정적 분석
flutter test                     # 전체 테스트
flutter gen-l10n                 # l10n 재생성
flutter run                      # 디버그 실행
```
