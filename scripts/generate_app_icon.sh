#!/usr/bin/env bash
#
# FlipOp 앱 아이콘 생성 래퍼 스크립트
# 사용법: ./scripts/generate_app_icon.sh
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PYTHON_SCRIPT="${SCRIPT_DIR}/generate_app_icon.py"

echo "=== FlipOp App Icon Generator ==="
echo ""

# Python 확인
if ! command -v python3 &> /dev/null; then
    echo "Error: python3이 설치되어 있지 않습니다."
    exit 1
fi

# Pillow 설치 확인
if ! python3 -c "import PIL" 2>/dev/null; then
    echo "Pillow가 설치되어 있지 않습니다. 설치 중..."
    pip3 install Pillow
    echo ""
fi

# Python 스크립트 실행
python3 "${PYTHON_SCRIPT}"
