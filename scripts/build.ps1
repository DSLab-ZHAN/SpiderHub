param(
    # Parameter help description
    [Parameter(Mandatory=$true, HelpMessage="Your spider folder path")]
    [string]
    $spider_folder_path
)

$status = $true

if (! (Test-Path $spider_folder_path)) {
    Write-Output "[-] Spider folder path '$spider_folder_path' does not exist!"
    $status = $false
}

if (! (Test-Path "compose.json")) {
    Write-Output "[-] Cannot found 'compose.json' in current path!"
    $status = $false
}

if (! $status) {
    exit -1
}

if (Test-Path "build") {
    Remove-Item -Path "build" -Recurse
}

New-Item -Path "build/temp" -ItemType Directory > $null

Copy-Item "compose.json" "build/temp"
Write-Output "[+] compose.json ==> build/temp"

Copy-Item $spider_folder_path "build/temp" -Recurse
Write-Output "[+] $spider_folder_path ==> build/temp/$spider_folder_path"

$spider_folder_name = Split-Path $spider_folder_path -Leaf

zip.exe -r -b"build/temp"  "build/$spider_folder_name.zip" "compose.json" "$spider_folder_path"
Write-Output "[+] ZIP FILE OUTPUT TO: build/$spider_folder_name.zip"

Remove-Item "./build/temp" -Recurse
Write-Output "[+] Clean temp files"

Write-Output "[+] Build done!"
