#!/bin/bash
set -euo pipefail

##############################################################################
# iOS TestFlight 빌드 + 업로드 스크립트
# 사용법: ./scripts/deploy_ios_testflight.sh
#
# 사전 조건:
#   1. Xcode + 유효한 Apple Developer 인증서
#   2. fastlane 설치 (gem install fastlane)
#   3. App Store Connect API 키 또는 Apple ID 인증
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
for cmd in flutter xcodebuild; do
    if ! command -v "$cmd" &>/dev/null; then
        log_error "'$cmd'이(가) 설치되어 있지 않습니다."
        exit 1
    fi
done

log_info "=========================================="
log_info "iOS TestFlight 배포 시작"
log_info "$(date '+%Y-%m-%d %H:%M:%S')"
log_info "=========================================="

# 1. Flutter clean + build
log_info "Flutter clean..."
flutter clean

log_info "Flutter pub get..."
flutter pub get

log_info "Flutter build iOS (release)..."
flutter build ios --release

log_ok "Flutter iOS 빌드 완료"

# 2. Fastlane beta (archive + TestFlight 업로드)
log_info "Fastlane beta 실행 (Archive + TestFlight 업로드)..."
cd "$PROJECT_ROOT/ios"
bundle exec fastlane beta

log_ok "=========================================="
log_ok "iOS TestFlight 배포 완료!"
log_ok "=========================================="
log_info "App Store Connect에서 빌드를 확인하세요."
log_info "  https://appstoreconnect.apple.com/apps/6760455756/testflight"
