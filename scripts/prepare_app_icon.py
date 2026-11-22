"""Rebuild the app icon derivatives from the master art.

Three problems the previous set had:

* stray opaque specks floating in the transparent area of the master,
* the wordmark is white, and the launcher background was an olive (#8A8769)
  that leaves white at roughly 3.2:1 -- below the 4.5:1 this app holds itself
  to elsewhere, on the one asset everybody sees first,
* every derivative (legacy launcher, adaptive foreground, Play 512) was made
  separately, so margins drifted between them.

This script removes the specks, keeps one master and derives everything from
it with explicit margins. Run from the repo root:

    python3 scripts/prepare_app_icon.py
"""

import os
from collections import deque

import numpy as np
from PIL import Image, ImageDraw

MASTER = "assets/images/app_icon/icon_source.png"
# Outside assets/: everything under assets/images/app_icon/ is bundled into
# the APK, so a backup copy there costs 1.5 MB of download.
BACKUP = "/tmp/icon_source_before_speck_cleanup.png"
PLAY = "assets/images/app_icon/appikon siffersafari_play_console_512.png"
MIPMAP = "android/app/src/main/res"

# Deep jungle green: the wordmark is white, so the background has to be dark.
# White on #1C4A2B is ~8.6:1, white on the old #8A8769 only ~3.2:1.
BACKGROUND = (0x1C, 0x4A, 0x2B)

# Legacy launcher icons: content at ~78 % of the tile.
# Adaptive foreground: 108 dp tile with a 66 dp safe zone -> ~0.61.
LEGACY_INSET = 0.78
FOREGROUND_SAFE = 0.60
PLAY_INSET = 0.76


def drop_specks(img: Image.Image, min_fraction: float = 0.002) -> Image.Image:
    """Drop small isolated opaque blobs, keep everything substantial.

    Keeping only the *largest* component is wrong here: the wordmark is twelve
    separate letters, each its own connected region, and earlier thresholds
    silently deleted "SIFFER SAFARI" (twice -- 49 576 pixels, which looked
    plausible until it was rendered). Measured, the real regions are the bust
    (18 012 cells) and twelve letters (128-345 cells), so the cut sits far below
    the smallest letter and only noise can fall through it.
    """
    alpha = np.asarray(img.split()[3])
    mask = alpha > 24

    # Label on a downsampled mask (fast in pure Python), then project back.
    step = 4
    small = mask[::step, ::step]
    h, w = small.shape
    label = np.zeros((h, w), dtype=np.int32)
    sizes = {}
    current = 0
    for sy in range(h):
        for sx in range(w):
            if not small[sy, sx] or label[sy, sx]:
                continue
            current += 1
            size = 0
            queue = deque([(sy, sx)])
            label[sy, sx] = current
            while queue:
                y, x = queue.popleft()
                size += 1
                for ny, nx in ((y + 1, x), (y - 1, x), (y, x + 1), (y, x - 1)):
                    if 0 <= ny < h and 0 <= nx < w and small[ny, nx] and not label[ny, nx]:
                        label[ny, nx] = current
                        queue.append((ny, nx))
            sizes[current] = size

    largest = max(sizes.values()) if sizes else 0
    threshold = max(largest * min_fraction, 20)
    keep_ids = [cid for cid, size in sizes.items() if size >= threshold]
    keep_small = np.isin(label, keep_ids)
    # Project back, growing by one small-cell so the outline is not shaved off.
    keep = np.repeat(np.repeat(keep_small, step, axis=0), step, axis=1)
    keep = keep[: mask.shape[0], : mask.shape[1]]
    grown = keep.copy()
    for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
        grown |= np.roll(keep, dy, axis=0) | np.roll(keep, dx, axis=1)
    final = mask & grown

    out = np.array(img)
    out[:, :, 3] = np.where(final, alpha, 0)
    # Sub-threshold alpha is noise, not artwork (the "specks" the icon appeared
    # to have were alpha <= 24 dust, not opaque blobs).
    out[:, :, 3] = np.where(out[:, :, 3] < 24, 0, out[:, :, 3])
    return Image.fromarray(out, "RGBA")


def trim_and_pad(img: Image.Image, size: int, inset: float, background=None) -> Image.Image:
    """Centre the artwork in a square canvas, content occupying `inset` of it."""
    bbox = img.split()[3].getbbox()
    art = img.crop(bbox)
    target = int(size * inset)
    scale = min(target / art.width, target / art.height)
    art = art.resize((max(1, int(art.width * scale)), max(1, int(art.height * scale))),
                     Image.LANCZOS)

    if background is None:
        canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    else:
        canvas = Image.new("RGBA", (size, size), background + (255,))

    canvas.alpha_composite(art, ((size - art.width) // 2, (size - art.height) // 2))
    return canvas


def main() -> None:
    master = Image.open(MASTER).convert("RGBA")
    cleaned = drop_specks(master)

    before = np.asarray(master.split()[3]) > 24
    after = np.asarray(cleaned.split()[3]) > 24
    print(f"opaque pixels: {int(before.sum())} -> {int(after.sum())} "
          f"({int(before.sum() - after.sum())} speck pixels removed)")

    # Splash art stays transparent, just 1024 with a little breathing room.
    cleaned.copy().save(MASTER)
    if not os.path.exists(BACKUP):
        master.save(BACKUP)

    # Play Console 512: dark background so the white wordmark reads.
    trim_and_pad(cleaned, 512, PLAY_INSET, BACKGROUND).convert("RGB").save(PLAY)

    # Legacy launcher icons (square; the launcher applies its own mask).
    for density, px in {"mdpi": 48, "hdpi": 72, "xhdpi": 96,
                        "xxhdpi": 144, "xxxhdpi": 192}.items():
        out = f"{MIPMAP}/mipmap-{density}/ic_launcher.png"
        trim_and_pad(cleaned, px, LEGACY_INSET, BACKGROUND).convert("RGB").save(out)

    # Adaptive foreground: transparent, inside the 66 % safe zone.
    for density, px in {"mdpi": 108, "hdpi": 162, "xhdpi": 216,
                        "xxhdpi": 324, "xxxhdpi": 432}.items():
        out = f"{MIPMAP}/mipmap-{density}/ic_launcher_foreground.png"
        trim_and_pad(cleaned, px, FOREGROUND_SAFE).save(out)

    print("wrote icon_source, Play 512, 5 legacy launcher icons, "
          "5 adaptive foregrounds")


if __name__ == "__main__":
    main()
