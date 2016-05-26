Configuration GlobomanticsCert
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
            Nodename = 'Cert'          
            Role = "PKI"             
            PsDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true
            Credential = (Get-Credential -UserName 'globomantics\duffneyj' -message 'Enter admin pwd')
        }                      
    )             
}

GlobomanticsCert -ConfigurationData $ConfigData -OutputPath c:\dsc

Set-DscLocalConfigurationManager -Path c:\dsc -Verbose -Force
Start-DscConfiguration -Path c:\dsc -Wait -Force -Verbose