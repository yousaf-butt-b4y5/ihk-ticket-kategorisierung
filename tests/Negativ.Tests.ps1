<#
.SYNOPSIS
    Negativtests für Main.ps1 (Integrationsebene).
    Prüft, ob das System bei fehlerhaften Eingaben kontrolliert scheitert.
#>

$ScriptRoot = $PSScriptRoot
$ProjectRoot = Split-Path $ScriptRoot -Parent
$MainScript = Join-Path $ProjectRoot 'Main.ps1'
$InputDir = Join-Path $ProjectRoot 'data\input'
$OriginalCsv = Join-Path $InputDir 'tickets_input.csv'
$BackupCsv = Join-Path $InputDir 'tickets_input.csv.bak'

$pass = 0
$fail = 0

Write-Host "`n=== Negativtests: Main.ps1 ===" -ForegroundColor Cyan

# --- Vorbereitung: Original-CSV sichern ---
if (Test-Path $OriginalCsv) {
    Copy-Item $OriginalCsv $BackupCsv -Force
}

try {
    # ======================================================
    # TC-05: Leere CSV-Datei
    # ======================================================
    Write-Host "`n[TC-05] Leere CSV-Datei" -ForegroundColor Yellow

    # Nur Header schreiben, keine Datenzeilen
    'TicketID;Betreff;Beschreibung;Meldender;Abteilung;Quelle;Standort;ErstelltAm' |
    Set-Content -Path $OriginalCsv -Encoding UTF8

    $fehlerAufgetreten = $false
    try {
        & $MainScript *>$null
    }
    catch {
        $fehlerAufgetreten = $true
    }

    # Main.ps1 nutzt 'exit 1' bei Fehler, daher LASTEXITCODE prüfen
    if ($LASTEXITCODE -ne 0 -or $fehlerAufgetreten) {
        Write-Host "  [PASS] Main.ps1 ist kontrolliert gescheitert (Exit-Code: $LASTEXITCODE)" -ForegroundColor Green
        $pass++
    }
    else {
        Write-Host "  [FAIL] Main.ps1 lief durch obwohl CSV leer war" -ForegroundColor Red
        $fail++
    }

    # ======================================================
    # TC-06: Eingabedatei fehlt
    # ======================================================
    Write-Host "`n[TC-06] Eingabedatei fehlt" -ForegroundColor Yellow

    Remove-Item $OriginalCsv -Force

    $fehlerAufgetreten = $false
    try {
        & $MainScript *>$null
    }
    catch {
        $fehlerAufgetreten = $true
    }

    if ($LASTEXITCODE -ne 0 -or $fehlerAufgetreten) {
        Write-Host "  [PASS] Main.ps1 ist kontrolliert gescheitert (Exit-Code: $LASTEXITCODE)" -ForegroundColor Green
        $pass++
    }
    else {
        Write-Host "  [FAIL] Main.ps1 lief durch obwohl Datei fehlt" -ForegroundColor Red
        $fail++
    }
}
finally {
    # --- Aufräumen: Original-CSV wiederherstellen ---
    if (Test-Path $BackupCsv) {
        Copy-Item $BackupCsv $OriginalCsv -Force
        Remove-Item $BackupCsv -Force
        Write-Host "`n[INFO] Original-CSV wiederhergestellt." -ForegroundColor DarkGray
    }
}

# --- Zusammenfassung ---
Write-Host "`n--- Zusammenfassung ---" -ForegroundColor Yellow
Write-Host ("Bestanden     : {0}" -f $pass) -ForegroundColor Green
Write-Host ("Fehlgeschlagen: {0}" -f $fail) -ForegroundColor $(if ($fail -eq 0) { 'Green' } else { 'Red' })
Write-Host ("Gesamt        : {0}" -f ($pass + $fail))

return [PSCustomObject]@{ Pass = $pass; Fail = $fail }