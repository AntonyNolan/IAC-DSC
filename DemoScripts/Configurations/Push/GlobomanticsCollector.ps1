configuration GlobomanticsCollector {
  
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xWindowsEventForwarding
    Import-DscResource -ModuleName xNetworking

    node $AllNodes.NodeName
    {
        Windowsfeature RSATADPowerShell{
                Ensure = 'Present'
                Name = 'RSAT-AD-PowerShell'
        }

        xFirewall RemoteLogManagement {
            Name = 'EventLog-Forwarding'
            Group = 'Remote Event Log Management'
            Ensure = 'Present'
            Enabled = 'True'
            Action = 'Allow'
            Profile = 'Domain'
        }

        xFirewall EventMonitor {
            Name = 'Remote Event Monitor'
            Group = 'Remote Event Monitor'
            Ensure = 'Present'
            Enabled = 'True'
            Action = 'Allow'
            Profile = 'Domain'
    }

        xWEFCollector Enabled {
            Ensure = "Present"
            Name = "Enabled"
        }

        xWEFSubscription ADSecurity
        {
            SubscriptionID = "ADSecurity"
            Ensure = "Present"
            LogFile = 'ForwardedEvents'
            SubscriptionType = 'CollectorInitiated'
            Address = (Get-ADGroupMember 'Domain Controllers' | % {Get-ADComputer -Identity $_.SID}).DNSHostName
            DependsOn = "[xWEFCollector]Enabled","[WindowsFeature]RSATADPowerShell"
            Query = @('Security:*')
        }      
    }
}

$ConfigData = @{             
    AllNodes = @(             
        @{             
            NodeName = 'Collector'          
            PSDscAllowDomainUser = $true
        }                
    )             
}  

$cim = New-CimSession -ComputerName Collector

GlobomanticsCollector -ConfigurationData $ConfigData -OutputPath c:\DSC\

Start-DscConfiguration -CimSession $cim -path c:\DSC\ -Wait -Force -Verbose