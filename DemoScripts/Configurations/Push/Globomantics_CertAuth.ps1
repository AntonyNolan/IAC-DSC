Configuration GlobomanticsCertAuth
{        

    Import-DscResource -ModuleName xAdcsDeployment,PSDesiredStateConfiguration,xNetworking,xComputerManagement,xTimeZone
    
    Node $AllNodes.Where{$_.Role -eq "PKI"}.Nodename
    {  
        LocalConfigurationManager            
        {            
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyAndAutoCorrect'            
            RebootNodeIfNeeded = $true            
        }          
        
        xTimeZone SystemTimeZone {
            TimeZone = 'Central Standard Time'
            IsSingleInstance = 'Yes'

        }

        If ((gwmi win32_computersystem).partofdomain -eq $false){
            xComputer NewName {
                Name = $Node.MachineName
                DomainName = $Node.DomainName
                Credential = $Node.Credential
                DependsOn = '[xDNSServerAddress]DnsServerAddress'
            }
        }

        xIPAddress NewIPAddress
        {
            IPAddress      = $Node.IPAddress
            InterfaceAlias = "Ethernet"
            SubnetMask     = 24
            AddressFamily  = "IPV4"
 
        }

        xDefaultGatewayAddress NewDefaultGateway
        {
            AddressFamily = 'IPv4'
            InterfaceAlias = 'Ethernet'
            Address = $Node.DefaultGateway
            DependsOn = '[xIPAddress]NewIpAddress'

        }
        
        xDNSServerAddress DnsServerAddress
        {
            Address        = $Node.DNSIPAddress
            InterfaceAlias = 'Ethernet'
            AddressFamily  = 'IPV4'
        }
        
        WindowsFeature ADCS-Cert-Authority {
               Ensure = 'Present'
               Name = 'ADCS-Cert-Authority'
        }

        WindowsFeature RSAT-ADCS {
            Ensure = 'Present'
            Name = 'RSAT-ADCS'
            IncludeAllSubFeature = $true
            DependsOn = '[WindowsFeature]ADCS-Cert-Authority'
        }
        
        xADCSCertificationAuthority ADCS {
            Ensure = 'Present'
            Credential = $Node.Credential
            CAType = 'EnterpriseRootCA'
            DependsOn = '[WindowsFeature]ADCS-Cert-Authority'              
        }
        
        WindowsFeature ADCS-Web-Enrollment {
            Ensure = 'Present'
            Name = 'ADCS-Web-Enrollment'
            DependsOn = '[WindowsFeature]ADCS-Cert-Authority'
        }
        
        xADCSWebEnrollment CertSrv {
            Ensure = 'Present'
            Name = 'CertSrv'
            Credential = $Node.Credential
            DependsOn = '[WindowsFeature]ADCS-Web-Enrollment','[xADCSCertificationAuthority]ADCS'
        }
        
        WindowsFeature Web-Mgmt-Console {
            Ensure = 'Present'
            Name = 'Web-Mgmt-Console'
            IncludeAllSubFeature = $true            
        }         
    }  
}


$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = $env:COMPUTERNAME          
            MachineName = 'PS-Cert01'
            Role = "PKI"             
            DomainName = "globomantics"
            PsDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true
            IPAddress = '192.168.2.3'
            DefaultGateway = '192.168.2.1'
            DNSIPAddress = '192.168.2.2'
            Credential = (Get-Credential -UserName 'globomantics\administrator' -message 'Enter admin pwd')
        }                      
    )             
}

GlobomanticsCertAuth -ConfigurationData $ConfigData -OutputPath c:\dsc

Set-DscLocalConfigurationManager -Path c:\dsc -Verbose -Force
Start-DscConfiguration -Path c:\dsc -Wait -Force -Verbose