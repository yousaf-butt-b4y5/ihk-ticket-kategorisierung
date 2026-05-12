<#
.SYNOPSIS
    Unit-Tests für Get-Impact (Auswirkungs-Bewertung).
.NOTES
    Strategie: Äquivalenzklassen-Testing.
    Output ist Integer (1=Hoch, 2=Mittel, 3=Niedrig).
    Drei logische Eingabe-Klassen: viele User / einzelne Person / unklar.
#>

. (Join-Path $PSScriptRoot '..\src\Get-Impact.ps1')

$testfaelle = @(
    # --- Klasse: HOCH (Output = 1) - viele User / ganze Bereiche betroffen ---
    @{ Betreff = 'WLAN-Ausfall Halle 3'; Beschreibung = 'Im gesamten Produktionsbereich kein WLAN'; Erwartet = 1; Beschreibung_Test = 'Hoch: Halle + gesamten' }
    @{ Betreff = 'Citrix-Sitzung laedt nicht'; Beschreibung = 'Mehrere Kollegen koennen sich nicht anmelden'; Erwartet = 1; Beschreibung_Test = 'Hoch: mehrere Kollegen' }
    @{ Betreff = 'Internetverbindung langsam'; Beschreibung = 'Die Internetverbindung im Buerogebaeude ist langsam'; Erwartet = 1; Beschreibung_Test = 'Hoch: Buerogebaeude (ganzer Standort)' }

    # --- Klasse: NIEDRIG (Output = 3) - einzelne Person betroffen ---
    @{ Betreff = 'Maus reagiert nicht'; Beschreibung = 'Die Maus an meinem Arbeitsplatz reagiert nicht'; Erwartet = 3; Beschreibung_Test = 'Niedrig: mein Arbeitsplatz' }
    @{ Betreff = 'Passwort vergessen'; Beschreibung = 'Ich habe mein Passwort vergessen'; Erwartet = 3; Beschreibung_Test = 'Niedrig: ich + mein' }

    # --- Klasse: DEFAULT/MITTEL (Output = 2) - kein klarer User-Hinweis ---
    @{ Betreff = 'Bildschirm flackert'; Beschreibung = 'Monitor zeigt unregelmaessige Bilder'; Erwartet = 2; Beschreibung_Test = 'Mittel: keine User-Keywords -> Default' }
    @{ Betreff = 'Drucker druckt nicht'; Beschreibung = 'Druckauftraege bleiben haengen'; Erwartet = 2; Beschreibung_Test = 'Mittel: kein "mein", kein "Halle" -> Default' }

    # --- Reihenfolge-Logik: HOCH gewinnt vor NIEDRIG ---
    @{ Betreff = 'WLAN-Stoerung in Halle 3'; Beschreibung = 'Mein Scanner funktioniert nicht'; Erwartet = 1; Beschreibung_Test = 'Prioritaet: Hoch (Halle) gewinnt vor Niedrig (mein)' }

    # --- Case-Insensitivity ---
    @{ Betreff = 'PRODUKTIONSAUSFALL'; Beschreibung = 'GESAMTE ABTEILUNG BETROFFEN'; Erwartet = 1; Beschreibung_Test = 'Case-Insensitivity: Grossbuchstaben' }
)

# --- Tests ausführen ---
$pass = 0
$fail = 0

Write-Host "`n=== Tests: Get-Impact ===" -ForegroundColor Cyan

foreach ($t in $testfaelle) {
    $ergebnis = Get-Impact -Betreff $t.Betreff -Beschreibung $t.Beschreibung

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