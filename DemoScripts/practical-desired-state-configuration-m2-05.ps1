$cim1 = New-CimSession -ComputerName "PS-S01"
$cim2 = New-CimSession -ComputerName "PS-S02"

Test-DscConfiguration -CimSession $cim1
Test-DscConfiguration -CimSession $cim2

Get-DscConfiguration -CimSession $cim1
Get-DscConfiguration -CimSession $cim2

Get-DscConfigurationStatus -CimSession $cim1
Get-DscConfigurationStatus -CimSession $cim2