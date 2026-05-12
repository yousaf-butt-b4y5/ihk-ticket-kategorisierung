function Get-Urgency {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Betreff,

        [Parameter(Mandatory = $true)]
        [string]$Beschreibung
    )

    $combined = "$Betreff $Beschreibung".ToLower()

    # Urgency = wie schnell muss reagiert werden?
    # 1 = Hoch (sofort), 2 = Mittel (heute), 3 = Niedrig (geplant)

    # Hohe Dringlichkeit: Arbeit steht still / Produktion / Sicherheit
    $hoch = @(
        'ausfall', 'funktioniert nicht', 'startet nicht', 'reagiert nicht',
        'blockiert', 'offline', 'gesperrt', 'kritisch', 'dringend',
        'produktion', 'virus', 'malware', 'phishing'
    )

    # Niedrige Dringlichkeit: Anfragen, Bestellungen, geplante Themen
    $niedrig = @(
        'frage', 'anfrage', 'bestellung', 'beschaffung', 'wunsch',
        'wie kann ich', 'anleitung', 'information', 'neuer mitarbeiter'
    )

    foreach ($keyword in $hoch) {
        if ($combined -like "*$keyword*") {
            return 1
        }
    }

    foreach ($keyword in $niedrig) {
        if ($combined -like "*$keyword*") {
            return 3
        }
    }

    # Default: alles dazwischen (z.B. "langsam", "flackert", einzelne Störung)
    return 2
}