#!/bin/bash
set -euo pipefail

##############################################################################
# 스토어 스크린샷 자동 캡처 스크립트
# - iOS: iPhone 6.7", 6.5", 5.5", iPad Pro 12.9"
# - Android: Phone, 7" Tablet, 10" Tablet
# - 각 디바이스당 2장: 홈 화면, 게임 화면
##############################################################################

# 프로젝트 루트 경로 (스크립트 위치 기준)
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUNDLE_ID="com.thingineeer.flipop"

# 임시 스크린샷 저장 디렉토리
TEMP_DIR="${PROJECT_ROOT}/scripts/.screenshots_tmp"
mkdir -p "$TEMP_DIR"

# iOS 스크린샷 저장 경로 (locale별)
IOS_SCREENSHOT_DIR="${PROJECT_ROOT}/ios/fastlane/screenshots"
IOS_LOCALES=("ko" "en-US" "ja" "zh-Hans")

# Android 스크린샷 저장 경로 (locale별)
ANDROID_SCREENSHOT_DIR="${PROJECT_ROOT}/android/fastlane/metadata/android"
ANDROID_LOCALES=("ko-KR" "en-US" "ja-JP" "zh-CN")

# 스크린샷 대기 시간 (초) — 앱 렌더링 완료까지 기다리는 시간
LAUNCH_WAIT=8
NAVIGATE_WAIT=5

