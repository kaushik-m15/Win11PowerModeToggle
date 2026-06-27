# Win11PowerModeToggle
Changes toggles the (overlay) power mode between "Balanced" and "High Performance", or whichever GUID you specify, and displays an overlay at the bottom.

The executable has been provided in *Releases* in case you want to prevent the PowerShell window from appearing. You can use the following commands in PowerShell if you want to compile the .exe yourself:

```Powershell
Install-Module -Name ps2exe -Scope CurrentUser -Force
Invoke-ps2exe -inputFile "Path:\To\PowerMode.ps1" -outputFile "Path:\To\PowerMode.exe" -noConsole
```
