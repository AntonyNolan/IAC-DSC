# Installing DSC Resource Modules
Install-Module -Name xNetworking
Install-Module -Name xNetworking -Force
Install-Module -Name xNetworking -Scope CurrentUser -Force
Find-Module xActiveDirectory | Install-Module

# DSC Resource Module Locations
Get-Module -Name xnetworking -ListAvailable | select Name,Version,ModuleBase

#Finding DSC Resource Syntax & Properties
Get-DscResource xDNSServerAddress
Get-DscResource xDNSServerAddress | select -ExpandProperty Properties | ft -AutoSize
Get-DscResource xDNSServerAddress -Syntax