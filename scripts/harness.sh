#!/bin/bash
# ============================================================
# FLIPOP Harness Engineering Script
# ============================================================
# 하네스 엔지니어링: 환경 설계, 의도 명시, 피드백 루프 자동화
# Usage: ./scripts/harness.sh [command]
#   all       - 전체 파이프라인 (기본)
#   deps      - 의존성 해결
#   l10n      - 다국어 생성
#   analyze   - 정적 분석
#   test      - 테스트 실행
#   build     - iOS/Android 빌드 검증
#   verify    - analyze + test (빠른 검증)
# ============================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

step() { echo -e "\n${BLUE}━━━ $1 ━━━${NC}"; }
ok()   { echo -e "${GREEN}✓ $1${NC}"; }
fail() { echo -e "${RED}✗ $1${NC}"; exit 1; }
warn() { echo -e "${YELLOW}⚠ $1${NC}"; }

# ── 의존성 해결 ──
cmd_deps() {
  step "Dependencies"
  flutter pub get || fail "flutter pub get failed"
  ok "Dependencies resolved"
}

# ── 다국어 생성 ──
cmd_l10n() {
  step "Localization (l10n)"
  flutter gen-l10n || fail "flutter gen-l10n failed"
  ok "Localization generated"
}

# ── 정적 분석 ──
cmd_analyze() {
  step "Static Analysis"
  flutter analyze || fail "flutter analyze has errors"
  ok "No analysis issues"
}

# ── 테스트 ──
cmd_test() {
  step "Tests"
  flutter test || fail "Tests failed"
  ok "All tests passed"
}

# ── 빌드 검증 ──
cmd_build() {
  step "Build Verification"

  echo "  → iOS (no-codesign)..."
  flutter build ios --no-codesign 2>&1 | tail -5
  ok "iOS build succeeded"

  echo "  → Android (debug APK)..."
  flutter build apk --debug 2>&1 | tail -5
  ok "Android build succeeded"
}

# ── 빠른 검증 (analyze + test) ──
cmd_verify() {
  cmd_analyze
  cmd_test
}

# ── 전체 파이프라인 ──
cmd_all() {
  echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║   FLIPOP Harness Pipeline            ║${NC}"
  echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"

  cmd_deps
  cmd_l10n
  cmd_analyze
  cmd_test
  cmd_build

  echo -e "\n${GREEN}╔══════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║   All checks passed!                 ║${NC}"
  echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
}

# ── 엔트리포인트 ──
COMMAND="${1:-all}"

case "$COMMAND" in
  deps)    cmd_deps ;;
  l10n)    cmd_l10n ;;
  analyze) cmd_analyze ;;
  test)    cmd_test ;;
  build)   cmd_build ;;
  verify)  cmd_verify ;;
  all)     cmd_all ;;
  *)
    echo "Usage: $0 {all|deps|l10n|analyze|test|build|verify}"
    exit 1
    ;;
esac
