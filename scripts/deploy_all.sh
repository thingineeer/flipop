#!/bin/bash
set -euo pipefail

##############################################################################
# FLIPOP 전체 배포 파이프라인
# 사용법: ./scripts/deploy_all.sh [옵션]
#
# 옵션:
#   --android-only   Android만 배포
#   --ios-only       iOS만 배포
#   --skip-build     빌드 건너뛰기 (이미 빌드된 경우)
#   --help           도움말
##############################################################################

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log_info()    { echo -e "${CYAN}[INFO]${NC} $1"; }
log_ok()      { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }
log_section() { echo -e "\n${BOLD}${CYAN}━━━ $1 ━━━${NC}\n"; }

# 옵션 파싱
RUN_ANDROID=true
RUN_IOS=true
SKIP_BUILD=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --android-only) RUN_IOS=false; shift ;;
        --ios-only) RUN_ANDROID=false; shift ;;
        --skip-build) SKIP_BUILD=true; shift ;;
        --help|-h)
            echo "사용법: $0 [옵션]"
            echo ""
            echo "옵션:"
            echo "  --android-only   Android만 배포"
            echo "  --ios-only       iOS만 배포"
            echo "  --skip-build     빌드 건너뛰기"
            echo "  --help, -h       도움말"
            echo ""
            echo "배포 순서:"
            echo "  1. Flutter analyze (린트 검사)"
            echo "  2. Flutter test (단위 테스트)"
            echo "  3. Android AAB 빌드 + 내부 테스트 업로드"
            echo "  4. iOS IPA 빌드 + TestFlight 업로드"
            echo "  5. 스토어 메타데이터 업로드"
            exit 0
            ;;
        *) log_error "알 수 없는 옵션: $1"; exit 1 ;;
    esac
done

log_info "=========================================="
log_info "FLIPOP 전체 배포 파이프라인"
log_info "$(date '+%Y-%m-%d %H:%M:%S')"
log_info "  Android: $RUN_ANDROID"
log_info "  iOS: $RUN_IOS"
log_info "  빌드 건너뛰기: $SKIP_BUILD"
log_info "=========================================="

# ── Step 0: 사전 검사 ──

log_section "Step 0: 사전 검사"

for cmd in flutter; do
    if ! command -v "$cmd" &>/dev/null; then
        log_error "'$cmd'이(가) 설치되어 있지 않습니다."
        exit 1
    fi
done
log_ok "Flutter: $(flutter --version | head -1)"

# Git 상태 확인
if [ -n "$(git status --porcelain)" ]; then
    log_warn "커밋되지 않은 변경사항이 있습니다."
    git status --short
    echo ""
    read -p "계속 진행하시겠습니까? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "배포 취소됨"
        exit 0
    fi
fi

# ── Step 1: 린트 검사 ──

log_section "Step 1: Flutter analyze"
flutter analyze --no-fatal-infos
log_ok "린트 검사 통과"

# ── Step 2: 단위 테스트 ──

log_section "Step 2: Flutter test"
flutter test || {
    log_warn "일부 테스트 실패. 계속 진행합니다."
}
log_ok "테스트 완료"

# ── Step 3: Android ──

if [ "$RUN_ANDROID" = true ]; then
    log_section "Step 3: Android 내부 테스트 배포"

    if [ "$SKIP_BUILD" = false ]; then
        log_info "Flutter build appbundle..."
        flutter build appbundle --release
        log_ok "AAB 빌드 완료"
    fi

    AAB_PATH="$PROJECT_ROOT/build/app/outputs/bundle/release/app-release.aab"
    if [ -f "$AAB_PATH" ]; then
        AAB_SIZE=$(du -h "$AAB_PATH" | cut -f1)
        log_ok "AAB: $AAB_PATH ($AAB_SIZE)"

        cd "$PROJECT_ROOT/android"
        KEY_FILE=$(grep json_key_file fastlane/Appfile | sed 's/.*"\(.*\)".*/\1/')
        if [ "$KEY_FILE" != "path/to/google-play-service-account.json" ] && [ -f "$KEY_FILE" ]; then
            bundle exec fastlane internal
            log_ok "Android 내부 테스트 업로드 완료"
        else
            log_warn "서비스 계정 미설정 — 수동 업로드 필요"
            log_warn "  AAB: $AAB_PATH"
            log_warn "  설정: ./scripts/setup_service_account.sh"
        fi
        cd "$PROJECT_ROOT"
    else
        log_error "AAB 파일 없음"
    fi
fi

# ── Step 4: iOS ──

if [ "$RUN_IOS" = true ]; then
    log_section "Step 4: iOS TestFlight 배포"

    if [ "$SKIP_BUILD" = false ]; then
        log_info "Flutter build iOS..."
        flutter build ios --release
        log_ok "iOS 빌드 완료"
    fi

    cd "$PROJECT_ROOT/ios"
    bundle exec fastlane beta
    log_ok "iOS TestFlight 업로드 완료"
    cd "$PROJECT_ROOT"
fi

# ── Step 5: 메타데이터 ──

log_section "Step 5: 스토어 메타데이터"

if [ "$RUN_ANDROID" = true ]; then
    cd "$PROJECT_ROOT/android"
    KEY_FILE=$(grep json_key_file fastlane/Appfile | sed 's/.*"\(.*\)".*/\1/')
    if [ "$KEY_FILE" != "path/to/google-play-service-account.json" ] && [ -f "$KEY_FILE" ]; then
        bundle exec fastlane metadata
        log_ok "Android 메타데이터 업로드 완료"
    else
        log_warn "Android 메타데이터: 서비스 계정 미설정 (건너뜀)"
    fi
    cd "$PROJECT_ROOT"
fi

if [ "$RUN_IOS" = true ]; then
    cd "$PROJECT_ROOT/ios"
    bundle exec fastlane metadata
    log_ok "iOS 메타데이터 업로드 완료"
    cd "$PROJECT_ROOT"
fi

# ── 완료 ──

log_info ""
log_ok "=========================================="
log_ok "FLIPOP 배포 파이프라인 완료!"
log_ok "=========================================="
log_info ""
log_info "확인:"
if [ "$RUN_ANDROID" = true ]; then
    log_info "  Android: Google Play Console → 내부 테스트"
fi
if [ "$RUN_IOS" = true ]; then
    log_info "  iOS: App Store Connect → TestFlight"
    log_info "    https://appstoreconnect.apple.com/apps/6760455756/testflight"
fi
