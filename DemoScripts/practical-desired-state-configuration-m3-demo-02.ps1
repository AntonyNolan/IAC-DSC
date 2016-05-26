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
. C:\GitHub\IAC-DSC\Helper-Functions\New-SelfSignedCertificateEx.ps1

Invoke-Command -Session $Session -ScriptBlock {
    New-SelfSignedCertificateEx -Subject 'CN=Cert' -StoreLocation LocalMachine -StoreName My -EnhancedKeyUsage 'Document Encryption' -FriendlyName SelfSigned
}

$cert = Invoke-Command -scriptblock { 
     Get-ChildItem Cert:\LocalMachine\my | 
     Where-Object {$_.FriendlyName -eq 'SelfSigned'}
     } -computername cert

Export-Certificate -Cert $cert -FilePath C:\Certs\cert.cer

[DSCLocalConfigurationManager()]
Configuration LCM_SelfSigned
{
    param
        (
            [Parameter(Mandatory=$true)]
            [string[]]$ComputerName,

            [Parameter(Mandatory=$true)]
            [string]$guid,

            [Parameter(Mandatory=$true)]
            [string]$thumbprint

        )
	Node $ComputerName {

		Settings {

			AllowModuleOverwrite = $True
		    ConfigurationMode = 'ApplyAndAutoCorrect'
			RefreshMode = 'Push'
			ConfigurationID = $guid
            CertificateID = $thumbprint
            }
	}
}

$cim = New-CimSession -ComputerName $Session.ComputerName

$guid=[guid]::NewGuid()

LCM_SelfSigned -ComputerName $Session.ComputerName `
-Guid $guid -Thumbprint $Cert.Thumbprint -OutputPath c:\DSC\Cert

Set-DscLocalConfigurationManager -CimSession $cim -Path C:\dsc\Cert -Verbose

psEdit C:\GitHub\IAC-DSC\DemoScripts\Configurations\Push\Globomantics_Cert.ps1

Start-DscConfiguration -CimSession $cim -Path c:\dsc\cert -Wait -Force -Verbose