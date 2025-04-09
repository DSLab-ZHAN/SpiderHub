#!/bin/bash
set -euo pipefail

# 参数验证
if [ $# -ne 1 ]; then
    echo "[-] Usage: $0 <spider_folder_path>"
    exit 1
fi

spider_folder_path="$1"
status=true

if [ ! -d "$spider_folder_path" ]; then
    echo "[-] Spider folder path '$spider_folder_path' does not exist!"
    status=false
fi

if [ ! -f "compose.json" ]; then
    echo "[-] Cannot found 'compose.json' in current path!"
    status=false
fi

if [ "$status" = false ]; then
    exit 1
fi

if [ -d "build" ]; then
    rm -rf build
fi

mkdir -p build/temp

cp compose.json build/temp/
echo "[+] compose.json ==> build/temp"

cp -r "$spider_folder_path" build/temp/
echo "[+] $spider_folder_path ==> build/temp/$(basename "$spider_folder_path")"

spider_folder_name=$(basename "$spider_folder_path")

(
    cd build/temp
    zip -r "../${spider_folder_name}.zip" compose.json "$spider_folder_name"
)
echo "[+] ZIP FILE OUTPUT TO: build/${spider_folder_name}.zip"

rm -rf build/temp
echo "[+] Clean temp files"

echo "[+] Build done!"
