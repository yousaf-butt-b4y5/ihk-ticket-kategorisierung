<#
.SYNOPSIS
    Master-Runner: Führt alle Unit-Test-Skripte aus und gibt eine Gesamtübersicht.
#>

$ScriptRoot = $PSScriptRoot

$testFiles = @(
    'Get-Kategorie.Tests.ps1'
    'Get-Urgency.Tests.ps1'
    'Get-Impact.Tests.ps1'
    'Get-Prioritaet.Tests.ps1'
)

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  TEST-RUNNER: Alle Unit-Tests" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$gesamt_pass = 0
$gesamt_fail = 0
$dateien_ok = 0
$dateien_nok = 0

foreach ($file in $testFiles) {
    $path = Join-Path $ScriptRoot $file

    if (-not (Test-Path $path)) {
        Write-Host "`n[FEHLER] Test-Datei nicht gefunden: $file" -ForegroundColor Red
        $dateien_nok++
        continue
    }

    # Test-Skript ausführen, Rückgabewert auffangen
    $result = & $path

    if ($null -ne $result -and $result.PSObject.Properties.Name -contains 'Pass') {
        $gesamt_pass += $result.Pass
        $gesamt_fail += $result.Fail

        if ($result.Fail -eq 0) { $dateien_ok++ } else { $dateien_nok++ }
    }
    else {
        Write-Host "[WARNUNG] $file gab keinen Pass/Fail-Wert zurück." -ForegroundColor Yellow
        $dateien_nok++
    }
}

# --- Gesamt-Zusammenfassung ---
Write-Host "`n========================================" -ForegroundColor Yellow
Write-Host "  GESAMT-ZUSAMMENFASSUNG" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ("Test-Dateien gesamt    : {0}" -f $testFiles.Count)
Write-Host ("Dateien ohne Fehler    : {0}" -f $dateien_ok) -ForegroundColor Green
Write-Host ("Dateien mit Fehlern    : {0}" -f $dateien_nok) -ForegroundColor $(if ($dateien_nok -eq 0) { 'Green' } else { 'Red' })
Write-Host ""
Write-Host ("Tests bestanden        : {0}" -f $gesamt_pass) -ForegroundColor Green
Write-Host ("Tests fehlgeschlagen   : {0}" -f $gesamt_fail) -ForegroundColor $(if ($gesamt_fail -eq 0) { 'Green' } else { 'Red' })
Write-Host ("Tests gesamt           : {0}" -f ($gesamt_pass + $gesamt_fail))
Write-Host "========================================`n" -ForegroundColor Yellow
if ($gesamt_fail -eq 0) { exit 0 } else { exit 1 }