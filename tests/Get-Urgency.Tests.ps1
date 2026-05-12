<#
.SYNOPSIS
    Unit-Tests für Get-Urgency (Dringlichkeits-Bewertung).
.NOTES
    Strategie: Äquivalenzklassen-Testing.
    Output ist Integer (1=Hoch, 2=Mittel, 3=Niedrig).
    Drei logische Eingabe-Klassen: hoch / niedrig / default.
#>

. (Join-Path $PSScriptRoot '..\src\Get-Urgency.ps1')

$testfaelle = @(
    # --- Klasse: HOCH (Output = 1) ---
    @{ Betreff = 'WLAN-Ausfall Halle 3'; Beschreibung = 'Produktion blockiert'; Erwartet = 1; Beschreibung_Test = 'Hoch: Ausfall + Produktion' }
    @{ Betreff = 'Drucker funktioniert nicht'; Beschreibung = 'Keine Etiketten druckbar'; Erwartet = 1; Beschreibung_Test = 'Hoch: funktioniert nicht' }
    @{ Betreff = 'AD-Konto gesperrt'; Beschreibung = 'Login unmoeglich'; Erwartet = 1; Beschreibung_Test = 'Hoch: gesperrt' }

    # --- Klasse: NIEDRIG (Output = 3) ---
    @{ Betreff = 'Bestellung neues Notebook'; Beschreibung = 'Anfrage fuer Werkstudent'; Erwartet = 3; Beschreibung_Test = 'Niedrig: Bestellung + Anfrage' }
    @{ Betreff = 'Frage zur Telefonanlage'; Beschreibung = 'Anleitung Rufumleitung gewuenscht'; Erwartet = 3; Beschreibung_Test = 'Niedrig: Frage + Anleitung' }

    # --- Klasse: DEFAULT/MITTEL (Output = 2) ---
    @{ Betreff = 'Bildschirm flackert'; Beschreibung = 'Monitor zeigt unregelmaessig'; Erwartet = 2; Beschreibung_Test = 'Mittel: keine Keywords -> Default' }
    @{ Betreff = 'Internetverbindung langsam'; Beschreibung = 'Webseiten laden traege'; Erwartet = 2; Beschreibung_Test = 'Mittel: nur "langsam" -> Default' }

    # --- Reihenfolge-Logik: HOCH gewinnt vor NIEDRIG ---
    @{ Betreff = 'Frage: Drucker ausgefallen'; Beschreibung = 'Anfrage zum Ausfall'; Erwartet = 1; Beschreibung_Test = 'Prioritaet: Hoch (ausfall) gewinnt vor Niedrig (frage)' }

    # --- Case-Insensitivity ---
    @{ Betreff = 'WLAN-AUSFALL'; Beschreibung = 'PRODUKTION BETROFFEN'; Erwartet = 1; Beschreibung_Test = 'Case-Insensitivity: Grossbuchstaben' }
)

# --- Tests ausführen ---
$pass = 0
$fail = 0

Write-Host "`n=== Tests: Get-Urgency ===" -ForegroundColor Cyan

foreach ($t in $testfaelle) {
    $ergebnis = Get-Urgency -Betreff $t.Betreff -Beschreibung $t.Beschreibung

    if ($ergebnis -eq $t.Erwartet) {
        Write-Host ("  [PASS] -> {0}  ({1})" -f $ergebnis, $t.Beschreibung_Test) -ForegroundColor Green
        $pass++
    }
    else {
        Write-Host ("  [FAIL] erwartet {0}, erhalten {1}  ({2})" -f $t.Erwartet, $ergebnis, $t.Beschreibung_Test) -ForegroundColor Red
        Write-Host ("         Input: Betreff='{0}' Beschreibung='{1}'" -f $t.Betreff, $t.Beschreibung) -ForegroundColor DarkGray
        $fail++
    }
}

Write-Host "`n--- Zusammenfassung ---" -ForegroundColor Yellow
Write-Host ("Bestanden     : {0}" -f $pass) -ForegroundColor Green
Write-Host ("Fehlgeschlagen: {0}" -f $fail) -ForegroundColor $(if ($fail -eq 0) { 'Green' } else { 'Red' })
Write-Host ("Gesamt        : {0}" -f ($pass + $fail))
return [PSCustomObject]@{ Pass = $pass; Fail = $fail }