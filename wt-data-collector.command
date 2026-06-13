#!/usr/bin/env bash

OUTPUT_FILE="systemInfo.txt"
FOLDER_NAME="WT-BUGREPORT"
DATE=$(date '+%Y-%m-%d_%H-%M')
BUG_FILES="$HOME/Desktop/${FOLDER_NAME}-${DATE}"
OUT_PATH="$BUG_FILES/$OUTPUT_FILE"

if [[ ! -d "$BUG_FILES" ]]; then
    mkdir -p "$BUG_FILES"
else
    printf "You've already created a report recently.\n"
    exit 1
fi

# Use block redirection to write system information to file efficiently
{
    uname -a
    
    printf "\nSoftware Information\n_______________________________________\n"
    # Cache system_profiler output to avoid slow, repeated calls
    SW_INFO=$(system_profiler SPSoftwareDataType)
    for a in "System Version" "Kernel Version" "Boot Volume" "Boot Mode" "Secure Virtual Memory" "System Integrity Protection" "Time since boot"; do
        b=$(echo "$SW_INFO" | grep "$a" | awk -F': ' '{print $2}' | xargs)
        [[ -n "$b" ]] && printf "%s = %s\n" "$a" "$b"
    done

    printf "\nHardware Information\n_______________________________________\n"
    HW_INFO=$(system_profiler SPHardwareDataType)
    for a in "Model Name" "Model Identifier" "Processor Name" "Processor Speed" "L3 Cache (per Processor)" "Memory" "Processor Interconnect Speed" "Boot ROM Version" "SMC Version (system)" "SMC Version (processor tray)" "Hardware UUID"; do
        b=$(echo "$HW_INFO" | grep "$a" | awk -F': ' '{print $2}' | xargs)
        [[ -n "$b" ]] && printf "%s = %s\n" "$a" "$b"
    done

    printf "\nGraphics Information\n_______________________________________\n"
    GFX_INFO=$(system_profiler SPDisplaysDataType)
    for a in "Chipset Model" "Type" "Bus" "Slot" "PCIe Lane Width" "VRAM (Total)" "Vendor" "Device ID" "Revision ID" "ROM Revision" "VBIOS Version" "EFI Driver Version" "Resolution" "Framebuffer Depth"; do
        b=$(echo "$GFX_INFO" | grep "$a" | awk -F': ' '{print $2}' | xargs)
        [[ -n "$b" ]] && printf "%s = %s\n" "$a" "$b"
    done

    printf "\nStorage Information\n_______________________________________\n"
    system_profiler SPStorageDataType
} > "$OUT_PATH"

# Map directories to their target file patterns for safe iteration
LOG_TARGETS=(
    "$HOME/WarThunderLauncherLogs:*"
    "$HOME/My Games/WarThunder/_game_logs:*.clog"
    "$HOME/Library/Logs/DiagnosticReports:aces*"
    "$HOME/Library/Application Support/CrashReporter:aces*"
    "/Library/Logs/DiagnosticReports:aces*"
)

for target in "${LOG_TARGETS[@]}"; do
    DIR="${target%%:*}"
    PATTERN="${target##*:}"
    
    if [[ -d "$DIR" ]]; then
        # Use find -exec to handle files safely, avoiding subshell word-splitting
        find "$DIR" -maxdepth 1 -type f -name "$PATTERN" -mmin -30 -exec cp -p {} "$BUG_FILES/" \; 2>/dev/null
    fi
done

clear
printf "These files will be zipped for you to submit\n"
printf "____________________________________________________\n"
ls -l "$BUG_FILES"
printf "____________________________________________________\n"
printf "Add any additional files to the folder such as screen caps, replays, etc.\n"

open -a Finder "$BUG_FILES"
read -p "Please review these files carefully, do you want to submit them? (Y / N): " ans_yn

case "$ans_yn" in
    [Yy]|[Yy][Ee][Ss]) 
        echo "Zipping the files..."
        ;;
    *) 
        echo "Exiting. Files preserved at $BUG_FILES"
        exit 3
        ;;
esac

clear
# Ensure zip succeeds before deleting the source directory
if zip -r -j -q "${BUG_FILES}.zip" "$BUG_FILES"; then
    rm -rf "$BUG_FILES"
    clear
    printf "The needed files are zipped for you to submit.\n"
    printf "Please attach the file below to your Bug Report Submission:\n"
    printf "____________________________________________________\n"
    echo "${BUG_FILES}.zip"
    printf "____________________________________________________\n"
else
    printf "Error: Failed to create zip archive.\n"
    exit 1
fi
