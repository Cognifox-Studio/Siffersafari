#!/usr/bin/env bash
#
# Pixel_6 dev loop for macOS/Linux — bash port of scripts/flutter_pixel6.ps1.
#
# Usage:
#   scripts/flutter_pixel6.sh --action sync            # build + install + relaunch
#   scripts/flutter_pixel6.sh --action install         # build + install, verify
#   scripts/flutter_pixel6.sh --action run             # flutter run on Pixel_6
#
# Extra arguments after `--` are forwarded to the flutter command:
#   scripts/flutter_pixel6.sh --action run -- --dart-define=FULL_SMOKE=false
#
# The Windows script stays the canonical one for Windows users; keep the two in
# sync when changing install/verification behaviour.

set -euo pipefail

PIXEL_AVD_NAME="Pixel_6"
APP_ID="se.cognifox.Siffersafari"
SCRIPT_VERSION="pixel6-script/v3-deterministic-install (bash)"

ACTION="run"
LOG_OUTPUT_DIR="build/logs"
CLEAR_LOGCAT_BEFORE_RUN=0
DUMP_LOGCAT_AFTER_RUN=0
FLUTTER_ARGS=()

die() {
  echo "error: $*" >&2
  exit 1
}

usage() {
  sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -a|--action)
      ACTION="${2:-}"; shift 2 ;;
    --log-dir)
      LOG_OUTPUT_DIR="${2:-}"; shift 2 ;;
    --clear-logcat)
      CLEAR_LOGCAT_BEFORE_RUN=1; shift ;;
    --dump-logcat-after-run)
      DUMP_LOGCAT_AFTER_RUN=1; shift ;;
    -h|--help)
      usage 0 ;;
    --)
      shift
      FLUTTER_ARGS+=("$@")
      break ;;
    *)
      die "unknown argument: $1 (try --help)" ;;
  esac
done

case "$ACTION" in
  run|install|sync) ;;
  *) die "unknown action: $ACTION (expected run|install|sync)" ;;
esac

command -v adb >/dev/null 2>&1 || die "adb not found on PATH (install Android platform-tools)"
command -v flutter >/dev/null 2>&1 || die "flutter not found on PATH"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "Script: $SCRIPT_VERSION"
echo "Repo:   $REPO_ROOT"

# Prints the emulator serial whose AVD name matches $PIXEL_AVD_NAME, if any.
find_pixel_device() {
  local serial avd_name
  while read -r serial state _; do
    [[ "$state" == "device" ]] || continue
    [[ "$serial" == emulator-* ]] || continue

    # `adb emu avd name` prints the AVD name followed by a line "OK".
    avd_name="$(adb -s "$serial" emu avd name 2>/dev/null \
      | tr -d '\r' \
      | grep -v '^OK$' \
      | grep -v '^$' \
      | head -n1 || true)"

    if [[ "$avd_name" == "$PIXEL_AVD_NAME" ]]; then
      echo "$serial"
      return 0
    fi
  done < <(adb devices)
  return 1
}

ensure_pixel_device() {
  local serial
  if serial="$(find_pixel_device)"; then
    echo "$serial"
    return 0
  fi

  echo "$PIXEL_AVD_NAME is not running. Launching the emulator..."
  flutter emulators --launch "$PIXEL_AVD_NAME" >/dev/null 2>&1 || true

  local deadline=$(( $(date +%s) + 180 ))
  while (( $(date +%s) < deadline )); do
    sleep 2
    if serial="$(find_pixel_device)"; then
      echo "$serial"
      return 0
    fi
  done

  die "no active $PIXEL_AVD_NAME emulator within 3 minutes"
}

wait_for_android_ready() {
  local device_id="$1"
  echo "Waiting for device to boot (boot_completed + PackageManager)..."

  adb -s "$device_id" wait-for-device >/dev/null 2>&1 \
    || die "could not attach to $device_id via adb"

  local deadline=$(( $(date +%s) + 240 ))
  local boot=""
  while (( $(date +%s) < deadline )); do
    boot="$(adb -s "$device_id" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r\n ' || true)"
    [[ "$boot" == "1" ]] && break
    sleep 2
  done
  [[ "$boot" == "1" ]] || die "device did not report sys.boot_completed=1 (deviceId=$device_id)"

  deadline=$(( $(date +%s) + 120 ))
  while (( $(date +%s) < deadline )); do
    if adb -s "$device_id" shell pm path android >/dev/null 2>&1; then
      return 0
    fi
    sleep 2
  done
  die "PackageManager did not become ready (deviceId=$device_id)"
}

# Echoes "<lastUpdateTime>|<versionName>|<versionCode>" or nothing.
package_info() {
  local device_id="$1" raw=""
  raw="$(adb -s "$device_id" shell dumpsys package "$APP_ID" 2>/dev/null || true)"
  [[ -n "$raw" ]] || return 0

  local version_name version_code last_update
  version_name="$(grep -o 'versionName=[^ ]*' <<<"$raw" | head -n1 | cut -d= -f2 || true)"
  version_code="$(grep -o 'versionCode=[^ ]*' <<<"$raw" | head -n1 | cut -d= -f2 || true)"
  last_update="$(grep -o 'lastUpdateTime=.*' <<<"$raw" | head -n1 | cut -d= -f2- || true)"

  if [[ -n "$version_name$version_code$last_update" ]]; then
    echo "${last_update}|${version_name}|${version_code}"
  fi
}