# 색상 출력 헬퍼
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log_info()  { echo -e "${CYAN}[INFO]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

##############################################################################
# 유틸리티 함수
##############################################################################

# 시뮬레이터가 Booted 상태인지 확인
wait_for_boot() {
    local device_id="$1"
    local max_wait=60
    local elapsed=0
    while [ $elapsed -lt $max_wait ]; do
        local state
        state=$(xcrun simctl list devices | grep "$device_id" | grep -o "(Booted)" || true)
        if [ -n "$state" ]; then
            return 0
        fi
        sleep 2
        elapsed=$((elapsed + 2))
    done
    log_error "시뮬레이터 부팅 타임아웃: $device_id"
    return 1
}

# iOS 시뮬레이터 UDID 조회 (이름으로 검색, 가장 최신 런타임 우선)
find_simulator_udid() {
    local device_name="$1"
    # 사용 가능한 디바이스 중 이름이 일치하는 마지막 항목 (최신 런타임)
    xcrun simctl list devices available | grep "$device_name" | \
        grep -oE '[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}' | \
        tail -1
}

# iOS 시뮬레이터 스크린샷 촬영
ios_screenshot() {
    local device_id="$1"
    local output_path="$2"
    xcrun simctl io "$device_id" screenshot --type=png "$output_path"
    log_ok "스크린샷 저장: $output_path"
}

# iOS 스크린샷을 모든 locale 폴더에 복사
copy_ios_to_locales() {
    local src_file="$1"
    local filename="$2"
    for locale in "${IOS_LOCALES[@]}"; do
        local dest_dir="${IOS_SCREENSHOT_DIR}/${locale}"
        mkdir -p "$dest_dir"
        cp "$src_file" "${dest_dir}/${filename}"
        log_info "  -> ${dest_dir}/${filename}"
    done
}

# Android 스크린샷을 모든 locale 폴더에 복사
copy_android_to_locales() {
    local src_file="$1"
    local filename="$2"
    local subfolder="$3"  # phoneScreenshots, sevenInchScreenshots, tenInchScreenshots
    for locale in "${ANDROID_LOCALES[@]}"; do
        local dest_dir="${ANDROID_SCREENSHOT_DIR}/${locale}/images/${subfolder}"
        mkdir -p "$dest_dir"
        cp "$src_file" "${dest_dir}/${filename}"
        log_info "  -> ${dest_dir}/${filename}"
    done
}

##############################################################################
# 디렉토리 초기화
##############################################################################

init_directories() {
    log_info "스크린샷 디렉토리 초기화 중..."

    # iOS locale 디렉토리 생성
    for locale in "${IOS_LOCALES[@]}"; do
        mkdir -p "${IOS_SCREENSHOT_DIR}/${locale}"
    done

    # Android locale 디렉토리 생성
    for locale in "${ANDROID_LOCALES[@]}"; do
        mkdir -p "${ANDROID_SCREENSHOT_DIR}/${locale}/images/phoneScreenshots"
        mkdir -p "${ANDROID_SCREENSHOT_DIR}/${locale}/images/sevenInchScreenshots"
        mkdir -p "${ANDROID_SCREENSHOT_DIR}/${locale}/images/tenInchScreenshots"
    done

    log_ok "디렉토리 초기화 완료"
}

##############################################################################
# iOS 스크린샷 캡처
##############################################################################

# iOS 디바이스 정의: (이름, 파일 프리픽스, 해상도 설명)
# iPhone 6.7" (1290x2796) -> iPhone 16 Pro Max (iPhone 15 Pro Max와 동일 해상도)
# iPhone 6.5" (1284x2778) -> iPhone 14 Plus
# iPhone 5.5" (1242x2208) -> iPhone 8 Plus (없으면 iPhone SE 3rd로 대체)
# iPad Pro 12.9" (2048x2732) -> iPad Pro 13-inch (M4)

capture_ios_screenshots() {
    log_info "=========================================="
    log_info "iOS 스크린샷 캡처 시작"
    log_info "=========================================="

    # 디바이스 목록: "시뮬레이터 이름|파일 프리픽스"
    local devices=(
        "iPhone 16 Pro Max|iphone_67"
        "iPhone 14 Plus|iphone_65"
        "iPhone SE (3rd generation)|iphone_55"
        "iPad Pro 13-inch (M4)|ipad_pro_129"
    )

    # Flutter 앱 빌드 (iOS 시뮬레이터용)
    log_info "Flutter iOS 앱 빌드 중..."
    cd "$PROJECT_ROOT"
    flutter build ios --simulator --no-codesign 2>&1 | tail -5
    log_ok "iOS 빌드 완료"

    for device_entry in "${devices[@]}"; do
        IFS='|' read -r device_name file_prefix <<< "$device_entry"

        log_info "------------------------------------------"
        log_info "디바이스: $device_name ($file_prefix)"
        log_info "------------------------------------------"

        # 시뮬레이터 UDID 조회
        local udid
        udid=$(find_simulator_udid "$device_name")
        if [ -z "$udid" ]; then
            log_warn "시뮬레이터를 찾을 수 없음: $device_name (건너뜀)"
            continue
        fi
        log_info "UDID: $udid"

        # 시뮬레이터 부팅
        log_info "시뮬레이터 부팅 중..."
        xcrun simctl boot "$udid" 2>/dev/null || true
        wait_for_boot "$udid"
        log_ok "시뮬레이터 부팅 완료"

        # 앱 설치
        log_info "앱 설치 중..."
        local app_path
        app_path=$(find "${PROJECT_ROOT}/build/ios/iphonesimulator" -name "*.app" -maxdepth 1 | head -1)
        if [ -z "$app_path" ]; then
            log_error "빌드된 .app 파일을 찾을 수 없습니다."
            xcrun simctl shutdown "$udid" 2>/dev/null || true
            continue
        fi
        xcrun simctl install "$udid" "$app_path"
        log_ok "앱 설치 완료"

        # 앱 실행
        log_info "앱 실행 중..."
        xcrun simctl launch "$udid" "$BUNDLE_ID"
        log_info "${LAUNCH_WAIT}초 대기 (앱 렌더링)..."
        sleep "$LAUNCH_WAIT"

        # 스크린샷 1: 홈/웰컴 화면
        local home_file="${TEMP_DIR}/${file_prefix}_01_home.png"
        log_info "스크린샷 1: 홈 화면 캡처"
        ios_screenshot "$udid" "$home_file"
        copy_ios_to_locales "$home_file" "${file_prefix}_01_home.png"

        # 화면 탭 (게임 시작 유도) — 화면 중앙 탭
        log_info "화면 탭하여 게임 화면으로 이동..."
        # simctl로 탭 이벤트를 보내기 어려우므로, 일정 시간 대기 후 캡처
        # 실제 게임 화면 진입이 필요하면 Flutter integration test 활용 권장
        sleep "$NAVIGATE_WAIT"

        # 스크린샷 2: 게임 화면
        local game_file="${TEMP_DIR}/${file_prefix}_02_game.png"
        log_info "스크린샷 2: 게임 화면 캡처"
        ios_screenshot "$udid" "$game_file"
        copy_ios_to_locales "$game_file" "${file_prefix}_02_game.png"

        # 앱 종료 및 시뮬레이터 종료
        log_info "앱 종료 및 시뮬레이터 종료..."
        xcrun simctl terminate "$udid" "$BUNDLE_ID" 2>/dev/null || true
        xcrun simctl shutdown "$udid" 2>/dev/null || true
        log_ok "$device_name 캡처 완료"
    done

    log_ok "iOS 스크린샷 캡처 완료"
}

##############################################################################
# Android 스크린샷 캡처 (에뮬레이터 + flutter screenshot)
##############################################################################

# Android 에뮬레이터 정의: (AVD 이름|파일 프리픽스|스크린샷 폴더)
# Phone (1080x1920): 기본 Pixel 에뮬레이터
# 7" Tablet (1200x1920): Nexus 7 또는 커스텀 AVD
# 10" Tablet (1600x2560): Pixel Tablet 또는 커스텀 AVD

capture_android_screenshots() {
    log_info "=========================================="
    log_info "Android 스크린샷 캡처 시작"
    log_info "=========================================="

    # 사용 가능한 AVD 목록 확인
    local avd_list
    avd_list=$(emulator -list-avds 2>/dev/null || true)

    if [ -z "$avd_list" ]; then
        log_warn "사용 가능한 Android AVD가 없습니다."
        log_warn "Android Studio에서 에뮬레이터를 먼저 생성해주세요."
        log_warn "권장 AVD:"
        log_warn "  - Phone: Pixel_7 (1080x2400) 또는 Pixel_4 (1080x2280)"
        log_warn "  - 7\" Tablet: Nexus_7_2013 (1200x1920)"
        log_warn "  - 10\" Tablet: Pixel_Tablet (1600x2560)"
        return 0
    fi

    log_info "사용 가능한 AVD 목록:"
    echo "$avd_list" | while read -r avd; do
        log_info "  - $avd"
    done

    # 에뮬레이터 디바이스 매핑
    # 환경에 맞게 AVD 이름을 수정하세요
    local devices=(
        "Pixel_7|phone|phoneScreenshots"
        "Nexus_7_2013|tablet_7|sevenInchScreenshots"
        "Pixel_Tablet|tablet_10|tenInchScreenshots"
    )

    for device_entry in "${devices[@]}"; do
        IFS='|' read -r avd_name file_prefix screenshot_folder <<< "$device_entry"

        # AVD 존재 여부 확인
        if ! echo "$avd_list" | grep -q "$avd_name"; then
            log_warn "AVD를 찾을 수 없음: $avd_name (건너뜀)"
            log_warn "  -> 이름이 다를 수 있습니다. 'emulator -list-avds'로 확인해주세요."
            continue
        fi

        log_info "------------------------------------------"
        log_info "디바이스: $avd_name ($file_prefix)"
        log_info "------------------------------------------"

        # 에뮬레이터 백그라운드 실행
        log_info "에뮬레이터 시작 중: $avd_name"
        emulator -avd "$avd_name" -no-audio -no-boot-anim -no-window &
        local emu_pid=$!

        # 에뮬레이터 부팅 완료 대기
        log_info "에뮬레이터 부팅 대기 중..."
        adb wait-for-device
        local boot_complete=""
        local max_boot_wait=120
        local boot_elapsed=0
        while [ "$boot_complete" != "1" ] && [ $boot_elapsed -lt $max_boot_wait ]; do
            boot_complete=$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r' || true)
            sleep 3
            boot_elapsed=$((boot_elapsed + 3))
        done

        if [ "$boot_complete" != "1" ]; then
            log_error "에뮬레이터 부팅 타임아웃: $avd_name"
            kill $emu_pid 2>/dev/null || true
            continue
        fi
        log_ok "에뮬레이터 부팅 완료"

        # Flutter 앱 설치 및 실행
        log_info "Flutter 앱 설치 및 실행 중..."
        cd "$PROJECT_ROOT"
        flutter run -d emulator --no-hot --no-pub 2>&1 | tail -5 &
        local flutter_pid=$!
        log_info "${LAUNCH_WAIT}초 대기 (앱 렌더링)..."
        sleep "$((LAUNCH_WAIT + 5))"

        # 스크린샷 1: 홈/웰컴 화면
        local home_file="${TEMP_DIR}/${file_prefix}_01_home.png"
        log_info "스크린샷 1: 홈 화면 캡처"
        flutter screenshot --out="$home_file" 2>/dev/null || \
            adb exec-out screencap -p > "$home_file"
        log_ok "스크린샷 저장: $home_file"
        copy_android_to_locales "$home_file" "${file_prefix}_01_home.png" "$screenshot_folder"

        # 게임 화면으로 이동 대기
        log_info "게임 화면 전환 대기 (${NAVIGATE_WAIT}초)..."
        sleep "$NAVIGATE_WAIT"

        # 스크린샷 2: 게임 화면
        local game_file="${TEMP_DIR}/${file_prefix}_02_game.png"
        log_info "스크린샷 2: 게임 화면 캡처"
        flutter screenshot --out="$game_file" 2>/dev/null || \
            adb exec-out screencap -p > "$game_file"
        log_ok "스크린샷 저장: $game_file"
        copy_android_to_locales "$game_file" "${file_prefix}_02_game.png" "$screenshot_folder"

        # Flutter 프로세스 종료
        kill $flutter_pid 2>/dev/null || true
        wait $flutter_pid 2>/dev/null || true

        # 에뮬레이터 종료
        log_info "에뮬레이터 종료 중..."
        adb emu kill 2>/dev/null || true
        kill $emu_pid 2>/dev/null || true
        wait $emu_pid 2>/dev/null || true
        sleep 3
        log_ok "$avd_name 캡처 완료"
    done

    log_ok "Android 스크린샷 캡처 완료"
}

##############################################################################
# 결과 요약
##############################################################################

print_summary() {
    log_info "=========================================="
    log_info "스크린샷 캡처 결과 요약"
    log_info "=========================================="

    log_info ""
    log_info "[iOS 스크린샷]"
    for locale in "${IOS_LOCALES[@]}"; do
        local dir="${IOS_SCREENSHOT_DIR}/${locale}"
        local count
        count=$(find "$dir" -name "*.png" 2>/dev/null | wc -l | tr -d ' ')
        log_info "  ${locale}: ${count}장 — ${dir}"
    done

    log_info ""
    log_info "[Android 스크린샷]"
    for locale in "${ANDROID_LOCALES[@]}"; do
        local base="${ANDROID_SCREENSHOT_DIR}/${locale}/images"
        local phone_count tablet7_count tablet10_count
        phone_count=$(find "$base/phoneScreenshots" -name "*.png" 2>/dev/null | wc -l | tr -d ' ')
        tablet7_count=$(find "$base/sevenInchScreenshots" -name "*.png" 2>/dev/null | wc -l | tr -d ' ')
        tablet10_count=$(find "$base/tenInchScreenshots" -name "*.png" 2>/dev/null | wc -l | tr -d ' ')
        log_info "  ${locale}: Phone ${phone_count}장, 7\" ${tablet7_count}장, 10\" ${tablet10_count}장"
    done

    log_info ""
    log_info "임시 파일 위치: ${TEMP_DIR}"
    log_info "임시 파일을 삭제하려면: rm -rf ${TEMP_DIR}"
}

##############################################################################
# 클린업 핸들러
##############################################################################

cleanup() {
    log_warn "스크립트 중단됨. 실행 중인 시뮬레이터/에뮬레이터 종료 중..."
    # 부팅된 iOS 시뮬레이터 종료
    xcrun simctl shutdown all 2>/dev/null || true
    # Android 에뮬레이터 종료
    adb emu kill 2>/dev/null || true
    exit 1
}

trap cleanup SIGINT SIGTERM

##############################################################################
# 메인 실행
##############################################################################

main() {
    log_info "=========================================="
    log_info "Flipop 스토어 스크린샷 캡처 시작"
    log_info "$(date '+%Y-%m-%d %H:%M:%S')"
    log_info "=========================================="

    # 필수 도구 확인
    for cmd in flutter xcrun; do
        if ! command -v "$cmd" &>/dev/null; then
            log_error "'$cmd'이(가) 설치되어 있지 않습니다."
            exit 1
        fi
    done

    # 사용법 안내
    local run_ios=true
    local run_android=true

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --ios-only)
                run_android=false
                shift
                ;;
            --android-only)
                run_ios=false
                shift
                ;;
            --help|-h)
                echo "사용법: $0 [옵션]"
                echo ""
                echo "옵션:"
                echo "  --ios-only       iOS 스크린샷만 캡처"
                echo "  --android-only   Android 스크린샷만 캡처"
                echo "  --help, -h       도움말 표시"
                echo ""
                echo "디렉토리 구조:"
                echo "  iOS:     ios/fastlane/screenshots/{ko,en-US,ja,zh-Hans}/"
                echo "  Android: android/fastlane/metadata/android/{locale}/images/{phone,tablet}Screenshots/"
                exit 0
                ;;
            *)
                log_error "알 수 없는 옵션: $1"
                exit 1
                ;;
        esac
    done

    # 디렉토리 초기화
    init_directories

    # iOS 스크린샷 캡처
    if [ "$run_ios" = true ]; then
        capture_ios_screenshots
    fi

    # Android 스크린샷 캡처
    if [ "$run_android" = true ]; then
        capture_android_screenshots
    fi

    # 결과 요약
    print_summary

    log_info ""
    log_ok "모든 스크린샷 캡처 완료!"
}

main "$@"
