function Get-Kategorie {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Betreff,

        [Parameter(Mandatory = $true)]
        [string]$Beschreibung
    )

    $combined = "$Betreff $Beschreibung".ToLower()

    # Reihenfolge entscheidet: spezifischere Kategorien zuerst (erster Treffer gewinnt)
    $kategorien = [ordered]@{
        'Sicherheit' = @('passwort', 'gesperrt', 'virus', 'malware', 'phishing', 'ad-konto', 'zugang', 'verschlüsselung', 'verschluesselung')
        'Netzwerk'   = @('vpn', 'wlan', 'internet', 'netzwerk', 'router', 'dns', 'ping')
        'Software'   = @('outlook', 'teams', 'excel', 'm365', 'citrix', 'sap', 'software', 'lizenz', 'anwendung', 'app', 'installation', 'update', 'programm')
        'Hardware'   = @('drucker', 'monitor', 'maus', 'notebook', 'bildschirm', 'tastatur', 'laptop', 'rechner', 'akku', 'headset', 'kabel')
    }

    foreach ($kat in $kategorien.Keys) {
        foreach ($keyword in $kategorien[$kat]) {
            if ($combined -like "*$keyword*") {
                return $kat
            }
        }
    }

    return 'Sonstige'
}