install_debug_apk_and_verify() {
  local device_id="$1"
  local before after apk_path

  before="$(package_info "$device_id")"
  if [[ -n "$before" ]]; then
    echo "Before install: $(cut -d'|' -f2- <<<"$before")"
  else
    echo "Before install: package not installed or unreadable."
  fi

  echo "Building debug APK (deterministic install)..."
  flutter build apk --debug ${FLUTTER_ARGS[@]+"${FLUTTER_ARGS[@]}"} \
    || die "flutter build apk --debug failed"

  apk_path="$REPO_ROOT/build/app/outputs/flutter-apk/app-debug.apk"
  [[ -f "$apk_path" ]] || die "APK not found after build: $apk_path"

  echo "Installing exactly: $apk_path"
  if command -v sha256sum >/dev/null 2>&1; then
    echo "APK sha256: $(sha256sum "$apk_path" | cut -d' ' -f1)"
  elif command -v shasum >/dev/null 2>&1; then
    echo "APK sha256: $(shasum -a 256 "$apk_path" | cut -d' ' -f1)"
  fi

  # Uninstall failures are expected when the app is not installed yet.
  adb -s "$device_id" uninstall "$APP_ID" >/dev/null 2>&1 || true
  adb -s "$device_id" install -r -t "$apk_path" >/dev/null \
    || die "adb install failed"

  after="$(package_info "$device_id")"
  [[ -n "$after" ]] || die "install verification failed: package info unreadable after install"

  local after_update after_name after_code
  after_update="$(cut -d'|' -f1 <<<"$after")"
  after_name="$(cut -d'|' -f2 <<<"$after")"
  after_code="$(cut -d'|' -f3 <<<"$after")"

  [[ -n "$after_update" && -n "$after_name" && -n "$after_code" ]] \
    || die "install verification failed: missing versionName/versionCode/lastUpdateTime"

  if [[ -n "$before" ]]; then
    local before_update
    before_update="$(cut -d'|' -f1 <<<"$before")"
    if [[ "$before_update" == "$after_update" ]]; then
      die "install verification failed: lastUpdateTime unchanged (stale APK?)"
    fi
  fi

  echo "After install: version=$after_name code=$after_code lastUpdateTime=$after_update"
}

DEVICE_ID="$(ensure_pixel_device)"
wait_for_android_ready "$DEVICE_ID"
echo "Using device: $DEVICE_ID (AVD: $PIXEL_AVD_NAME)"

mkdir -p "$LOG_OUTPUT_DIR"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

case "$ACTION" in
  run)
    echo "Mode: RUN (flutter run + optional logcat dump)"
    (( CLEAR_LOGCAT_BEFORE_RUN )) && adb -s "$DEVICE_ID" logcat -c >/dev/null 2>&1 || true

    RUN_LOG="$LOG_OUTPUT_DIR/flutter_run_${TIMESTAMP}.log"
    echo "[$TIMESTAMP] flutter run on $DEVICE_ID" > "$RUN_LOG"

    set +e
    flutter run -d "$DEVICE_ID" ${FLUTTER_ARGS[@]+"${FLUTTER_ARGS[@]}"} 2>&1 | tee -a "$RUN_LOG"
    EXIT_CODE=${PIPESTATUS[0]}
    set -e

    if (( DUMP_LOGCAT_AFTER_RUN )) || grep -q 'Lost connection to device\.' "$RUN_LOG" 2>/dev/null; then
      LOGCAT_PATH="$LOG_OUTPUT_DIR/logcat_${TIMESTAMP}.txt"
      if adb -s "$DEVICE_ID" logcat -d -v time > "$LOGCAT_PATH" 2>&1; then
        echo "[logcat] Saved to: $LOGCAT_PATH"
      else
        echo "warning: could not dump logcat" >&2
      fi
    fi

    exit "$EXIT_CODE"
    ;;

  install)
    echo "Mode: INSTALL (build apk + adb install exact file)"
    install_debug_apk_and_verify "$DEVICE_ID"
    ;;

  sync)
    echo "Mode: SYNC (build + install + restart + launch)"
    install_debug_apk_and_verify "$DEVICE_ID"

    echo "Restarting the app so it definitely runs the new build..."
    adb -s "$DEVICE_ID" shell am force-stop "$APP_ID" >/dev/null 2>&1 || true
    adb -s "$DEVICE_ID" shell monkey -p "$APP_ID" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1 \
      || die "could not launch $APP_ID after sync"

    echo "SYNC done: app installed, restarted and launched on $PIXEL_AVD_NAME."
    ;;
esac
