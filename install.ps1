$ErrorActionPreference = "Stop"

# ZIP
$zipUrl = "https://github.com/piqseu/ltsteamplugin/releases/download/v8.0.5/ltsteamplugin.zip"

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


$millenniumPath = Join-Path $steamPath "millennium\plugins\luatools"


$temp = Join-Path $env:TEMP "ltsteamplugin"
$zipPath = Join-Path $env:TEMP "ltsteamplugin.zip"

Write-Host "Downloading plugin..." -ForegroundColor Cyan


if (Test-Path $temp) { Remove-Item $temp -Recurse -Force }
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }


Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath

Write-Host "Extracting..." -ForegroundColor Cyan

# Распаковываем
Expand-Archive -Path $zipPath -DestinationPath $temp -Force

# Удаляем старую установку
if (Test-Path $millenniumPath) {
    Remove-Item $millenniumPath -Recurse -Force
}

# Создаём папку и копируем файлы
New-Item -ItemType Directory -Path $millenniumPath | Out-Null
Copy-Item -Path "$temp\*" -Destination $millenniumPath -Recurse -Force

# Чистим временные файлы
Remove-Item $temp -Recurse -Force
Remove-Item $zipPath -Force

Write-Host "ltsteamplugin installed successfully!" -ForegroundColor Green
