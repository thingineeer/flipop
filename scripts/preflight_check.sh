#!/bin/bash
set -euo pipefail

##############################################################################
# 배포 전 체크리스트 검증 스크립트
# 사용법: ./scripts/preflight_check.sh
#
# Google Play + App Store 출시에 필요한 항목을 모두 확인합니다.
##############################################################################

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

PASS=0
WARN=0
FAIL=0

check_pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASS=$((PASS + 1)); }
check_warn() { echo -e "  ${YELLOW}[WARN]${NC} $1"; WARN=$((WARN + 1)); }
check_fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAIL=$((FAIL + 1)); }

echo ""
echo -e "${CYAN}━━━ FLIPOP 배포 전 체크리스트 ━━━${NC}"
echo ""

# ── 1. 프로젝트 기본 ──

echo -e "${CYAN}[프로젝트 기본]${NC}"

# pubspec.yaml 버전
VERSION=$(grep '^version:' pubspec.yaml | head -1 | sed 's/version: //')
if [ -n "$VERSION" ]; then
    check_pass "앱 버전: $VERSION"
else
    check_fail "pubspec.yaml에 version 없음"
fi

# Flutter analyze
if flutter analyze --no-fatal-infos 2>/dev/null | grep -q "No issues found"; then
    check_pass "Flutter analyze: 이슈 없음"
else
    check_warn "Flutter analyze: 이슈 존재 (확인 필요)"
fi

# Flutter test
if flutter test 2>/dev/null; then
    check_pass "Flutter test: 통과"
else
    check_warn "Flutter test: 일부 실패"
fi

# ── 2. Android ──

echo ""
echo -e "${CYAN}[Android]${NC}"

# Fastlane Appfile
ANDROID_APPFILE="$PROJECT_ROOT/android/fastlane/Appfile"
if [ -f "$ANDROID_APPFILE" ]; then
    KEY_FILE=$(grep json_key_file "$ANDROID_APPFILE" | sed 's/.*"\(.*\)".*/\1/')
    if [ "$KEY_FILE" = "path/to/google-play-service-account.json" ]; then
        check_fail "서비스 계정 JSON 키: 미설정"
    elif [ -f "$KEY_FILE" ]; then
        check_pass "서비스 계정 JSON 키: 설정됨"
    else
        check_fail "서비스 계정 JSON 키: 파일 없음 ($KEY_FILE)"
    fi
else
    check_fail "Android Fastlane Appfile 없음"
fi

# 메타데이터
for locale in ko-KR en-US ja-JP zh-CN; do
    META_DIR="$PROJECT_ROOT/android/fastlane/metadata/android/$locale"
    if [ -f "$META_DIR/full_description.txt" ] && [ -f "$META_DIR/short_description.txt" ]; then
        check_pass "Android 메타데이터 ($locale): 존재"
    else
        check_fail "Android 메타데이터 ($locale): 누락"
    fi
done

# 그래픽 에셋
if [ -f "$PROJECT_ROOT/assets/app_icon_512.png" ]; then
    check_pass "앱 아이콘 (512x512): 존재"
else
    check_fail "앱 아이콘 (512x512): 없음"
fi

if [ -f "$PROJECT_ROOT/assets/feature_graphic_1024x500.png" ]; then
    check_pass "그래픽 이미지 (1024x500): 존재"
else
    check_fail "그래픽 이미지 (1024x500): 없음"
fi

# 스크린샷
PHONE_SHOTS=$(find "$PROJECT_ROOT/android/fastlane/metadata/android/ko-KR/images/phoneScreenshots" -name "*.png" 2>/dev/null | wc -l | tr -d ' ')
if [ "$PHONE_SHOTS" -ge 2 ]; then
    check_pass "Android 스크린샷: ${PHONE_SHOTS}장"
else
    check_warn "Android 스크린샷: ${PHONE_SHOTS}장 (최소 2장 필요)"
fi

# ── 3. iOS ──

echo ""
echo -e "${CYAN}[iOS]${NC}"

# Fastlane
if [ -f "$PROJECT_ROOT/ios/fastlane/Fastfile" ]; then
    check_pass "iOS Fastfile: 존재"
else
    check_fail "iOS Fastfile: 없음"
fi

# 메타데이터
for locale in ko en-US ja zh-Hans; do
    META_DIR="$PROJECT_ROOT/ios/fastlane/metadata/$locale"
    if [ -d "$META_DIR" ]; then
        check_pass "iOS 메타데이터 ($locale): 존재"
    else
        check_warn "iOS 메타데이터 ($locale): 없음"
    fi
done

# iOS 스크린샷
IOS_SHOTS=$(find "$PROJECT_ROOT/ios/fastlane/screenshots" -name "*.png" 2>/dev/null | wc -l | tr -d ' ')
if [ "$IOS_SHOTS" -ge 2 ]; then
    check_pass "iOS 스크린샷: ${IOS_SHOTS}장"
else
    check_warn "iOS 스크린샷: ${IOS_SHOTS}장"
fi

# ── 4. Firebase ──

echo ""
echo -e "${CYAN}[Firebase]${NC}"

if [ -f "$PROJECT_ROOT/firebase.json" ]; then
    check_pass "firebase.json: 존재"
else
    check_warn "firebase.json: 없음"
fi

if [ -f "$PROJECT_ROOT/firestore.rules" ]; then
    check_pass "Firestore 규칙: 존재"
else
    check_warn "Firestore 규칙: 없음"
fi

# ── 5. 개인정보처리방침 ──

echo ""
echo -e "${CYAN}[법적 요건]${NC}"

PRIVACY_URL="https://flipop-game.web.app/privacy-policy.html"
if command -v curl &>/dev/null; then
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$PRIVACY_URL" 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" = "200" ]; then
        check_pass "개인정보처리방침 URL: 접근 가능 ($PRIVACY_URL)"
    else
        check_fail "개인정보처리방침 URL: HTTP $HTTP_CODE ($PRIVACY_URL)"
    fi
else
    check_warn "curl 없음 — 개인정보처리방침 URL 확인 불가"
fi

# ── 결과 요약 ──

echo ""
echo -e "${CYAN}━━━ 체크 결과 ━━━${NC}"
echo -e "  ${GREEN}PASS: $PASS${NC}  ${YELLOW}WARN: $WARN${NC}  ${RED}FAIL: $FAIL${NC}"
echo ""

if [ $FAIL -gt 0 ]; then
    echo -e "${RED}FAIL 항목을 해결한 후 배포를 진행하세요.${NC}"
    exit 1
elif [ $WARN -gt 0 ]; then
    echo -e "${YELLOW}WARN 항목을 확인하세요. 배포는 가능합니다.${NC}"
    exit 0
else
    echo -e "${GREEN}모든 항목 통과! 배포 준비 완료.${NC}"
    exit 0
fi
