#Install xWindowsEventForwarding
if (-not (Get-Module xWindowsEventForwarding -ListAvailable)){Install-Module xWindowsEventForwarding -Confirm:$false}

psedit C:\GitHub\IAC-DSC\DemoScripts\Configurations\Push\GlobomanticsCollector.ps1