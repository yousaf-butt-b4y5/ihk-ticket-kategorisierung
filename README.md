# IHK-Abschlussprojekt FISI (AP2) — Automatisierte Ticket-Kategorisierung

> **PowerShell-basierte Lösung zur Kategorisierung und Priorisierung von IT-Service-Desk-Tickets**
> IHK-Projektarbeit Sommer 2026, Fachinformatiker Systemintegration

---

## Inhalt

- [Projektziel](#projektziel)
- [Funktionsweise](#funktionsweise)
- [Projektstruktur](#projektstruktur)
- [Voraussetzungen](#voraussetzungen)
- [Verwendung](#verwendung)
- [Tests](#tests)
- [Technische Details](#technische-details)
- [Status & Metadaten](#status--metadaten)

---

## Projektziel

Im IT-Service-Desk werden eingehende Tickets bisher manuell kategorisiert und priorisiert. Das ist zeitintensiv und führt zu uneinheitlichen Ergebnissen.

Dieses Projekt automatisiert den Prozess: Tickets werden per Schlüsselwort-Logik einer Kategorie zugeordnet, Urgency und Impact werden regelbasiert ermittelt, und über eine 3×3-Matrix wird daraus die Priorität (P1–P5) berechnet.

---

## Funktionsweise

```text
tickets_input.csv  →  Main.ps1  →  tickets_output.csv
                          │
                          ├── Get-Kategorie    → Kategorie (Netzwerk/Hardware/Software/Sicherheit/Sonstige)
                          ├── Get-Urgency      → Urgency (1-3)
                          ├── Get-Impact       → Impact (1-3)
                          └── Get-Prioritaet   → Priorität (P1-P5)
```

**Datenfluss:** CSV einlesen → 4 Funktionen anwenden → erweiterte CSV exportieren.

---

## Projektstruktur

```text
ihk-ticket-kategorisierung/
├── Main.ps1                       # Hauptskript: Steuerung & I/O
├── src/
│   ├── Get-Kategorie.ps1          # Kategorisierung (Keyword-basiert)
│   ├── Get-Urgency.ps1            # Dringlichkeitsbewertung
│   ├── Get-Impact.ps1             # Auswirkungsbewertung
│   └── Get-Prioritaet.ps1         # Priorisierungs-Matrix
├── tests/
│   ├── Get-Kategorie.Tests.ps1
│   ├── Get-Urgency.Tests.ps1
│   ├── Get-Impact.Tests.ps1
│   ├── Get-Prioritaet.Tests.ps1
│   ├── Negativ.Tests.ps1          # Integrations-/Negativtests
│   └── Test-All.ps1               # Master-Test-Runner
└── data/
    ├── input/tickets_input.csv    # 18 simulierte Tickets
    └── output/tickets_output.csv  # Erzeugte Ausgabe
```

---

## Voraussetzungen

- **OS:** Windows 10/11 (oder Windows Server 2016+)
- **PowerShell:** Version 5.1 oder höher (entwickelt unter PowerShell 7.6.1)
- **Keine externen Module nötig** (PowerShell-nativ, kein Pester)

---

## Verwendung

### 1. Repository klonen

```powershell
git clone https://github.com/Surpriseb4y5/ihk-ticket-kategorisierung.git
cd ihk-ticket-kategorisierung
```

### 2. Skript ausführen

```powershell
.\Main.ps1
```

**Erwartete Ausgabe:**

```text
Lese Tickets ein aus: ...\data\input\tickets_input.csv
Verarbeite 18 Tickets...
Fertig. Ergebnis geschrieben nach: ...\data\output\tickets_output.csv

--- Verteilung nach Prioritaet ---
P1    2
P2    6
P3    4
P4    4
P5    2

--- Verteilung nach Kategorie ---
Software     7
Hardware     5
Netzwerk     3
Sicherheit   2
Sonstige     1
```

### 3. Eigene Daten verwenden

Eingabe-CSV `data/input/tickets_input.csv` mit folgenden Spalten (Semikolon-getrennt, UTF-8):

| Spalte | Beschreibung |
|---|---|
| TicketID | Eindeutige Ticket-Nummer |
| Betreff | Kurztitel |
| Beschreibung | Detailbeschreibung |
| Meldender | Name des Erstellers |
| Abteilung | Organisationseinheit |
| Quelle | Eingangskanal (Telefon/Mail/...) |
| Standort | Standortangabe |
| ErstelltAm | Erstellzeitpunkt |

---

## Tests

Das Projekt enthält **39 automatisierte Tests** in 5 Testdateien.

```powershell
.\tests\Test-All.ps1
```

**Erwartete Ausgabe:** `39/39 bestanden ✓`

### Testabdeckung

| Datei | Tests | Schwerpunkt |
|---|---|---|
| Get-Kategorie.Tests.ps1 | 10 | Äquivalenzklassen pro Kategorie + Edge Cases |
| Get-Urgency.Tests.ps1 | 9 | Hoch/Mittel/Niedrig + Reihenfolge-Logik |
| Get-Impact.Tests.ps1 | 9 | Hoch/Mittel/Niedrig + Reihenfolge-Logik |
| Get-Prioritaet.Tests.ps1 | 9 | Vollständige 3×3-Matrix |
| Negativ.Tests.ps1 | 2 | Leere CSV, fehlende Datei (Exit-Code 1) |

---

## Technische Details

### Priorisierungs-Matrix (Urgency × Impact → P1-P5)

|  | Impact 1 (hoch) | Impact 2 (mittel) | Impact 3 (niedrig) |
|---|---|---|---|
| **Urgency 1 (hoch)** | **P1** kritisch | P2 hoch | P3 mittel |
| **Urgency 2 (mittel)** | P2 hoch | P3 mittel | P4 niedrig |
| **Urgency 3 (niedrig)** | P3 mittel | P4 niedrig | **P5** minimal |

### Kategorien & Schlüsselwörter (vereinfacht)

| Kategorie | Beispiel-Keywords |
|---|---|
| Sicherheit | passwort, gesperrt, virus, ad-konto, phishing |
| Netzwerk | vpn, wlan, internet, dns, router |
| Software | outlook, teams, excel, m365, citrix, sap, lizenz |
| Hardware | drucker, monitor, notebook, tastatur, maus |
| Sonstige | (Fallback bei keinem Treffer) |

### Designentscheidungen

- **Reihenfolge der Kategorie-Prüfung:** Sicherheit zuerst (sicherheitsrelevante Tickets haben Vorrang), Hardware zuletzt (vermeidet Fehlklassifikation von Bestellungen).
- **Urgency vor Niedrig-Keywords:** Bei mehrdeutigen Tickets gewinnt die höhere Dringlichkeit (Vorsichtsprinzip).
- **Kein Pester:** Bewusst PowerShell-native Tests, ohne externe Modul-Abhängigkeit. Pester ist als Erweiterung im Ausblick dokumentiert.

---

## Status & Metadaten

| | |
|---|---|
| **Prüfling** | Yousaf Butt |
| **Identnummer** | 204494 |
| **IHK** | Nürnberg für Mittelfranken |
| **Prüfungstermin** | Sommer 2026 |
| **Projektumfang** | 40 Stunden |
| **Bearbeitungszeitraum** | 09.04.2026 – 20.05.2026 |
| **Status** | Abgeschlossen ✅ |
| **Tests** | 39/39 ✓ |

---

## Lizenz / Hinweis

Dieses Repository enthält die Implementierung einer IHK-Projektarbeit. Alle verwendeten Ticketdaten sind **simuliert** und enthalten keine personenbezogenen Daten im Sinne der DSGVO. Personennamen, Standorte und Abteilungen sind frei erfunden.
