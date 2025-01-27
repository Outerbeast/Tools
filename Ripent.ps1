<# Ripent frontend with menu
    Simply place into your bsp folder and run the script.
-Outerbeast
#>
$host.ui.RawUI.WindowTitle = "Ripent"
$optExport = New-Object System.Management.Automation.Host.ChoiceDescription '&Export', 'Extracts entity data into .ent file from a .bsp file'
$optImport = New-Object System.Management.Automation.Host.ChoiceDescription '&Import', 'Imports entity data from a .ent file into a .bsp file'
$optExit = New-Object System.Management.Automation.Host.ChoiceDescription '&Close', 'Close'

$menu = [System.Management.Automation.Host.ChoiceDescription[]]( 
    $optExport,
    $optImport,
    $optExit
)

$exe = if ( [Environment]::Is64BitProcess ) { "Ripent_x64.exe" } else { "Ripent.exe" }
$strDataPath = [Environment]::GetFolderPath('LocalApplicationData')

class PathData
{
    static [string] $strRipentPath
}

function Init
{
    if( Test-Path -Path "$strDataPath\ripent_path.txt"  )
    {
        [PathData]::strRipentPath = ( Get-Content "$strDataPath\ripent_path.txt" -Raw ).Trim()

        if( ![PathData]::strRipentPath )
        {
            SearchRipentInstall
        }
    }
    else
    {
        SearchRipentInstall
    }
}

function SearchRipentInstall
{
    Write-Host "Searching for Ripent install, please wait..." -ForegroundColor Gray

    $drives = ( get-psdrive | Where-Object { $_.provider -match 'FileSystem' } ).root
    $strRipentLocation = Get-ChildItem -Path $drives -Filter $exe -Recurse -ErrorAction SilentlyContinue -Force | Select-Object -First 1

    if( !$strRipentLocation )
    {
        Write-Error "Ripent executable not found.`nPlease manually set the path to your Sven Co-op addons folder, or reinstall Sven Co-op SDK and try again."
    }
    else
    {
        [PathData]::strRipentPath = $strRipentLocation.Directory.FullName
        [PathData]::strRipentPath | Out-File -FilePath "$strDataPath\ripent_path.txt"
    }
}

function RipEntities($action)
{
    $BSPS = @()

    Get-ChildItem -Filter "$strBspName.bsp" | Foreach-Object {

        $path = [PathData]::strRipentPath

        if( $action -eq 1 )
        {
            $s = [System.IO.Path]::ChangeExtension( $_.FullName, 'ent' )

            if( Test-Path -Path $s )
            {
                Write-Host "Importing entities into: $_`n"
                & "$path\$exe" -import $_.Name
                $BSPS += $_.FullName
            }
            else
            {
                Write-Warning "No .ent file to import for: $_. Skipping...`n"
            }
        }
        else
        {
            Write-Host "Exporting entities from: $_`n"
            & "$path\$exe" -export $_.Name
            $BSPS += $_.FullName
        }
    }

    $i = $BSPS.Length

    if( !$i )
    {
        Write-Host "No BSPs were processed.`n"
        return
    }
    else
    {
        Write-Host "$i BSPs processed.`n" -ForegroundColor Green
    }

    if( $action -ne 1 )
    {
        return
    }

    $confirmation = Read-Host "Do you want to remove .ent files?"

    if( $confirmation -eq 'y' )
    {
        Get-ChildItem -Filter "$strBspName.ent" | ForEach-Object {

            if( $BSPS -contains [System.IO.Path]::ChangeExtension( $_.FullName, 'bsp' ) )
            {
                Write-Host "Removing entity file: $_"
                $_
            }
        } | Remove-Item
    }
}

Init

do
{
    $choice = $host.ui.PromptForChoice( "Ripent`nExtract and Import BSP entity data`n`n", "Select an option:", $menu, 0 )

    if( $choice -eq 2 )
    {
        exit
    }

    $strBspName = Read-Host "Enter the bsp name you want to ripent (leave blank to do all)"

    if( !$strBspName )
    {
        $strBspName = "*"
    }

    if( $choice -eq 2 )
    {
        exit
    }
    else
    {
        RipEntities $choice
    }
}
while( $choice -ne 2 )
