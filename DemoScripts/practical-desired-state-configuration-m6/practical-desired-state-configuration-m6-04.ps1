#Install xActiveDirectory
Install-Module xActiveDirectory -Confirm:$false

#Obtain Self Signed Cert
$cert = Invoke-Command -scriptblock { 
    Get-ChildItem Cert:\LocalMachine\my | 
    Where-Object {$_.Issuer -eq 'CN=DC3'}
    } -ComputerName DC3

if (-not (Test-Path c:\certs)){mkdir -Path c:\certs}
Export-Certificate -Cert $Cert -FilePath $env:systemdrive:\Certs\DC3.cer -Force     

#Copy xActiveDirectory to DC3
$params =@{
    Path = (Get-Module xActiveDirectory -ListAvailable).ModuleBase
    Destination = "$env:SystemDrive\Program Files\WindowsPowerShell\Modules\xActiveDirectory"
    ToSession = (New-PSSession -ComputerName DC3)
    Force = $true
    Recurse = $true
    Verbose = $true

}

Copy-Item @params

#Promote DC3
psedit C:\GitHub\IAC-DSC\DemoScripts\Configurations\Push\GlobomanticsNewDomainController.ps1