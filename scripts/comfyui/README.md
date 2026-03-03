# ComfyUI → Assets (Local Image Generation)

This folder is for generating theme images / mascots locally via ComfyUI.

## Prereqs

- Install and run ComfyUI.
- Default server is typically `http://127.0.0.1:8000` in this repo setup.

## 0) Start ComfyUI (recommended flags)

This repo includes a helper script that starts ComfyUI with speed-oriented flags that should not affect quality:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/comfyui/start_comfyui.ps1 -EnableManager
```

By default it enables:
- `--use-pytorch-cross-attention` (supported by this ComfyUI build)
- `--force-fp16`
- `--fp16-vae`

If you need to troubleshoot, you can disable them:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/comfyui/start_comfyui.ps1 -CrossAttention auto -NoFp16
```

Tip: If you don't have `xformers` installed, cross-attention settings can make a noticeable speed difference.

## 1) Export a workflow in API format

In ComfyUI:
- Build a workflow (e.g. txt2img) that outputs images.
- In the **positive prompt** text field, put: `__POSITIVE_PROMPT__`
- In the **negative prompt** text field (if you use one), put: `__NEGATIVE_PROMPT__`
- Export / save as **API format** JSON into:
  - `scripts/comfyui/workflows/txt2img_api.json`

## 2) Generate images into assets

Example:

```bash
dart run scripts/generate_images_comfyui.dart \
  --workflow scripts/comfyui/workflows/txt2img_api.json \
  --prompt "cute friendly space mascot, flat vector, kids app" \
  --negative "scary, gore, realistic" \
  --width 1024 --height 1024 --steps 25 --cfg 6.5 --count 4 \
  --out artifacts/comfyui/out
```

If your workflow uses the common ComfyUI nodes, `--width/--height/--steps/--cfg/--seed` will be applied automatically.
If not, the placeholders for prompts still work.

Note: `assets/images/generated/` is ignored by git in this repo. If you want to keep a generated image as an app asset, move/rename it into the proper theme folder under `assets/images/themes/`.

## Pose-pack (character_v2)

Generate a small set of character poses from the canonical jungle character reference.

Recommended (also generates alpha variants):

```powershell
powershell -ExecutionPolicy Bypass -File scripts/generate_character_v2_pose_pack.ps1 -AlphaAll
```

Override workflow explicitly:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/generate_character_v2_pose_pack.ps1 -Workflow scripts/comfyui/workflows/character_v2_pose_pack_api.json -AlphaAll
```

## Animation frames (idle/jump/run/wave)

To build real UI animations, generate each frame via ComfyUI and curate the results.

Example (idle, 8 frames):

```powershell
powershell -ExecutionPolicy Bypass -File scripts/generate_character_v2_animation_frames.ps1 -Anim idle -Frames 8 -AlphaAll
```

This outputs to `artifacts/comfyui/anim_<anim>_<timestamp>/`.
When you're happy with the loop, copy the chosen frames into:

`assets/images/characters/character_v2/<anim>/`.

## Benchmark (3 runs, median)

To measure if speed flags improved performance, run 3 identical generations and take the median time:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/comfyui/bench_comfyui.ps1
```

Default is `http://127.0.0.1:8000` in this repo.

To benchmark the pixel-art workflow (LoRA + rembg + alpha processing), run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/comfyui/bench_comfyui.ps1 -Workflow scripts/comfyui/workflows/ville_pixel_art_test_api.json -VarySeed
```

Note: `-VarySeed` is recommended to avoid ComfyUI caching making numbers unrealistically fast.

If your ComfyUI runs on a different port, override it explicitly:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/comfyui/bench_comfyui.ps1 -Server http://127.0.0.1:8001
```

## Plugins (optional)

These are only needed if you want higher consistency (IP-Adapter) or pose control (OpenPose).

### ComfyUI-Manager

From your ComfyUI folder:

```powershell
Set-Location "D:\Tools\Comfyui\resources\ComfyUI\custom_nodes"
git clone https://github.com/ltdrdata/ComfyUI-Manager comfyui-manager
```

Restart ComfyUI afterwards.

### IP-Adapter (stable character identity)

```powershell
Set-Location "D:\Tools\Comfyui\resources\ComfyUI\custom_nodes"
git clone https://github.com/cubiq/ComfyUI_IPAdapter_plus
```

Then download the required SDXL models into your ComfyUI model folders (see the IPAdapter repo for exact filenames).

### OpenPose preprocessor (pose control)

```powershell
Set-Location "D:\Tools\Comfyui\resources\ComfyUI\custom_nodes"
git clone https://github.com/Fannovel16/comfyui_controlnet_aux/
```

Then install Python dependencies as required by that repo (often includes `opencv-python`).
