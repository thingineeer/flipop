# Session State — FLIPOP

## Date
2026-04-01

## Branch
main

## Completed
- [x] Phase 1~10 전체 완료 (게임밸런스/온보딩/데일리보너스/챌린지/ASO/IAP/사운드/UI폴리시/소셜/인프라/캐릭터+업적)
- [x] 자율 개선 루프 1~30 완료 (l10n 완전 적용, analytics 강화, UX 개선)
- [x] l10n 4언어(ko/en/ja/zh) 하드코딩 문자열 전부 키 적용
- [x] Analytics: 광고시청/IAP구매/데일리보너스/챌린지 이벤트 추가
- [x] SoundService 초기화 가드, PopParticle mounted 체크
- [x] 리워드 광고 버튼 항상 표시 (미로딩시 opacity 처리)
- [x] resume command → skills 마이그레이션 완료
- [x] E2E 게임 플로우 테스트 추가
- [x] 188 tests, analyze 0

## In Progress
- 없음

## Remaining
- TestFlight/Play Store 내부 테스트 빌드 배포
- 실기기 QA (사운드, 햅틱, 광고, IAP)
- 앱스토어 심사 제출
- 출시 후 Crashlytics/Analytics 모니터링
- Phase 11+ 검토 (리텐션 데이터 기반)

## Key Files
- CLAUDE.md — 프로젝트 규칙, 아키텍처
- ARCHITECTURE.md — Clean Architecture 레이어 설계
- .claude/context/CURRENT-STATE.md — 루프 1~30 상세 로그
- lib/game/game_state.dart — 게임 엔진 (불변 상태)
- lib/services/ — 8개 서비스 (ad/iap/sound/share/review/remote_config/analytics/achievement)
- lib/ui/ — 10개 화면/위젯

## Notes
- Flutter SDK 3.41.4
- Firebase: Auth + Firestore + Crashlytics + Analytics + Remote Config
- AdMob: 배너/인터스티셜/리워드/앱오픈 (IAP로 제거 가능)
- 에셋: assets/sounds/ (13개 placeholder WAV — 실제 SE 교체 필요)
