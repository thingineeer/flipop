---
name: resume-flipop
description: Resume FLIPOP Flutter game session — restore context, check code health, and brief current state.
disable-model-invocation: true
---

# FLIPOP 세션 재개

이전 세션의 컨텍스트를 복구하고 작업을 이어서 진행합니다.

## 실행 순서

1. **메모리 로드**: `.claude/projects/-Users-imyeongjin-Desktop-flipop/memory/` 의 모든 메모리 파일을 읽어 현재 프로젝트 상태, 사용자 선호도, 피드백을 파악하세요.

2. **프로젝트 문서 확인**: `CLAUDE.md`, `ARCHITECTURE.md`를 읽어 아키텍처 규칙과 개발 규칙을 확인하세요.

3. **현재 상태 파악**:
   - `git log --oneline -15` 로 최근 커밋 히스토리 확인
   - `git status` 로 uncommitted 변경 확인
   - `flutter analyze` 로 현재 코드 상태 확인

4. **핵심 파일 맵 (바로 참조용)**:
   ```
   lib/di/service_locator.dart          — 수동 DI
   lib/domain/                          — entities, repositories, failures
   lib/data/                            — Firebase 구현체, datasources
   lib/services/auth_service.dart       — facade 패턴 (기존 UI 호환)
   lib/ui/main_screen.dart              — 탭 네비게이션 (게임/리더보드/더보기)
   lib/ui/game_screen.dart              — 메인 게임 화면 + START 오버레이
   lib/ui/more_screen.dart              — 프로필/소셜연동/계정관리
   lib/main.dart                        — AuthGate 라우팅
   functions/src/index.ts               — Cloud Functions
   ```

5. **사용자에게 보고**: 현재 상태를 간략히 요약하고, 메모리에서 파악한 "다음 작업 후보" 목록을 제시하며, 어떤 작업을 진행할지 물어보세요.

## 주의사항
- CLAUDE.md의 모든 규칙 (커밋 정책, 코드 규칙 등) 준수
- Clean Architecture + SOLID 원칙 유지
- 한국어 기반 대화, 기술 용어는 영어 그대로
- 배너 광고 넣지 말 것 (인터스티셜+리워드 유지)
- 게임 시작 시 항상 START 오버레이 먼저
