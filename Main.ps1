<#
.SYNOPSIS
    Automatisierte Ticket-Kategorisierung und Priorisierung.

.DESCRIPTION
    Liest Tickets aus einer CSV-Datei, ermittelt für jedes Ticket
    Kategorie, Urgency, Impact und Priorität (P1-P5) und exportiert
    das Ergebnis in eine neue CSV-Datei.

.NOTES
    IHK-Projektarbeit FISI AP2 - Sommer 2026
#>

# --- Konfiguration ---
$ScriptRoot = $PSScriptRoot
$InputFile = Join-Path $ScriptRoot 'data\input\tickets_input.csv'
$OutputFile = Join-Path $ScriptRoot 'data\output\tickets_output.csv'

# --- Funktionen einbinden (Dot-Sourcing) ---
. (Join-Path $ScriptRoot 'src\Get-Kategorie.ps1')
. (Join-Path $ScriptRoot 'src\Get-Urgency.ps1')
. (Join-Path $ScriptRoot 'src\Get-Impact.ps1')
. (Join-Path $ScriptRoot 'src\Get-Prioritaet.ps1')

# --- Hauptverarbeitung ---
try {
    if (-not (Test-Path $InputFile)) {
        throw "Eingabedatei nicht gefunden: $InputFile"
    }

    Write-Host "Lese Tickets ein aus: $InputFile" -ForegroundColor Cyan
    $tickets = Import-Csv -Path $InputFile -Delimiter ';' -Encoding UTF8

    if ($tickets.Count -eq 0) {
        throw "Eingabedatei enthält keine Tickets."
    }

    Write-Host "Verarbeite $($tickets.Count) Tickets..." -ForegroundColor Cyan

    $ergebnis = foreach ($ticket in $tickets) {
        $kategorie = Get-Kategorie  -Betreff $ticket.Betreff -Beschreibung $ticket.Beschreibung
        $urgency = Get-Urgency    -Betreff $ticket.Betreff -Beschreibung $ticket.Beschreibung
        $impact = Get-Impact     -Betreff $ticket.Betreff -Beschreibung $ticket.Beschreibung
        $prio = Get-Prioritaet -Urgency $urgency        -Impact       $impact

        [PSCustomObject]@{
            TicketID     = $ticket.TicketID
            Betreff      = $ticket.Betreff
            Beschreibung = $ticket.Beschreibung
            Meldender    = $ticket.Meldender
            Abteilung    = $ticket.Abteilung
            Quelle       = $ticket.Quelle
            Standort     = $ticket.Standort
            ErstelltAm   = $ticket.ErstelltAm
            Kategorie    = $kategorie
            Urgency      = $urgency
            Impact       = $impact
            Prioritaet   = $prio
        }
    }

    # Output-Ordner ggf. anlegen
    $outDir = Split-Path $OutputFile -Parent
    if (-not (Test-Path $outDir)) {
        New-Item -ItemType Directory -Path $outDir -Force | Out-Null
    }

    $ergebnis | Export-Csv -Path $OutputFile -Delimiter ';' -Encoding UTF8 -NoTypeInformation

    Write-Host "Fertig. Ergebnis geschrieben nach: $OutputFile" -ForegroundColor Green

    # --- Statistik-Ausgabe in der Konsole ---
    Write-Host "`n--- Verteilung nach Priorität ---" -ForegroundColor Yellow
    $ergebnis | Group-Object Prioritaet | Sort-Object Name | Format-Table Name, Count -AutoSize

    Write-Host "--- Verteilung nach Kategorie ---" -ForegroundColor Yellow
    $ergebnis | Group-Object Kategorie | Sort-Object Count -Descending | Format-Table Name, Count -AutoSize
}
catch {
    Write-Host "FEHLER: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}