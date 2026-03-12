#!/bin/bash
set -euo pipefail

##############################################################################
# 스토어 그래픽 에셋 업로드 가이드 + Fastlane 메타데이터 동기화
# 사용법: ./scripts/upload_store_assets.sh
#
# Google Play Console은 이미지 업로드에 서비스 계정 API 또는
# 웹 콘솔 수동 업로드가 필요합니다.
# 이 스크립트는 에셋을 준비하고 Fastlane supply로 업로드를 시도합니다.
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

log_info "=========================================="
log_info "스토어 그래픽 에셋 준비 + 업로드"
log_info "=========================================="

# ── 에셋 파일 확인 ──

ICON_512="$PROJECT_ROOT/assets/app_icon_512.png"
FEATURE_GRAPHIC="$PROJECT_ROOT/assets/feature_graphic_1024x500.png"
ANDROID_LOCALES=("ko-KR" "en-US" "ja-JP" "zh-CN")

# 앱 아이콘 (512x512)
if [ -f "$ICON_512" ]; then
    log_ok "앱 아이콘 (512x512): $ICON_512"
else
    log_error "앱 아이콘 없음: $ICON_512"
    log_info "생성: ./scripts/generate_app_icon.sh"
fi

# 그래픽 이미지 (1024x500)
if [ -f "$FEATURE_GRAPHIC" ]; then
    log_ok "그래픽 이미지 (1024x500): $FEATURE_GRAPHIC"
else
    log_warn "그래픽 이미지 없음: $FEATURE_GRAPHIC"
    log_info "Python으로 생성 시도 중..."
    python3 << 'PYEOF'
from PIL import Image, ImageDraw, ImageFont
import os

img = Image.new('RGBA', (1024, 500), (255, 255, 255, 255))
draw = ImageDraw.Draw(img)

for y in range(500):
    r = int(74 + (255 - 74) * y / 500)
    g = int(144 + (200 - 144) * y / 500)
    b = int(226 + (80 - 226) * y / 500)
    draw.line([(0, y), (1024, y)], fill=(r, g, b, 255))

icon_path = os.path.expanduser("~/Desktop/flipop/assets/app_icon_512.png")
if os.path.exists(icon_path):
    icon = Image.open(icon_path).convert('RGBA')
    icon_resized = icon.resize((200, 200), Image.LANCZOS)
    x = (1024 - 200) // 2
    img.paste(icon_resized, (x, 80), icon_resized)

try:
    font_large = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Bold.ttf", 60)
    font_small = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial.ttf", 28)
except:
    font_large = ImageFont.load_default()
    font_small = ImageFont.load_default()

text = "FLIPOP"
bbox = draw.textbbox((0, 0), text, font=font_large)
tw = bbox[2] - bbox[0]
draw.text(((1024 - tw) // 2, 300), text, fill=(255, 255, 255, 255), font=font_large)

sub = "Tap, Flip & Clear!"
bbox2 = draw.textbbox((0, 0), sub, font=font_small)
tw2 = bbox2[2] - bbox2[0]
draw.text(((1024 - tw2) // 2, 380), sub, fill=(255, 255, 255, 220), font=font_small)

output = os.path.expanduser("~/Desktop/flipop/assets/feature_graphic_1024x500.png")
img.convert('RGB').save(output, 'PNG')
print(f"Created: {output}")
PYEOF
fi

# ── Fastlane 메타데이터 디렉토리에 에셋 복사 ──

log_info ""
log_info "Fastlane 메타데이터 디렉토리에 에셋 복사 중..."

for locale in "${ANDROID_LOCALES[@]}"; do
    IMG_DIR="$PROJECT_ROOT/android/fastlane/metadata/android/${locale}/images"
    mkdir -p "$IMG_DIR"

    # 앱 아이콘
    if [ -f "$ICON_512" ]; then
        cp "$ICON_512" "$IMG_DIR/icon.png"
        log_info "  ${locale}/images/icon.png"
    fi

    # 그래픽 이미지
    if [ -f "$FEATURE_GRAPHIC" ]; then
        cp "$FEATURE_GRAPHIC" "$IMG_DIR/featureGraphic.png"
        log_info "  ${locale}/images/featureGraphic.png"
    fi

    # 스크린샷 디렉토리 생성 (비어있을 수 있음)
    mkdir -p "$IMG_DIR/phoneScreenshots"
done

log_ok "에셋 복사 완료"

# ── 스크린샷 상태 확인 ──

log_info ""
log_info "스크린샷 상태 확인:"
SCREENSHOT_COUNT=0
for locale in "${ANDROID_LOCALES[@]}"; do
    PHONE_DIR="$PROJECT_ROOT/android/fastlane/metadata/android/${locale}/images/phoneScreenshots"
    if [ -d "$PHONE_DIR" ]; then
        COUNT=$(find "$PHONE_DIR" -name "*.png" 2>/dev/null | wc -l | tr -d ' ')
        SCREENSHOT_COUNT=$((SCREENSHOT_COUNT + COUNT))
        log_info "  ${locale}: ${COUNT}장"
    fi
done

if [ "$SCREENSHOT_COUNT" -eq 0 ]; then
    log_warn ""
    log_warn "스크린샷이 없습니다!"
    log_warn "캡처 방법:"
    log_warn "  1. 자동: ./scripts/capture_screenshots.sh --ios-only"
    log_warn "  2. 수동: 시뮬레이터에서 캡처 후 아래 경로에 저장"
    log_warn "     android/fastlane/metadata/android/{locale}/images/phoneScreenshots/"
    log_warn ""
    log_warn "최소 2장의 스크린샷이 필요합니다 (Google Play 요구사항)"
fi

# ── Fastlane supply로 메타데이터 업로드 시도 ──

log_info ""
log_info "Fastlane supply로 메타데이터 업로드 시도..."

cd "$PROJECT_ROOT/android"

# 서비스 계정 키 파일 확인
KEY_FILE=$(grep json_key_file fastlane/Appfile | sed 's/.*"\(.*\)".*/\1/')
if [ "$KEY_FILE" = "path/to/google-play-service-account.json" ]; then
    log_warn "======================================================"
    log_warn "서비스 계정 JSON 키가 설정되지 않았습니다."
    log_warn ""
    log_warn "[수동 업로드 방법]"
    log_warn "Google Play Console → 스토어 등록정보에서 직접 업로드:"
    log_warn ""
    log_warn "  1. 앱 아이콘 (512x512):"
    log_warn "     $ICON_512"
    log_warn ""
    log_warn "  2. 그래픽 이미지 (1024x500):"
    log_warn "     $FEATURE_GRAPHIC"
    log_warn ""
    log_warn "  3. 휴대전화 스크린샷 (최소 2장):"
    log_warn "     ./scripts/capture_screenshots.sh 로 생성"
    log_warn "======================================================"
    exit 0
fi

bundle exec fastlane metadata

log_ok "=========================================="
log_ok "스토어 에셋 업로드 완료!"
log_ok "=========================================="
