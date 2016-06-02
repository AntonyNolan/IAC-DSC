#Create PS Sessions
$Servers = 's1','s2'
foreach ($Server in $Servers)
{
    $Server = New-PSSession -ComputerName $Server -Name $Server
}
Get-PSSession

#Confirm Certificate was Issued
Invoke-Command -Session $s1,$s2 -ScriptBlock {Get-ChildItem Cert:\LocalMachine\My}

Invoke-Command -Session $s1 -ScriptBlock `
{Get-ChildItem Cert:\LocalMachine\My | select Thumbprint,Subject,Issuer}

Invoke-Command -Session $s1,$s2 -ScriptBlock `
{Get-ChildItem Cert:\LocalMachine\My | Where Issuer -eq 'CN=GLOBOMANTICS-CERT-CA, DC=GLOBOMANTICS, DC=COM'}

#Exporting Certificates
$certs = Invoke-Command -scriptblock { 
    Get-ChildItem Cert:\LocalMachine\my | 
    Where-Object {$_.Issuer -eq 'CN=GLOBOMANTICS-CERT-CA, DC=GLOBOMANTICS, DC=COM'}
    } -Session (Get-PSSession)

$certs

foreach ($Cert in $Certs)
{
    Export-Certificate -Cert $Cert -FilePath $env:systemdrive:\Certs\$($Cert.PSComputerName).cer -Force     
}
