function Get-Prioritaet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateRange(1, 3)]
        [int]$Urgency,

        [Parameter(Mandatory = $true)]
        [ValidateRange(1, 3)]
        [int]$Impact
    )

    # Urgency x Impact Matrix (siehe Doku Kap. 5.4)
    # U\I  | I=1 (Hoch) | I=2 (Mittel) | I=3 (Niedrig)
    # -----|------------|--------------|---------------
    # U=1  |    P1      |     P2       |     P3
    # U=2  |    P2      |     P3       |     P4
    # U=3  |    P3      |     P4       |     P5

    $matrix = @{
        '1,1' = 'P1'; '1,2' = 'P2'; '1,3' = 'P3'
        '2,1' = 'P2'; '2,2' = 'P3'; '2,3' = 'P4'
        '3,1' = 'P3'; '3,2' = 'P4'; '3,3' = 'P5'
    }

    $key = "$Urgency,$Impact"
    return $matrix[$key]
}