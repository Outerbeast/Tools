Add-Type -AssemblyName System.Windows.Forms
$Host.UI.RawUI.WindowTitle = "MOTDGen"
Write-Host "MOTDGen`nAutomatically create MOTD files for your maps`n`n"
$FilePath= Read-Host "Enter full path to your MOTD template file`n(leave blank to browse file manually)"

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
    $strCurrentPath = [System.Environment]::CurrentDirectory

    Get-ChildItem -Path $strCurrentPath -Filter *.bsp | Foreach-Object {

        $strMOTDName = $_.BaseName
        $strFileExt = "_motd.txt"

        New-Item -Name "$strMOTDName$strFileExt" -Path $strCurrentPath -ItemType "file" -Value $strMOTDInfo -Force
    }
}