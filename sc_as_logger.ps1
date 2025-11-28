<# AngelScript Error logger for Sven Co-op
Prints AngelScript errors in console window as they are run

Usage:-
- Place in your workspace
- Edit the "$path" so it matches the path to your Angelscript log folder
- Open a new IDE terminal
- Launch the script via powershell ".\sc_error_logger"
#>
$Host.UI.RawUI.WindowTitle = "Sven Co-op AS Error Logger"

$path = "B:\Games\Steam\steamapps\common\Sven Co-op\svencoop\logs\Angelscript\"
$filename = "AS_server_"
$date = Get-Date -Format "yyyy-MM-dd"
$errors = @( "ERROR", "WARNING", "fail", "null", "not found", "include" )

try
{
    Get-Content "$path\$filename$date.log" -Wait -ErrorAction Stop |
    ForEach-Object {
        if( $_ -match 'ERROR' )
        {
            Write-Host $_ -ForegroundColor Red
        }
        elseif( $_ -match 'WARNING' )
        {
            Write-Host $_ -ForegroundColor Yellow
        }
        elseif( $_ -like '*DEBUG*' )
        {
            Write-Host $_ -ForegroundColor Cyan
        }
        else
        {
            Write-Host $_
        }
    }
}
catch
{
    $msg = "WARNING: Log file $filename$date.log not found.`nPlease launch a map and try again."
    Write-Host $msg -ForegroundColor Yellow
}
