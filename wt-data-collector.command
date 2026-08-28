#!/usr/bin/env bash
#
# War Thunder bug-report collector for macOS.
# Gathers system info and recent game/crash logs, then zips them for submission.

set -euo pipefail

# ---- Configuration ---------------------------------------------------------

readonly OUTPUT_FILE="systemInfo.txt"
readonly FOLDER_NAME="WT-BUGREPORT"
readonly LOG_AGE_MIN=30          # collect logs modified within this many minutes
readonly DATE="$(date '+%Y-%m-%d_%H-%M')"
readonly REPORT_DIR="${HOME}/Desktop/${FOLDER_NAME}-${DATE}"
readonly OUT_PATH="${REPORT_DIR}/${OUTPUT_FILE}"

# Directory:glob pairs for logs to collect.
readonly LOG_TARGETS=(
    "${HOME}/WarThunderLauncherLogs:*"
    "${HOME}/My Games/WarThunder/_game_logs:*.clog"
    "${HOME}/Library/Logs/DiagnosticReports:aces*"
    "${HOME}/Library/Application Support/CrashReporter:aces*"
    "/Library/Logs/DiagnosticReports:aces*"
)

# ---- Helpers ---------------------------------------------------------------

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }

# Print "Label = value" for each requested field found in profiler output.
# $1 = profiler text, remaining args = field labels.
extract_fields() {
    local info="$1"; shift
    local field value
    for field in "$@"; do
        value="$(grep -F "$field" <<<"$info" | awk -F': ' '{print $2}' | xargs)"
        [[ -n "$value" ]] && printf '%s = %s\n' "$field" "$value"
    done
}

# ---- Preconditions ---------------------------------------------------------

[[ "$(uname -s)" == "Darwin" ]] || die "This script only runs on macOS."

for cmd in system_profiler zip; do
    command -v "$cmd" >/dev/null 2>&1 || die "Required command not found: $cmd"
done

if [[ -d "$REPORT_DIR" ]]; then
    die "A report for this timestamp already exists: $REPORT_DIR"
fi
mkdir -p "$REPORT_DIR"

# ---- System information ----------------------------------------------------

{
    uname -a

    printf '\nSoftware Information\n%s\n' "$(printf '_%.0s' {1..40})"
    sw_info="$(system_profiler SPSoftwareDataType)"
    extract_fields "$sw_info" \
        "System Version" "Kernel Version" "Boot Volume" "Boot Mode" \
        "Secure Virtual Memory" "System Integrity Protection" "Time since boot"

    printf '\nHardware Information\n%s\n' "$(printf '_%.0s' {1..40})"
    hw_info="$(system_profiler SPHardwareDataType)"
    extract_fields "$hw_info" \
        "Model Name" "Model Identifier" "Chip" "Processor Name" "Processor Speed" \
        "Total Number of Cores" "L3 Cache (per Processor)" "Memory" \
        "Processor Interconnect Speed" "Boot ROM Version" "SMC Version (system)" \
        "SMC Version (processor tray)" "Hardware UUID"

    printf '\nGraphics Information\n%s\n' "$(printf '_%.0s' {1..40})"
    gfx_info="$(system_profiler SPDisplaysDataType)"
    extract_fields "$gfx_info" \
        "Chipset Model" "Type" "Bus" "Slot" "PCIe Lane Width" "VRAM (Total)" \
        "Vendor" "Device ID" "Revision ID" "ROM Revision" "VBIOS Version" \
        "EFI Driver Version" "Resolution" "Framebuffer Depth"

    printf '\nStorage Information\n%s\n' "$(printf '_%.0s' {1..40})"
    system_profiler SPStorageDataType
} > "$OUT_PATH"

# ---- Collect logs ----------------------------------------------------------

for target in "${LOG_TARGETS[@]}"; do
    dir="${target%%:*}"
    pattern="${target##*:}"
    [[ -d "$dir" ]] || continue
    find "$dir" -maxdepth 1 -type f -name "$pattern" -mmin "-${LOG_AGE_MIN}" \
        -exec cp -p {} "$REPORT_DIR/" \; 2>/dev/null || true
done

# ---- Review ----------------------------------------------------------------

clear
printf 'These files will be zipped for you to submit\n'
printf '%s\n' "$(printf '_%.0s' {1..52})"
ls -l "$REPORT_DIR"
printf '%s\n' "$(printf '_%.0s' {1..52})"
printf 'Add any additional files to the folder such as screen caps, replays, etc.\n'

command -v open >/dev/null 2>&1 && open -a Finder "$REPORT_DIR"

read -r -p 'Please review these files carefully, do you want to submit them? (Y/N): ' ans
case "$ans" in
    [Yy]|[Yy][Ee][Ss]) : ;;
    *) printf 'Exiting. Files preserved at %s\n' "$REPORT_DIR"; exit 0 ;;
esac

# ---- Zip --------------------------------------------------------------------

clear
if zip -r -j -q "${REPORT_DIR}.zip" "$REPORT_DIR"; then
    rm -rf "$REPORT_DIR"
    clear
    printf 'The needed files are zipped for you to submit.\n'
    printf 'Please attach the file below to your Bug Report Submission:\n'
    printf '%s\n' "$(printf '_%.0s' {1..52})"
    printf '%s\n' "${REPORT_DIR}.zip"
    printf '%s\n' "$(printf '_%.0s' {1..52})"
else
    die "Failed to create zip archive."
fi
