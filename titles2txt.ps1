<# titles2txt.ps1 - Convert titles.txt to titles.ent for use in the game.
    Use for changeing env_message titles file to discreet game_text entities
    Usage:-
    - Place the script in the same directory as titles.txt.
    - Run the script from PowerShell or Command Prompt.
    - The converted file will be saved as titles.ent
    - titles.ent contains the game_text entities which can be imported to a BSP via ripent
- Outerbeast
#>
$titlesPath = ".\titles.txt"
$outPath    = ".\titles.ent"
$lines = Get-Content $titlesPath
# Current style dictionary
$style = @{
    x = "-1"
    y = "-1"
    effect = "0"
    color = "255 255 255"
    color2 = "255 255 255"
    fadein = "0.5"
    fadeout = "0.5"
    holdtime = "2"
    fxtime = "0"
}

$entries = @()
$currentTitle = $null
$currentMessage = @()
$inBlock = $false

function CreateGameText($title, $msg, $style)
{
    $entity = "{`n"
    $entity += '"classname" "game_text"' + "`n"
    $entity += '"targetname" "' + $title + '"' + "`n"
    $entity += '"message" "' + $msg + '"' + "`n"

    foreach( $k in $style.Keys )
    {
        $entity += '"' + $k + '" "' + $style[$k] + '"' + "`n"
    }

    $entity += "}`n"

    return $entity
}

foreach( $raw in $lines )
{
    $line = $raw.Trim()
    # Skip comments
    if( $line.StartsWith( "//" ) )
    {
        continue
    }
    # Handle style commands
    if( $line.StartsWith( "$" ) )
    {
        $parts = $line.Split( " ", 2, "RemoveEmptyEntries" )
        $cmd = $parts[0].Substring( 1 )   # remove $
        $value = $parts[1]

        switch( $cmd )
        {
            "position"
            {
                $xy = $value.Split( " " )
                $style["x"] = $xy[0]
                $style["y"] = $xy[1]
            }

            "color"
            {
                $style["color"] = $value
            }

            "color2"
            {
                $style["color2"] = $value
            }

            "effect"
            {
                $style["effect"] = $value
            }

            "fadein"
            {
                $style["fadein"] = $value
            }

            "fadeout"
            {
                $style["fadeout"] = $value
            }

            "holdtime"
            {
                $style["holdtime"] = $value
            }

            "fxtime"
            {
                $style["fxtime"] = $value
            }
        }

        continue
    }
    # Start of message block
    if( $line -eq "{" )
    {
        $inBlock = $true
        continue
    }
    # End of message block
    if( $line -eq "}" )
    {
        if( $currentTitle )
        {
            $msg = ( $currentMessage -join "\n" )
            $entries += CreateGameText $currentTitle $msg $style
        }

        $currentTitle = $null
        $currentMessage = @()
        $inBlock = $false

        continue
    }
    # Inside message block
    if( $inBlock )
    {
        $currentMessage += $line
        continue
    }
    # Title name
    if( $line -ne "" )
    {
        $currentTitle = $line
        continue
    }
}
# Write output
$entries | Set-Content $outPath
Write-Host "Done! Output written to $outPath"
