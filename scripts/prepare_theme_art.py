"""Prepare generated theme art for the app.

Two jobs the generator cannot do for us:

* chroma-key the character sprites onto real alpha (the old astronaut shipped
  with an opaque green box baked into the pixels), with edge despill so no
  green halo survives on the dark space background, and
* trim the paper border the hero illustration came back with.

Outputs are written as WebP at the same dimensions the existing assets use, so
the rendering widgets need no changes.

Usage: python3 scripts/prepare_theme_art.py [source_dir]

The generated source PNGs are not checked in (they are a few hundred KB each
and the WebP output is the artefact that ships); pass the directory holding
space_background.png, space_character.png, space_hero.png and the desert
equivalents.
"""

import io
import os
import sys

import numpy as np
from PIL import Image

SRC = sys.argv[1] if len(sys.argv) > 1 else "/tmp/generated_art"
OUT = "assets/images/themes"

# Green-screen parameters. The generator produced a near-flat #00E000-ish
# field; the thresholds are wide enough to take the noise with it but the
# soft ramp keeps the outline of the artwork instead of chewing it away.
KEY = np.array([0.0, 224.0, 0.0])
HARD = 70.0   # fully transparent below this distance from the key colour
SOFT = 150.0  # fully opaque above this distance


def chroma_key(path: str) -> Image.Image:
    img = Image.open(path).convert("RGB")
    arr = np.asarray(img).astype(np.float32)

    dist = np.sqrt(((arr - KEY) ** 2).sum(axis=2))

    # 1.0 = keep, 0.0 = drop, linear ramp in between for antialiased edges.
    alpha = np.clip((dist - HARD) / (SOFT - HARD), 0.0, 1.0)

    # Despill: on the semi-transparent rim, pull the green channel down to the
    # level of the other channels, otherwise the sprite glows green on a dark
    # background even though the pixels are "transparent enough".
    rim = (alpha > 0.0) & (alpha < 1.0)
    green_excess = arr[:, :, 1] - np.maximum(arr[:, :, 0], arr[:, :, 2])
    fix = rim & (green_excess > 0)
    arr[:, :, 1] = np.where(fix, np.maximum(arr[:, :, 0], arr[:, :, 2]), arr[:, :, 1])

    rgba = np.dstack([arr, alpha * 255.0]).clip(0, 255).astype(np.uint8)
    out = Image.fromarray(rgba, "RGBA")

    # Drop the empty margin, then re-centre on a square canvas so BoxFit.contain
    # keeps the sprite the same perceived size as the previous art.
    bbox = out.split()[3].getbbox()
    if bbox is None:
        raise SystemExit(f"{path}: chroma key removed everything")
    out = out.crop(bbox)
    side = int(max(out.size) * 1.06)
    square = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    square.paste(out, ((side - out.width) // 2, (side - out.height) // 2))
    return square.resize((512, 512), Image.LANCZOS)


def trim_paper_border(path: str, pad: int = 60, aspect: float = 2.0) -> Image.Image:
    """Remove the white deckled paper border the hero came back with.

    Cropping cannot fix this: a scan of the source shows the "border" is a soft
    white vignette fading over ~25 px at the top and ~15 px at the sides, so
    every inset either leaves a white sliver or eats the artwork. Instead the
    paper band is refilled by propagating the nearest real pixels inward, which
    is what the eye expects at a frame edge, and the result is centre-cropped to
    the card's aspect ratio.
    """
    img = Image.open(path).convert("RGB")
    arr = np.asarray(img).astype(np.float32)
    h, w, _ = arr.shape

    paper = arr.min(axis=2) > 235
    band = np.zeros((h, w), dtype=bool)
    band[:pad, :] = True
    band[-pad:, :] = True
    band[:, :pad] = True
    band[:, -pad:] = True
    remaining = paper & band

    if remaining.any():
        for _ in range(pad + 8):
            known = ~remaining
            up = np.roll(known, 1, axis=0)
            dn = np.roll(known, -1, axis=0)
            lf = np.roll(known, 1, axis=1)
            rt = np.roll(known, -1, axis=1)
            nbrs = up.astype(np.int8) + dn + lf + rt
            fillable = remaining & (nbrs > 0)
            if not fillable.any():
                break
            # Average only over neighbours that already hold real pixels --
            # including the paper ones is what keeps a white sliver alive.
            acc = np.zeros_like(arr)
            count = np.zeros((h, w), dtype=np.float32)
            for shift, axis in ((1, 0), (-1, 0), (1, 1), (-1, 1)):
                shifted = np.roll(arr, shift, axis=axis)
                known_shifted = np.roll(known, shift, axis=axis)
                acc += shifted * known_shifted[:, :, None]
                count += known_shifted
            filled = fillable & (count > 0)
            arr[filled] = acc[filled] / count[filled][:, None]
            remaining = remaining & ~filled

    img = Image.fromarray(arr.clip(0, 255).astype(np.uint8), "RGB")
    img = img.crop((16, 16, w - 16, h - 16))

    # Centre-crop to the target aspect so BoxFit.cover does not stretch it.
    w, h = img.size
    if w / h > aspect:
        new_w = int(h * aspect)
        img = img.crop(((w - new_w) // 2, 0, (w + new_w) // 2, h))
    elif w / h < aspect:
        new_h = int(w / aspect)
        img = img.crop((0, (h - new_h) // 2, w, (h + new_h) // 2))
    return img


def save_webp(img: Image.Image, rel: str, size: tuple[int, int], quality: int = 90) -> str:
    path = os.path.join(OUT, rel)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img = img.resize(size, Image.LANCZOS)
    img.save(path, "WEBP", quality=quality, method=6, alpha_quality=100)
    return path


def main() -> None:
    made = []

    made.append(save_webp(
        Image.open(f"{SRC}/space_background.png").convert("RGB"),
        "space/background.webp", (1024, 1536)))
    made.append(save_webp(chroma_key(f"{SRC}/space_character.png"),
                          "space/character.webp", (512, 512)))
    made.append(save_webp(trim_paper_border(f"{SRC}/space_hero.png"),
                          "space/quest_hero.webp", (1024, 512)))

    made.append(save_webp(
        Image.open(f"{SRC}/desert_background.png").convert("RGB"),
        "desert/background.webp", (1024, 1536)))
    made.append(save_webp(chroma_key(f"{SRC}/desert_character.png"),
                          "desert/character.webp", (512, 512)))
    made.append(save_webp(trim_paper_border(f"{SRC}/desert_hero.png"),
                          "desert/quest_hero.webp", (1024, 512)))

    for p in made:
        im = Image.open(p)
        alpha = "has-alpha" if im.mode == "RGBA" else "opaque"
        print(f"{os.path.getsize(p) / 1024:8.1f} KB  {im.size[0]}x{im.size[1]}  "
              f"{alpha:9s} {p}")


if __name__ == "__main__":
    main()
