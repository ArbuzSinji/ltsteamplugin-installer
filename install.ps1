$ErrorActionPreference = "Stop"

Write-Host "Starting installation..." -ForegroundColor Cyan

# -----------------------------
# 1. Detect Steam installation
# -----------------------------
Write-Host "Searching for Steam installation..." -ForegroundColor Cyan

$steamPath = (Get-ItemProperty -Path "HKCU:\Software\Valve\Steam" -ErrorAction SilentlyContinue).SteamPath

if (-not $steamPath) {
    $steamExe = Get-ChildItem -Path "C:\" -Filter "steam.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($steamExe) {
        $steamPath = $steamExe.Directory.FullName
    }
}

if (-not $steamPath) {
    Write-Host "Steam not found on this system." -ForegroundColor Red
    exit 1
}

Write-Host "Steam found at: $steamPath" -ForegroundColor Green

# -----------------------------
# 2. Install Millennium if missing
# -----------------------------
$millenniumPath = Join-Path $steamPath "millennium"

if (-not (Test-Path $millenniumPath)) {
    Write-Host "Millennium not found. Installing Millennium..." -ForegroundColor Yellow

    $millenniumZipUrl = "https://github.com/SteamClientHomebrew/Millennium/releases/download/v3.3.0/millennium-v3.3.0-windows-x86_64.zip"
    $millenniumZipPath = Join-Path $env:TEMP "millennium.zip"
    $millenniumExtractPath = Join-Path $env:TEMP "millennium_extract"

    if (Test-Path $millenniumZipPath) { Remove-Item $millenniumZipPath -Force }
    if (Test-Path $millenniumExtractPath) { Remove-Item $millenniumExtractPath -Recurse -Force }

    Invoke-WebRequest -Uri $millenniumZipUrl -OutFile $millenniumZipPath

    Write-Host "Extracting Millennium..." -ForegroundColor Cyan
    Expand-Archive -Path $millenniumZipPath -DestinationPath $millenniumExtractPath -Force

    New-Item -ItemType Directory -Path $millenniumPath -Force | Out-Null

    Copy-Item -Path (Join-Path $millenniumExtractPath "*") -Destination $millenniumPath -Recurse -Force

    Remove-Item $millenniumZipPath -Force
    Remove-Item $millenniumExtractPath -Recurse -Force

    Write-Host "Millennium installed successfully!" -ForegroundColor Green
} else {
    Write-Host "Millennium already installed." -ForegroundColor Green
}

# -----------------------------
# 3. Install ltsteamplugin
# -----------------------------
Write-Host "Installing ltsteamplugin..." -ForegroundColor Cyan

$pluginPath = Join-Path $millenniumPath "plugins\luatools"
$temp = Join-Path $env:TEMP "ltsteamplugin"
$zipPath = Join-Path $env:TEMP "ltsteamplugin.zip"

$zipUrl = "https://github.com/piqseu/ltsteamplugin/releases/download/v8.0.5/ltsteamplugin.zip"

if (Test-Path $temp) { Remove-Item $temp -Recurse -Force }
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }

Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath

Expand-Archive -Path $zipPath -DestinationPath $temp -Force

$root = Get-ChildItem -Path $temp | Where-Object { $_.PSIsContainer } | Select-Object -First 1

if (-not $root) {
    Write-Host "Plugin ZIP structure invalid." -ForegroundColor Red
    exit 1
}

if (Test-Path $pluginPath) {
    Remove-Item $pluginPath -Recurse -Force
}

New-Item -ItemType Directory -Path $pluginPath | Out-Null

Copy-Item -Path (Join-Path $root.FullName "*") -Destination $pluginPath -Recurse -Force

Remove-Item $temp -Recurse -Force
Remove-Item $zipPath -Force

Write-Host "ltsteamplugin installed successfully!" -ForegroundColor Green
Write-Host "Installation complete." -ForegroundColor Cyan
