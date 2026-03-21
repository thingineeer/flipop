#!/bin/bash
# ================================================
# FLIPOP 자율 개선 루프 — 무한 반복
# ================================================
#
# 사용법:
#   chmod +x scripts/auto-harness.sh
#   ./scripts/auto-harness.sh
#
# 이 스크립트가 하는 일:
#   Claude Code를 반복 호출해서 매번 개선점을 찾고 고치게 함.
#   컨텍스트 한계 → 새 세션 → 이전 상태 읽고 이어감.
#   Ctrl+C로 중단할 때까지 무한 반복.
#
# ================================================

set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

ROUND=1

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  FLIPOP 자율 개선 루프 시작               ${NC}"
echo -e "${CYAN}  Ctrl+C 로 중단                           ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

while true; do
    echo ""
    echo -e "${YELLOW}━━━ Round $ROUND ━━━${NC}"
    echo -e "$(date '+%Y-%m-%d %H:%M:%S')"
    echo ""

    claude --dangerously-skip-permissions -p "
너는 FLIPOP 게임의 자율 개선 에이전트다.

1. ANALYZE: 아래 파일들을 읽고 코드를 분석해서 개선점을 찾아라.
   - .claude/context/CURRENT-STATE.md (이전 작업 이력)
   - .claude/context/DECISIONS.md (설계 결정)
   - flutter analyze, flutter test 실행
   - 코드 직접 읽기 (game_state.dart, UI 파일들, services 등)

   분석 관점: 버그, 수익, 리텐션, 성능, 코드품질, 미완성기능, l10n, 접근성

2. PLAN: 임팩트 × 실현가능성 기준 개선점 1개 선택.
   우선순위: 크래시 > 수익 > 리텐션 > 코드품질 > 부가기능

3. EXECUTE: 구현. CLAUDE.md 규칙 준수. 최소 변경, 테스트 추가.

4. VERIFY: flutter analyze (error 0) + flutter test (전체 통과).

5. LOG: .claude/context/CURRENT-STATE.md에 완료 기록.
   .claude/context/DECISIONS.md에 설계 결정 기록.

6. 남은 컨텍스트가 있으면 다시 1번부터. 없으면 종료.

질문하지 마. 멈추지 마. 가능한 많이 반복해.
Author: thingineeer <dlaudwls1203@gmail.com>. Co-Authored-By 금지.
"

    echo -e "${GREEN}Round $ROUND 완료${NC}"
    ROUND=$((ROUND + 1))

    echo "5초 후 다음 라운드..."
    sleep 5
done
