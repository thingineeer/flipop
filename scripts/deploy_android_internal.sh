#!/bin/bash
set -euo pipefail

##############################################################################
# Android 내부 테스트 빌드 + 업로드 스크립트
# 사용법: ./scripts/deploy_android_internal.sh
#
# 사전 조건:
#   1. Google Play Console 서비스 계정 JSON 키 파일 필요
#      - android/fastlane/Appfile 의 json_key_file 경로 설정
#   2. flutter, bundletool 설치
#   3. Java 17+ 설치 (AGP 8 요구사항)
##############################################################################

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()  { echo -e "${CYAN}[INFO]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 필수 도구 확인
for cmd in flutter; do
    if ! command -v "$cmd" &>/dev/null; then
        log_error "'$cmd'이(가) 설치되어 있지 않습니다."
        exit 1
    fi
done

log_info "=========================================="
log_info "Android 내부 테스트 배포 시작"
log_info "$(date '+%Y-%m-%d %H:%M:%S')"
log_info "=========================================="

# 1. Flutter clean + build
log_info "Flutter clean..."
flutter clean

log_info "Flutter pub get..."
flutter pub get

log_info "Flutter build appbundle (release)..."
flutter build appbundle --release

AAB_PATH="$PROJECT_ROOT/build/app/outputs/bundle/release/app-release.aab"
if [ ! -f "$AAB_PATH" ]; then
    log_error "AAB 파일을 찾을 수 없습니다: $AAB_PATH"
    exit 1
fi

AAB_SIZE=$(du -h "$AAB_PATH" | cut -f1)
log_ok "AAB 빌드 완료: $AAB_PATH ($AAB_SIZE)"

# 2. Fastlane 내부 테스트 업로드
log_info "Fastlane 내부 테스트 트랙 업로드..."
cd "$PROJECT_ROOT/android"

# 서비스 계정 키 파일 확인
KEY_FILE=$(grep json_key_file fastlane/Appfile | sed 's/.*"\(.*\)".*/\1/')
if [ "$KEY_FILE" = "path/to/google-play-service-account.json" ]; then
    log_warn "======================================================"
    log_warn "서비스 계정 JSON 키 파일이 설정되지 않았습니다!"
    log_warn ""
    log_warn "설정 방법:"
    log_warn "  1. Google Cloud Console → IAM → 서비스 계정 생성"
    log_warn "  2. Google Play Console → API 액세스에서 서비스 계정 연결"
    log_warn "  3. JSON 키 다운로드 후 안전한 위치에 저장"
    log_warn "  4. android/fastlane/Appfile 수정:"
    log_warn "     json_key_file(\"/path/to/your-key.json\")"
    log_warn ""
    log_warn "AAB 파일은 수동으로 업로드 가능:"
    log_warn "  $AAB_PATH"
    log_warn "======================================================"
    exit 0
fi

bundle exec fastlane internal

log_ok "=========================================="
log_ok "Android 내부 테스트 배포 완료!"
log_ok "=========================================="
log_info "Google Play Console에서 내부 테스트를 확인하세요."
