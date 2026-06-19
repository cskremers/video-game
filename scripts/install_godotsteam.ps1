# Installs GodotSteam GDExtension into addons/godotsteam/
# Requires: Godot 4.x editor OR manual zip placement from Asset Library

param(
    [string]$GodotVersion = "4.4"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$TargetDir = Join-Path $ProjectRoot "addons\godotsteam"

Write-Host "GodotSteam installer"
Write-Host "Target: $TargetDir"
Write-Host ""
Write-Host "GodotSteam GDExtension is distributed via the Godot Asset Library."
Write-Host "Automated download requires the Godot editor AssetLib integration."
Write-Host ""
Write-Host "Manual steps:"
Write-Host "  1. Open project in Godot $GodotVersion+"
Write-Host "  2. AssetLib -> search 'GodotSteam GDExtension 4.4+'"
Write-Host "  3. Install to res://addons/godotsteam/"
Write-Host ""
Write-Host "Alternative: download from https://godotsteam.com/getting_started/introduction/"
Write-Host ""

if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
}

$marker = Join-Path $TargetDir "godotsteam.gdextension"
if (Test-Path $marker) {
    Write-Host "GodotSteam appears installed: $marker"
    exit 0
}

Write-Host "GodotSteam not found yet. Install via Asset Library (see addons/godotsteam/README.md)."
exit 1
