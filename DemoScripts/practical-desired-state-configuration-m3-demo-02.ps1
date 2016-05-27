$Session = New-PSSession -ComputerName Cert

#load custom cmdlet, create self signed cert
PSEdit C:\GitHub\IAC-DSC\Helper-Functions\New-SelfSignedCertificateEx.ps1

Enter-PSSession -Session $Session

New-SelfSignedCertificateEx -Subject 'CN=Cert' -StoreLocation LocalMachine -StoreName My -EnhancedKeyUsage "Document Encryption" -FriendlyName SelfSigned

Exit-PSSession

#Get cert info and export to authoring machine
$cert = Invoke-Command -scriptblock { 
     Get-ChildItem Cert:\LocalMachine\my | 
     Where-Object {$_.FriendlyName -eq 'SelfSigned'}
     } -computername cert

$cert

Export-Certificate -Cert $cert -FilePath C:\Certs\cert.cer -Force