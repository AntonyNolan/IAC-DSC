#Install xActiveDirectory
Install-Module xActiveDirectory -Confirm:$false

#Obtain Self Signed Cert
$cert = Invoke-Command -scriptblock { 
    Get-ChildItem Cert:\LocalMachine\my | 
    Where-Object {$_.Issuer -eq 'CN=GLOBOMANTICS-CERT-CA, DC=GLOBOMANTICS, DC=COM'}
    } -ComputerName DC4

if (-not (Test-Path c:\certs)){mkdir -Path c:\certs}
Export-Certificate -Cert $Cert -FilePath $env:systemdrive:\Certs\DC4.cer -Force     

#Copy xActiveDirectory
$params =@{
    Path = (Get-Module xActiveDirectory -ListAvailable).ModuleBase
    Destination = "$env:SystemDrive\Program Files\WindowsPowerShell\Modules\xActiveDirectory"
    ToSession = (New-PSSession -ComputerName DC4)
    Force = $true
    Recurse = $true
    Verbose = $true

}

Copy-Item @params

#Configure New Domain Controller LCM
psedit C:\GitHub\IAC-DSC\DemoScripts\Configurations\SecureLCM.ps1

#Promote New Domain Controller
psedit C:\GitHub\IAC-DSC\DemoScripts\Configurations\Push\GlobomanticsNewDomainController.ps1