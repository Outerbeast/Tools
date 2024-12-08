<# Ripent frontend with menu
-Outerbeast
#>
$optExport = New-Object System.Management.Automation.Host.ChoiceDescription '&Export', 'Export Entities'
$optImport = New-Object System.Management.Automation.Host.ChoiceDescription '&Import', 'Import Entities'
$optExit = New-Object System.Management.Automation.Host.ChoiceDescription '&Close', 'Close'

$menu = [System.Management.Automation.Host.ChoiceDescription[]]( 
    $optExport,
    $optImport,
    $optExit
)
$choice

function EntExport
{
    Get-ChildItem -Filter "$strBspName.bsp" | Foreach-Object {

        Write-Host "Exporting Ents: $_"
        .\Ripent_x64.exe -export $_.Name
    }

    Write-Host "Finished entity exports.`n"
}

function EntImport
{
    Get-ChildItem -Filter "$strBspName.bsp" | Foreach-Object {

        Write-Host "Importing Ents: $_"
        .\Ripent_x64.exe -import $_.Name
    }

    Write-Host "Finished entity imports.`n"

    $confirmation = Read-Host "Do you want to remove .ent files"

    if( $confirmation -eq 'y')
    {
        Get-ChildItem -Filter "$strBspName.ent" | Foreach-Object {

            Write-Host "Removing entity file: $_"
            Remove-Item $_
        }
    }
}

do
{
    $choice = $host.ui.PromptForChoice( "Ripent", "Select an option:", $menu, 0 )

    if( $choice -eq 2 )
    {
        exit
    }

    $strBspName = Read-Host "Enter the bsp name you want to ripent (leave blank to do all)"

    if( !$strBspName )
    {
        $strBspName = "*"
    }

    switch( $choice )
    {
        0 { EntExport }
        1 { EntImport }
        2 { exit }
    }
}
while( $choice -ne 2 )
