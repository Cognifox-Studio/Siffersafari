#!/usr/bin/env python3
"""Convert app PNG art to WebP and report the quality/size trade-off.

The game art in `assets/` ships as large PNGs (43 MB of `assets/images` at the
time of writing). The PNGs are already well optimised, so re-running a PNG
optimiser buys almost nothing - the weight is pixel dimensions and the format.
WebP cuts ~90 % at a quality that is visually indistinguishable on device.

Quality policy (per file, measured, not guessed):

  1. encode at q90 and score the result with PSNR against the original
     (alpha composited over a mid-grey background, alpha channel scored
     separately, so transparent pixels cannot skew the number);
  2. if PSNR < 40 dB, retry at q95;
  3. if it is still below 40 dB, fall back to lossless WebP;
  4. if the WebP is not at least 20 % smaller than the PNG, keep the PNG.

Deliberately skipped: `assets/images/app_icon/`, which is the source image for
`scripts/generate_android_launcher_icons.dart`.

Usage:
    python3 scripts/convert_images_to_webp.py            # convert in place
    python3 scripts/convert_images_to_webp.py --dry-run  # report only

Requires Pillow with WebP support: `pip install Pillow`.
After converting, update the `.png` string references (see docs/ASSET_GUIDE or
run `grep -rn "assets/.*\\.png" lib test`) and delete the source PNGs.
"""

from __future__ import annotations

import argparse
import glob
import math
import os
import sys

try:
    from PIL import Image, ImageChops
except ImportError:  # pragma: no cover - developer setup issue
    sys.exit("Pillow is required: pip install Pillow")

SKIP_DIRS = ("assets/images/app_icon/",)
PSNR_TARGET = 40.0
QUALITY_STEPS = (90, 95)
MIN_SAVING = 0.20


def _psnr(a: Image.Image, b: Image.Image) -> float:
    hist = ImageChops.difference(a, b).histogram()
    n = sum(hist[0:256])
    total = sum(c * v * v for v, c in enumerate(hist[0:256]))
    mse = total / max(n, 1)
    return 99.0 if mse == 0 else 10 * math.log10(255 * 255 / mse)


def _score(src: Image.Image, dec: Image.Image) -> float:
    """PSNR that survives transparency: composite, then score alpha separately."""
    if "A" in src.mode:
        bg = Image.new("RGB", src.size, (127, 127, 127)).convert("RGBA")
        a = Image.alpha_composite(bg, src.convert("RGBA")).convert("RGB")
        b = Image.alpha_composite(bg, dec.convert("RGBA")).convert("RGB")
        return min(
            _psnr(a, b),
            _psnr(src.getchannel("A"), dec.convert("RGBA").getchannel("A")),
        )
    return _psnr(src.convert("RGB"), dec.convert("RGB"))


def convert(path: str, dry_run: bool) -> tuple[int, int, str]:
    src = Image.open(path)
    src = src.convert("RGBA" if "A" in src.mode else "RGB")
    png_bytes = os.path.getsize(path)
    out_path = os.path.splitext(path)[0] + ".webp"

    best: tuple[bytes, str] | None = None

    for quality in QUALITY_STEPS:
        buf = _encode(src, lossless=False, quality=quality)
        dec = _decode(buf)
        if _score(src, dec) >= PSNR_TARGET:
            best = (buf, f"q{quality}")
            break

    if best is None:
        buf = _encode(src, lossless=True, quality=100)
        best = (buf, "lossless")

    data, how = best
    if len(data) > png_bytes * (1 - MIN_SAVING):
        return png_bytes, png_bytes, f"kept PNG ({how} was not smaller)"

    if not dry_run:
        with open(out_path, "wb") as fh:
            fh.write(data)
        os.remove(path)
    return png_bytes, len(data), how


def _encode(img: Image.Image, *, lossless: bool, quality: int) -> bytes:
    import io

    buf = io.BytesIO()
    img.save(
        buf,
        "WEBP",
        lossless=lossless,
        quality=quality,
        method=6,
        alpha_quality=100,
    )
    return buf.getvalue()


def _decode(data: bytes) -> Image.Image:
    import io

    img = Image.open(io.BytesIO(data))
    img.load()
    return img


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true", help="report only")
    args = parser.parse_args()

    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    os.chdir(root)

    paths = [
        p
        for p in sorted(glob.glob("assets/**/*.png", recursive=True))
        if not any(skip in p for skip in SKIP_DIRS)
    ]
    if not paths:
        print("Nothing to do - no PNGs outside the skipped directories.")
        return 0

    before = after = 0
    for path in paths:
        png_bytes, webp_bytes, how = convert(path, args.dry_run)
        before += png_bytes
        after += webp_bytes
        saved = 100 * (1 - webp_bytes / png_bytes) if png_bytes else 0
        print(f"{png_bytes / 1048576:6.2f}M -> {webp_bytes / 1048576:6.2f}M"
              f" (-{saved:3.0f}%) {how:34} {path}")

    print(
        f"\ntotal {before / 1048576:.1f} MB -> {after / 1048576:.1f} MB "
        f"({100 * (1 - after / before):.0f}% saved)"
    )
    if args.dry_run:
        print("dry run: no files written")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
