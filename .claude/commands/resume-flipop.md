# FLIPOP 세션 재개

이전 세션의 컨텍스트를 복구하고 작업을 이어서 진행합니다.

## 실행 순서

1. **프로젝트 문서 확인**: `CLAUDE.md`, `ARCHITECTURE.md`를 읽어 아키텍처 규칙과 개발 규칙을 확인하세요.

2. **메모리 로드**: 아래 auto memory 디렉토리에서 모든 `.md` 파일을 읽으세요. 경로가 존재하지 않으면 건너뛰세요.
   - `~/.claude/projects/*/memory/` (glob으로 현재 프로젝트 매칭)

3. **현재 상태 파악**:
   - `git log --oneline -15` 로 최근 커밋 히스토리 확인
   - `git status` 로 uncommitted 변경 확인
   - `git branch -a` 로 브랜치 상태 확인
   - `flutter analyze` 로 현재 코드 상태 확인
   - `flutter test` 로 테스트 통과 여부 확인

4. **핵심 파일 맵 (바로 참조용)**:
   ```
   lib/di/service_locator.dart          — 수동 DI
   lib/domain/                          — entities, repositories, failures
   lib/data/                            — Firebase 구현체, datasources
   lib/services/auth_service.dart       — facade 패턴 (기존 UI 호환)
   lib/services/leaderboard_service.dart — 리더보드 + Cloud Function 호출
   lib/ui/main_screen.dart              — 탭 네비게이션 (게임/리더보드/더보기)
   lib/ui/game_screen.dart              — 메인 게임 화면 + START 오버레이
   lib/ui/leaderboard_screen.dart       — 리더보드 (전체/국가 필터)
   lib/ui/more_screen.dart              — 프로필/소셜연동/계정관리
   lib/main.dart                        — AuthGate 라우팅
   functions/src/index.ts               — Cloud Functions (onUserDeleted + submitScore)
   test/                                — 단위 테스트 (game_state, widget, l10n_sync)
   integration_test/                    — E2E 테스트 (game_flow_test.dart)
   ```

5. **배포 정보**:
   - iOS: `cd ios && fastlane beta` (TestFlight) — API Key: G97L8T2XA8, Issuer: e5ea7eb2-038f-46e0-91c7-719bb0c07b2e
   - Android: `cd android && fastlane internal` (내부 테스트) — 또는 Play Console 수동 업로드
   - Firebase: `firebase deploy --only functions,firestore`
   - E2E: `flutter test integration_test/game_flow_test.dart -d <device_id>`

6. **사용자에게 보고**: 현재 상태를 간략히 요약하고, "다음 작업 후보" 목록을 제시하며, 어떤 작업을 진행할지 물어보세요.

## 주의사항
- CLAUDE.md의 모든 규칙 (커밋 정책, 코드 규칙 등) 준수
- Clean Architecture + SOLID 원칙 유지
- 한국어 기반 대화, 기술 용어는 영어 그대로
- 배너 광고 넣지 말 것 (인터스티셜+리워드 유지)
- 게임 시작 시 항상 START 오버레이 먼저
- leaderboard 직접 쓰기 차단됨 — Cloud Function (submitScore) 통해서만 점수 제출
- 하네스 엔지니어링 원칙 적용: Research → Plan → Execute → Verify 루프
