#!/usr/bin/env python3
"""
FlipOp 앱 아이콘 생성 스크립트

4개의 캐릭터(cat_red, puppy_blue, bunny_yellow, frog_green)를
2x2 그리드로 배치한 앱 아이콘을 생성합니다.
"""

import os
import sys
from pathlib import Path

try:
    from PIL import Image, ImageDraw
except ImportError:
    print("Error: Pillow 라이브러리가 필요합니다.")
    print("  pip install Pillow")
    sys.exit(1)

# ── 경로 설정 ──
PROJECT_ROOT = Path(__file__).resolve().parent.parent
IMAGES_DIR = PROJECT_ROOT / "assets" / "images"
OUTPUT_DIR = PROJECT_ROOT / "assets"

# ── 캐릭터 파일 (2x2 배치 순서: 좌상, 우상, 좌하, 우하) ──
CHARACTER_FILES = [
    "cat_red.png",      # 좌상
    "puppy_blue.png",   # 우상
    "bunny_yellow.png",  # 좌하
    "frog_green.png",    # 우하
]

# ── 디자인 설정 ──
CANVAS_SIZE = 1024
BG_COLOR = (247, 243, 238)  # #F7F3EE - 게임 배경색
CHAR_SIZE = 380              # 각 캐릭터 크기
GRID_GAP = 24                # 캐릭터 간 간격
CORNER_RADIUS = 180          # 배경 라운드 반경

# ── 출력 크기 ──
OUTPUT_SIZES = {
    "app_icon_1024.png": 1024,  # iOS App Store
    "app_icon_512.png": 512,    # Google Play Store
    "app_icon_192.png": 192,    # Android launcher
}


def create_rounded_mask(size: int, radius: int) -> Image.Image:
    """라운드 코너 마스크를 생성합니다."""
    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle(
        [(0, 0), (size - 1, size - 1)],
        radius=radius,
        fill=255,
    )
    return mask


def load_character(filename: str) -> Image.Image:
    """캐릭터 이미지를 로드하고 RGBA로 변환합니다."""
    path = IMAGES_DIR / filename
    if not path.exists():
        print(f"Error: 캐릭터 이미지를 찾을 수 없습니다 - {path}")
        sys.exit(1)
    img = Image.open(path).convert("RGBA")
    return img


def make_character_circular(img: Image.Image, size: int) -> Image.Image:
    """캐릭터 이미지를 원형으로 크롭합니다."""
    img = img.resize((size, size), Image.LANCZOS)

    # 원형 마스크
    circle_mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(circle_mask)
    draw.ellipse([(0, 0), (size - 1, size - 1)], fill=255)

    # 투명 배경 위에 원형으로 합성
    result = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    result.paste(img, (0, 0), circle_mask)
    return result


def generate_icon() -> Image.Image:
    """1024x1024 앱 아이콘을 생성합니다."""
    # 캔버스 (RGBA)
    canvas = Image.new("RGBA", (CANVAS_SIZE, CANVAS_SIZE), (*BG_COLOR, 255))

    # 캐릭터 로드 및 원형 크롭
    characters = []
    for f in CHARACTER_FILES:
        char_img = load_character(f)
        char_img = make_character_circular(char_img, CHAR_SIZE)
        characters.append(char_img)

    # 2x2 그리드 좌표 계산 (중앙 정렬)
    total_width = CHAR_SIZE * 2 + GRID_GAP
    offset_x = (CANVAS_SIZE - total_width) // 2
    offset_y = (CANVAS_SIZE - total_width) // 2

    positions = [
        (offset_x, offset_y),                              # 좌상
        (offset_x + CHAR_SIZE + GRID_GAP, offset_y),       # 우상
        (offset_x, offset_y + CHAR_SIZE + GRID_GAP),       # 좌하
        (offset_x + CHAR_SIZE + GRID_GAP, offset_y + CHAR_SIZE + GRID_GAP),  # 우하
    ]

    for char_img, pos in zip(characters, positions):
        canvas.paste(char_img, pos, char_img)

    # 라운드 코너 적용
    rounded_mask = create_rounded_mask(CANVAS_SIZE, CORNER_RADIUS)
    final = Image.new("RGBA", (CANVAS_SIZE, CANVAS_SIZE), (0, 0, 0, 0))
    final.paste(canvas, (0, 0), rounded_mask)

    return final


def main():
    print("FlipOp 앱 아이콘 생성 시작...\n")

    icon = generate_icon()
    generated_files = []

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    for filename, size in OUTPUT_SIZES.items():
        output_path = OUTPUT_DIR / filename
        resized = icon.resize((size, size), Image.LANCZOS)
        resized.save(str(output_path), "PNG")
        generated_files.append(str(output_path))
        print(f"  [{size}x{size}] {output_path}")

    print(f"\n생성 완료! ({len(generated_files)}개 파일)")
    print("\n생성된 파일 경로:")
    for f in generated_files:
        print(f"  {f}")


if __name__ == "__main__":
    main()
