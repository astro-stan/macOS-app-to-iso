#!/bin/bash

help=( --help -h )
print_help() {
    echo "Small script that will transform your macOS.app into a bootable hfs+"
    echo "partitioned .iso"
    echo
    echo "Usage: bash ./macOS-app-to-iso.sh macOS.app [ macOS.iso ]"
    echo
    echo "Optional arguments:"
    echo "-h, --help: prints this help and exits"
    echo "macOS.iso:  if ommitted the .iso will have the same name as the .app"
    exit 0
}
if [ $# -eq 0 ]; then
    print_help
fi
if [ $# -gt 2 ]; then
    echo "Too many arguments..."
    exit 1
fi 
for i in "$@"; do
    for h in "${help[@]}"; do
        if [ "$i" == "$h" ]; then
            print_help
        fi
    done
done


APP=$1
ISO=$2

if [ -d "$APP" ]; then
    if [ "$ISO" == "" ]; then
        ISO="$(basename "$APP")"
        ISO=${ISO::${#ISO}-4}".iso"
    fi
    if [ ${ISO: -4} != ".iso" ]; then
        ISO=${ISO}".iso"
    fi
    if [ ! -d "$(dirname "$ISO")" ]; then
        echo "Target dir: $(dirname "$ISO") does not exist..."
        exit 1
    fi
    ISO_NAME=${ISO::${#ISO}-4}
    
    hdiutil create -o "${ISO_NAME}".cdr -size 7316m -layout SPUD -fs HFS+J
    hdiutil attach "${ISO_NAME}".cdr.dmg -noverify -nobrowse -mountpoint /Volumes/install_build
    asr restore -source "${APP}"/Contents/SharedSupport/BaseSystem.dmg -target /Volumes/install_build -noprompt -noverify -erase
    hdiutil detach /Volumes/OS\ X\ Base\ System
    hdiutil convert "${ISO_NAME}".cdr.dmg -format UDTO -o "${ISO}"
    mv "${ISO}".cdr "${ISO}"
    rm -rf "${ISO_NAME}".cdr.dmg
else
    echo "$1 not found..."
    exit 1
fi
