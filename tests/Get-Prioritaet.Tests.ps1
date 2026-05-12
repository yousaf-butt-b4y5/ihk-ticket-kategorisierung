<#
.SYNOPSIS
    Unit-Tests für Get-Prioritaet (Urgency x Impact Matrix).
#>

# Funktion einbinden
. (Join-Path $PSScriptRoot '..\src\Get-Prioritaet.ps1')

# --- Test-Definitionen ---
# Format: @{ Urgency = X; Impact = Y; Erwartet = "PZ"; Beschreibung = "..." }
$testfaelle = @(
    @{ Urgency = 1; Impact = 1; Erwartet = 'P1'; Beschreibung = 'Kritisch: Hohe Urgency + Hoher Impact' }
    @{ Urgency = 1; Impact = 2; Erwartet = 'P2'; Beschreibung = 'Hohe Urgency + Mittlerer Impact' }
    @{ Urgency = 1; Impact = 3; Erwartet = 'P3'; Beschreibung = 'Hohe Urgency + Niedriger Impact' }
    @{ Urgency = 2; Impact = 1; Erwartet = 'P2'; Beschreibung = 'Mittlere Urgency + Hoher Impact' }
    @{ Urgency = 2; Impact = 2; Erwartet = 'P3'; Beschreibung = 'Standardfall (Mitte/Mitte)' }
    @{ Urgency = 2; Impact = 3; Erwartet = 'P4'; Beschreibung = 'Mittlere Urgency + Niedriger Impact' }
    @{ Urgency = 3; Impact = 1; Erwartet = 'P3'; Beschreibung = 'Niedrige Urgency + Hoher Impact' }
    @{ Urgency = 3; Impact = 2; Erwartet = 'P4'; Beschreibung = 'Niedrige Urgency + Mittlerer Impact' }
    @{ Urgency = 3; Impact = 3; Erwartet = 'P5'; Beschreibung = 'Minimal: Niedrige Urgency + Niedriger Impact' }
)

# --- Tests ausführen ---
$pass = 0
$fail = 0

Write-Host "`n=== Tests: Get-Prioritaet ===" -ForegroundColor Cyan

foreach ($t in $testfaelle) {
    $ergebnis = Get-Prioritaet -Urgency $t.Urgency -Impact $t.Impact

    if ($ergebnis -eq $t.Erwartet) {
        Write-Host ("  [PASS] U={0} I={1} -> {2}  ({3})" -f $t.Urgency, $t.Impact, $ergebnis, $t.Beschreibung) -ForegroundColor Green
        $pass++
    }
    else {
        Write-Host ("  [FAIL] U={0} I={1} -> erwartet {2}, erhalten {3}  ({4})" -f $t.Urgency, $t.Impact, $t.Erwartet, $ergebnis, $t.Beschreibung) -ForegroundColor Red
        $fail++
    }
}

# --- Zusammenfassung ---
Write-Host "`n--- Zusammenfassung ---" -ForegroundColor Yellow
Write-Host ("Bestanden : {0}" -f $pass) -ForegroundColor Green
Write-Host ("Fehlgeschlagen: {0}" -f $fail) -ForegroundColor $(if ($fail -eq 0) { 'Green' } else { 'Red' })
Write-Host ("Gesamt    : {0}" -f ($pass + $fail))
return [PSCustomObject]@{ Pass = $pass; Fail = $fail }