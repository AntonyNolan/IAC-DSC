#Discovering DSC Resource Modules
Find-Module -Includes DscResource
Find-Module -Tag DSC
Find-Module -Name *Networking*  -Includes DscResource

#Discovering DSC Resources
Find-DscResource
Find-DscResource -moduleName xNetworking
Find-DscResource | Where-Object Name -like *IP*
Find-DscResource -Name xIPAddress