#Verify & Test Cert Server
Get-ADComputer -Identity Cert
Test-Connection -ComputerName Cert
$Session = New-PSSession -ComputerName Cert

Install-Module xAdcsDeployment

$params =@{
    Path = (Get-Module xAdcsDeployment -ListAvailable).ModuleBase
    Destination = "$env:SystemDrive\Program Files\WindowsPowerShell\Modules\xAdcsDeployment"
    ToSession = $Session
    Force = $true
    Recurse = $true
    Verbose = $true

}

Copy-Item @params

Invoke-Command -Session $Session -ScriptBlock {Get-Module xAdcsDeployment -ListAvailable}

#load custom cmdlet into remote session
. .\New-SelfSignedCertificateEx
Invoke-Command -Session $Session -ScriptBlock {
    New-SelfSignedCertificateEx -Subject 'CN=Cert' -StoreLocation LocalMachine -StoreName My -EnhancedKeyUsage 'Document Encryption' -FriendlyName SelfSigned
}


$cert = Invoke-Command -scriptblock { 
     Get-ChildItem Cert:\LocalMachine\my | 
     Where-Object {$_.FriendlyName -eq 'SelfSigned'}
     } -computername cert

Export-Certificate -Cert $cert -FilePath C:\Certs\cert.cer
