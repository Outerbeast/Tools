Add-Type -AssemblyName System.Windows.Forms
$Host.UI.RawUI.WindowTitle = "MOTDGen"
Write-Host "MOTDGen`nAutomatically create MOTD files for your maps`n`n"
$FilePath = Read-Host "Enter full path to your MOTD template file`n(leave blank to browse file manually)"

$strCurrentPath = 
if( $MyInvocation.InvocationName -eq "PSConsoleHostReadLine" )
{
    Get-Location
}
else
{
    $PSScriptRoot
}

if( !$FilePath )
{
    $openfile = [System.Windows.Forms.OpenFileDialog]@{
        Filter = 'txt files (*.txt)|*.txt'
    }

    $openfile.ShowDialog()
    $FilePath = $openfile.FileName
}

$strMOTDInfo = Get-Content $FilePath

if( $strMOTDInfo -ne '' -and $strMOTDInfo -ne 'Cancel' )
{
    Get-ChildItem -Path $strCurrentPath -Filter *.bsp | Foreach-Object {

        $strMOTDName = $_.BaseName
        $strFileExt = "_motd.txt"

        Copy-Item -Path $FilePath -Destination "$strMOTDName$strFileExt" -Force
    }
}