#Verify cert server
Get-ADComputer -Identity Cert
Test-Connection -ComputerName Cert

#load custom cmdlet, create self signed cert
. C:\GitHub\IAC-DSC\Helper-Functions\New-SelfSignedCertificateEx.ps1

Invoke-Command -Session $Session -ScriptBlock ${
function:New-SelfSignedCertificateEx -Subject 'CN=Cert' -StoreLocation LocalMachine -StoreName My -EnhancedKeyUsage 'Document Encryption' -FriendlyName SelfSigned
}

#Get cert info and export to authoring machine
$cert = Invoke-Command -scriptblock { 
     Get-ChildItem Cert:\LocalMachine\my | 
     Where-Object {$_.FriendlyName -eq 'SelfSigned'}
     } -computername cert

Export-Certificate -Cert $cert -FilePath C:\Certs\cert.cer