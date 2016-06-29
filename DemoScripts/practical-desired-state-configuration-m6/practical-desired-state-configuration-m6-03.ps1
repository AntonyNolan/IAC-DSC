# Confirm DSC Configuration applied
$cim = New-CimSession -ComputerName DC4
Get-DscConfigurationStatus -CimSession $cim

#Start Event Viewer
Start-Process "c:\windows\system32\eventvwr.msc" -ArgumentList "/s"