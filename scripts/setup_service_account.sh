#!/bin/bash
set -euo pipefail

##############################################################################
# Google Play 서비스 계정 설정 가이드
# 사용법: ./scripts/setup_service_account.sh
#
# Fastlane supply를 사용하여 Google Play에 업로드하려면
# 서비스 계정 JSON 키가 필요합니다.
##############################################################################

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()  { echo -e "${CYAN}[INFO]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }

echo ""
log_info "=========================================="
log_info "Google Play 서비스 계정 설정 가이드"
log_info "=========================================="

echo ""
log_info "Step 1: Google Cloud Console에서 서비스 계정 생성"
log_info "  https://console.cloud.google.com/iam-admin/serviceaccounts?project=flipop-game"
log_info "  - '서비스 계정 만들기' 클릭"
log_info "  - 이름: 'fastlane-deploy'"
log_info "  - 역할: '편집자' (Editor)"
log_info "  - JSON 키 생성 후 다운로드"

echo ""
log_info "Step 2: Google Play Console에서 API 액세스 연결"
log_info "  https://play.google.com/console/u/0/developers/5351376807423705889/api-access"
log_info "  - '서비스 계정' 탭에서 위에서 만든 계정 연결"
log_info "  - 권한: '릴리스 관리자' (Release Manager)"

echo ""
log_info "Step 3: JSON 키 파일 저장"
log_info "  - 다운로드한 JSON 파일을 안전한 위치에 저장"
log_info "  - 예: ~/.config/flipop/google-play-key.json"
log_info "  - .gitignore에 추가되어 있는지 확인!"

echo ""
log_info "Step 4: Fastlane Appfile 업데이트"
APPFILE="$PROJECT_ROOT/android/fastlane/Appfile"
log_info "  파일: $APPFILE"
log_info "  변경:"
log_info "    json_key_file(\"~/.config/flipop/google-play-key.json\")"

echo ""
log_info "Step 5: 확인"
log_info "  cd android && bundle exec fastlane run validate_play_store_json_key"

echo ""
# 현재 상태 확인
KEY_FILE=$(grep json_key_file "$APPFILE" | sed 's/.*"\(.*\)".*/\1/')
if [ "$KEY_FILE" = "path/to/google-play-service-account.json" ]; then
    log_warn "현재 상태: 서비스 계정 미설정 (기본값)"
else
    if [ -f "$KEY_FILE" ]; then
        log_ok "현재 상태: 서비스 계정 설정됨 ($KEY_FILE)"
    else
        log_warn "현재 상태: Appfile에 경로 설정됨, 파일 없음 ($KEY_FILE)"
    fi
fi

echo ""
log_info "=========================================="
log_info "설정 완료 후 사용 가능한 명령:"
log_info "  ./scripts/deploy_android_internal.sh  — 내부 테스트 업로드"
log_info "  ./scripts/upload_store_assets.sh       — 메타데이터 업로드"
log_info "=========================================="
