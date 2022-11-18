<# AngelScript Error logger for Sven Co-op
Prints AngelScript errors in console window as they are run

Usage:-
Place SC_ASErrorLogger.exe into svencoop/logs/Angelscript and launch. You can create a shortcut to this.
Alternatively, put SC_ASErrorLogger.ps1 in the same dir, right click then select "Run with PowerShell"
#>
$Host.UI.RawUI.WindowTitle = "Sven Co-op AS Error Logger"

$path = [System.Environment]::CurrentDirectory
$filename = "AS_server_"
$date = Get-Date -Format "yyyy-MM-dd"
$errors = @( "ERROR", "WARNING", "fail", "null", "not found", "include" )

try
{
    Get-Content $path\$filename$date.log -Wait -ErrorAction Stop | Select-String -pattern $errors
}
catch
{
    Write-Warning "Log file $filename$date.log not found.`nPlease launch a map and try again." -WarningAction Inquire
}