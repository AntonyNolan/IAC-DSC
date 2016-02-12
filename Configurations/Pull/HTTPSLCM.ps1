[DSCLocalConfigurationManager()]
Configuration LCM_HTTPSPULL
{
    param
        (
            [Parameter(Mandatory=$true)]
            [string[]]$ComputerName,

            [Parameter(Mandatory=$true)]
            [string]$guid

        )
	Node $ComputerName {

		Settings {

			AllowModuleOverwrite = $True
		           ConfigurationMode = 'ApplyAndAutoCorrect'
			RefreshMode = 'Pull'
			ConfigurationID = $guid
            CertificateID = 'BEC413EF926594141A1CA77B63EC54A33450A990'
            }

            ConfigurationRepositoryWeb DSCHTTPS {
                ServerURL = 'https://zpull01.zephyr.org:8080/PSDSCPullServer.svc'
                CertificateID = '59C31226752787FE0BAB37ECA23C14B4B9524A70'
                AllowUnsecureConnection = $False
            }
	}
}

$ComputerName = 'ZDC01'

$guid=[guid]::NewGuid()

LCM_HTTPSPULL -ComputerName $ComputerName -Guid $guid -OutputPath c:\DSC\HTTPS

Set-DscLocalConfigurationManager -CimSession $cim -Path C:\dsc\HTTPS
