Configuration ADUser {
    
    param (
        [string]$NodeName   
        )
    
    Import-DscResource –ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xActiveDirectory
    
    Node $AllNodes.Nodename  {           
        
        WindowsFeature ADDSTools            
        {             
            Ensure = "Present"             
            Name = "RSAT-ADDS"             
        }            
                    
        xADUser duffneyj {
            UserName = 'duffneyj'
            JobTitle = 'Senior Operations Engineer'
            UserPrincipalName = 'duffneyj@globomantics.com'
            Enabled = $true
            Ensure = 'Present'
            Password = $Node.Password
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $Node.DomainAdministratorCredential
            DependsOn = '[WindowsFeature]ADDSTools'
        }

        xADGroup Operations {
            GroupName = 'Operations'
            Category = 'Security'
            GroupScope = 'Global'
            Description = 'Role based group for Operations team members'
            Ensure = 'Present'
            Members = 'duffneyj'

        }                                                 
    }
}

$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = 'DC1'
            DomainName = 'globomantics.com'          
            Certificatefile = 'c:\certs\DC1.cer'
            Password = (Get-Credential -UserName duffneyj -Message 'Enter Password')
            DomainAdministratorCredential = (Get-Credential -UserName globomantics\administrator -Message "Domain Admin Credential")
            PSDscAllowDomainUser = $true     
        }
                      
    )             
} 

# Generate Configuration
ADUser -ConfigurationData $ConfigData -OutputPath c:\dsc\ADUser

Start-DscConfiguration -wait -force -Verbose -Path c:\dsc\ADUser

Get-ADUser -Identity duffneyj -Properties Title