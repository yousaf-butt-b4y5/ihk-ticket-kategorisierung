<#
.SYNOPSIS
    Unit-Tests für Get-Kategorie (Keyword-basierte Klassifikation).
.NOTES
    Strategie: Äquivalenzklassen-Testing.
    Statt unendlich viele Strings zu testen, prüfen wir je einen
    Repräsentanten pro Output-Klasse sowie Spezialfälle der Logik.
#>

. (Join-Path $PSScriptRoot '..\src\Get-Kategorie.ps1')

# --- Test-Definitionen ---
$testfaelle = @(
    # --- Happy Path: jede Kategorie mindestens 1x ---
    @{ Betreff = 'WLAN-Ausfall Halle 3'; Beschreibung = 'Kein WLAN in Halle 3'; Erwartet = 'Netzwerk'; Beschreibung_Test = 'Netzwerk: WLAN-Keyword' }
    @{ Betreff = 'Drucker druckt nicht'; Beschreibung = 'Drucker reagiert nicht'; Erwartet = 'Hardware'; Beschreibung_Test = 'Hardware: Drucker-Keyword' }
    @{ Betreff = 'Outlook startet nicht'; Beschreibung = 'Fehlermeldung beim Start'; Erwartet = 'Software'; Beschreibung_Test = 'Software: Outlook-Keyword' }
    @{ Betreff = 'Passwort zuruecksetzen'; Beschreibung = 'Domaenen-Passwort vergessen'; Erwartet = 'Sicherheit'; Beschreibung_Test = 'Sicherheit: Passwort-Keyword' }
    @{ Betreff = 'Frage zur Telefonanlage'; Beschreibung = 'Wie Rufumleitung einrichten?'; Erwartet = 'Sonstige'; Beschreibung_Test = 'Sonstige: kein Keyword-Treffer' }

    # --- Reihenfolge-Logik: Sicherheit hat Vorrang vor Netzwerk ---
    @{ Betreff = 'AD-Konto gesperrt'; Beschreibung = 'Konto nach VPN-Login gesperrt'; Erwartet = 'Sicherheit'; Beschreibung_Test = 'Prioritaet: Sicherheit vor Netzwerk' }

    # --- Case-Insensitivity ---
    @{ Betreff = 'DRUCKER DEFEKT'; Beschreibung = 'GROSSBUCHSTABEN TEST'; Erwartet = 'Hardware'; Beschreibung_Test = 'Case-Insensitivity: Grossbuchstaben' }

    # --- Keyword nur in Beschreibung, nicht im Betreff ---
    @{ Betreff = 'Problem'; Beschreibung = 'Mein VPN funktioniert nicht'; Erwartet = 'Netzwerk'; Beschreibung_Test = 'Keyword nur in Beschreibung' }

    # --- Keyword nur im Betreff, nicht in Beschreibung ---
    @{ Betreff = 'M365 Lizenz fehlt'; Beschreibung = 'Bitte pruefen'; Erwartet = 'Software'; Beschreibung_Test = 'Keyword nur im Betreff' }

    # --- Edge Case: Text ohne IT-Bezug ---
    @{ Betreff = 'Hallo'; Beschreibung = 'Wie geht es?'; Erwartet = 'Sonstige'; Beschreibung_Test = 'Fallback: kompletter Random-Text' }
)

# --- Tests ausführen ---
$pass = 0
$fail = 0

Write-Host "`n=== Tests: Get-Kategorie ===" -ForegroundColor Cyan

foreach ($t in $testfaelle) {
    $ergebnis = Get-Kategorie -Betreff $t.Betreff -Beschreibung $t.Beschreibung

    if ($ergebnis -eq $t.Erwartet) {
        Write-Host ("  [PASS] -> {0,-10}  ({1})" -f $ergebnis, $t.Beschreibung_Test) -ForegroundColor Green
        $pass++
    }
    else {
        Write-Host ("  [FAIL] erwartet {0}, erhalten {1}  ({2})" -f $t.Erwartet, $ergebnis, $t.Beschreibung_Test) -ForegroundColor Red
        Write-Host ("         Input: Betreff='{0}' Beschreibung='{1}'" -f $t.Betreff, $t.Beschreibung) -ForegroundColor DarkGray
        $fail++
    }
}

# --- Zusammenfassung ---
Write-Host "`n--- Zusammenfassung ---" -ForegroundColor Yellow
Write-Host ("Bestanden     : {0}" -f $pass) -ForegroundColor Green
Write-Host ("Fehlgeschlagen: {0}" -f $fail) -ForegroundColor $(if ($fail -eq 0) { 'Green' } else { 'Red' })
Write-Host ("Gesamt        : {0}" -f ($pass + $fail))
return [PSCustomObject]@{ Pass = $pass; Fail = $fail }