<# LazyRipent frontend with menu
    An even lazier way to use LazyRipent
    Simply place into your bsp folder and run the script.
    This requires the LazyRipent executable to be present on your system. This can be obtained from: https://github.com/Zode/Lazyripent2/releases/tag/v2.0.0
- Outerbeast
#>
$host.ui.RawUI.WindowTitle = "LazyRipent"
Write-Host $host.ui.RawUI.WindowTitle -BackgroundColor Green -ForegroundColor Black

$optExport = New-Object System.Management.Automation.Host.ChoiceDescription '&Extract', 'Extracts entity data into .ent file from a .bsp file'
$optImport = New-Object System.Management.Automation.Host.ChoiceDescription '&Import', 'Imports entity data from a .ent file into a .bsp file'
$optApplyRule = New-Object System.Management.Automation.Host.ChoiceDescription '&Rule', 'Modifies entity data using rulesets in a .bsp file'
$optExit = New-Object System.Management.Automation.Host.ChoiceDescription '&Close', 'Close'

$menu = [System.Management.Automation.Host.ChoiceDescription[]](

    $optExport,
    $optImport,
    $optApplyRule,
    $optExit
)

$exe = "lazyripent.exe"
$strDataPath = [Environment]::GetFolderPath('LocalApplicationData')
$strCurrentPath = 
if( $MyInvocation.InvocationName -eq "PSConsoleHostReadLine" )
{
    Get-Location
}
else
{
    $PSScriptRoot
}

class PathData
{
    static [string] $strRipentPath
}

function Init
{
    if( Test-Path -Path "$strDataPath\lazyripent_path.txt"  )
    {
        [PathData]::strRipentPath = ( Get-Content "$strDataPath\lazyripent_path.txt" -Raw ).Trim()

        if( ![PathData]::strRipentPath )
        {
            SearchLazyRipentInstall
        }
    }
    else
    {
        SearchLazyRipentInstall
    }
}

function SearchLazyRipentInstall
{
    Write-Host "Searching for LazyRipent install, please wait..." -ForegroundColor DarkGray

    $drives = ( get-psdrive | Where-Object { $_.provider -match 'FileSystem' } ).root
    $strRipentLocation = Get-ChildItem -Path $drives -Filter $exe -Recurse -ErrorAction SilentlyContinue -Force | Select-Object -First 1

    if( !$strRipentLocation )
    {
        Write-Error "LazyRipent executable not found.`n"
        Write-Host "Download and install LazyRipent first. You can download the latest version of LazyRipent here: https://github.com/Zode/Lazyripent2/releases/tag/v2.0.0"
        Write-Host "Press any key to continue..."
        [void][System.Console]::ReadKey( $true )
        Invoke-Item "https://github.com/Zode/Lazyripent2/releases/tag/v2.0.0"

        exit
    }
    else
    {
        [PathData]::strRipentPath = $strRipentLocation.Directory.FullName
        [PathData]::strRipentPath | Out-File -FilePath "$strDataPath\lazyripent_path.txt"
    }
}

function WrapString([string] $str, [char] $c)
{
    return "$c$str$c"
}

function DoRipent([string[]] $ARGS_IN)
{
    Write-Host "[$ARGS_IN]" -ForegroundColor DarkGray
    $path = [PathData]::strRipentPath
    & $path\$exe $ARGS_IN
}

function ExtractEntities([string] $strInput)
{
    if( $strInput -match ".bsp" )# has a file extension eg ".bsp"
    {
        $strInput = $strInput -replace "`"", ""
        $strEntOutput = [System.IO.Path]::ChangeExtension( $strInput, ".ent" )
        Write-Host "Extracting ents from bsp file: $strInput to $strEntOutput" -ForegroundColor DarkCyan
        $ARGUMENTS = @( "-i", $strInput, "-o", $strEntOutput, "-ee" )# extract ent from bsp and dump into same dir (I hope)
    }
    else
    {   # Whole dir
        if( !$strInput )
        {
            $strInput = $strCurrentPath
        }

        Write-Host "Extracting entity data from bsp files in the folder: $strInput" -ForegroundColor DarkCyan
        $ARGUMENTS = @( "-i", $strInput, "-o", $strInput, "-ee" )
    }

    DoRipent $ARGUMENTS
}

function ImportEntities([string] $strInput)
{
    if( $strInput -match ".bsp" )# has a file extension eg ".bsp"
    {
        $strInput = $strInput -replace "`"", ""
        $strEntOutput = [System.IO.Path]::ChangeExtension( $strInput, ".ent" )
        Write-Host "Importing entity data from ent file to bsp: $strInput" -ForegroundColor DarkCyan
        $ARGUMENTS = @( "-i", $strInput, "-i", $strEntOutput, "-o", $strInput, "-ie" )# import ent from bsp and dump into same dir (I hope)
    }
    else
    {   # Whole dir
        if( !$strInput )
        {
            $strInput = $strCurrentPath
        }

        Write-Host "Importing entity data from ent files in the folder: $strInput" -ForegroundColor DarkCyan
        $ARGUMENTS = @( "-i", $strInput, "-o", $strInput, "-ie" )
    }
    
    DoRipent $ARGUMENTS
}

function ApplyRule([string] $strRuleFile, [string] $strOutput)
{
    $ARGUMENTS = @()

    if( !$strOutput )
    {
        $strOutput = $strCurrentPath
    }

    if( $strRuleFile -match ".rule" )
    {
        Write-Host "Using rule file: $strRuleFile" -ForegroundColor DarkCyan
        $ARGUMENTS = @( "-i", $strRuleFile, "-i", $strOutput, "-o", $strOutput )
    }
    else
    {
        if( !$strRuleFile )
        {
            Get-ChildItem -Path $strCurrentPath -Filter "*.rule" | Foreach-Object {

                $rule = $_.FullName

                if( $ARGUMENTS -contains $rule )
                {
                    continue
                }

                $ARGUMENTS += "-i"
                $ARGUMENTS += $rule
                Write-Host "Using rule files from folder: $rule" -ForegroundColor DarkCyan
            }
        }
        else
        {
            Write-Host "Using rule files from folder: $strRuleFile" -ForegroundColor DarkCyan
        }

        $ARGUMENTS += @( "-i", $strOutput, "-o", $strOutput )
    }

    DoRipent $ARGUMENTS
}

Init

do
{
    $choice = $host.ui.PromptForChoice( "Extract, import and mass edit BSP entity data`n`n", "Select an option:", $menu, 0 )

    if( $choice -eq 3 )
    {
        exit
    }

    $strChoice = $menu[$choice].Label -replace "&", ""
    $strBspName = Read-Host "$strChoice > Drag or enter a bsp file or bsp folder (leave blank to use the current folder)`n"

    switch( $choice )
    {
        0
        {
            ExtractEntities $strBspName
            break
        }

        1
        {
            ImportEntities $strBspName
            break
        }

        2
        {
            $strSelectedRule = Read-Host "Drag or enter a rule file or rule folder (leave blank to use the current folder)`n"
            ApplyRule $strSelectedRule $strBspName

            break
        }

        3
        {
            exit
        }

        default
        {
            Write-Error "Invalid choice."
        }
    }
}
while( $choice -ne 3 )
