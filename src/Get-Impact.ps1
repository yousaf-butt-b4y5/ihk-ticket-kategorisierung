function Get-Impact {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Betreff,

        [Parameter(Mandatory = $true)]
        [string]$Beschreibung
    )

    $combined = "$Betreff $Beschreibung".ToLower()

    # Impact = wie viele Benutzer / wie viel Geschäftsbetrieb betroffen?
    # 1 = Hoch (Team/Abteilung/Halle), 2 = Mittel (mehrere User), 3 = Niedrig (Einzelperson)

    # Hoher Impact: ganze Bereiche, mehrere Personen, Produktion
    $hoch = @(
        'halle', 'gesamten', 'gesamte', 'alle', 'mehrere kollegen', 'team',
        'abteilung', 'produktion', 'bürogebäude', 'buerogebaeude',
        'vertriebsteam', 'produktionsbereich', 'standort'
    )

    # Niedriger Impact: explizit nur eine Person
    $niedrig = @(
        'mein ', 'meine ', 'meinen ', 'ich ', 'mir ', 'arbeitsplatz',
        'einzelner', 'einzelne'
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

    return 2
}