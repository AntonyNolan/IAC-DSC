#Create PS session
$Session = New-PSSession -ComputerName Pull

#Install xAdcsDeployment from PSGallery
Install-Module xPSDesiredStateConfiguration

#Copy module to remote node
$params =@{
    Path = (Get-Module xPSDesiredStateConfiguration -ListAvailable).ModuleBase
    Destination = "$env:SystemDrive\Program Files\WindowsPowerShell\Modules\xAdcsDeployment"
    ToSession = $Session
    Force = $true
    Recurse = $true
    Verbose = $true

}

Copy-Item @params

Invoke-Command -Session $Session -ScriptBlock {Get-Module xAdcsDeployment -ListAvailable}

#Create secure DSC config
psEdit C:\GitHub\IAC-DSC\DemoScripts\Configurations\Push\Globomantics_HTTPSPullSecure.ps1