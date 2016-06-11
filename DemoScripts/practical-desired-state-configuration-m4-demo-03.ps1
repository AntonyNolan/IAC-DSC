Configuration Baseline {
    Param (
        [Parameter(Mandatory=$true)]
        [PSCredential]$Password
    )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xNetworking -ModuleVersion 2.8.0.0


    Node $AllNodes.NodeName
    {

        User LocalAdmin {
            Ensure = 'Present'
            UserName = 'LocalAdmin'
            Description = 'Local Administrator Account'
            Disabled = $false
            Password = $Password
        }

        Group Administrators {
            GroupName = 'Administrators'
            Members = 'LocalAdmin'
            Ensure = 'Present'
            DependsOn = '[User]LocalAdmin'
        }

        Service RemoteRegistry {
            Ensure = 'Present'
            StartupType = 'Automatic'
            State = 'Running'
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

        Log Baseline {
            Message = 'Baseline configuration complete'
            DependsOn = '[Service]RemoteRegistry','[Group]Administrators','[xFirewall]EventMonitor','[xFirewall]RemoteLogManagement'
        }


    }
}

$configdata = @{
    AllNodes = @(
     @{
      NodeName = 's2'
      Certificatefile = 'c:\certs\s2.cer'
      PSDscAllowDomainUser = $true
     }
    )
}

#Generate Secure .mof  
Baseline -ConfigurationData $ConfigData `
-password (Get-Credential -UserName LocalAdmin -Message 'Enter Password') `
-OutputPath c:\dsc\s2

#establish cim and PS sessions
$cim = New-CimSession -ComputerName s2
$PullSession = New-PSSession -ComputerName pull

#stage pull config on pullserver
$guid = Get-DscLocalConfigurationManager -CimSession $cim | Select-Object -ExpandProperty ConfigurationID

$source = "C:\DSC\s2\$($ConfigData.AllNodes.NodeName).mof"
$dest = "$Env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"

Copy-Item -Path $source -Destination $dest -ToSession $PullSession -force -verbose

Invoke-Command $PullSession -ScriptBlock {Param($ComputerName,$guid)Rename-Item $env:ProgramFiles\WindowsPowerShell\DscService\Configuration\$ComputerName.mof -NewName $env:ProgramFiles\WindowsPowerShell\DscService\Configuration\$guid.mof} -ArgumentList $($ConfigData.AllNodes.NodeName),$guid
Invoke-Command $PullSession -ScriptBlock {Param($dest)New-DSCChecksum $dest -Force} -ArgumentList $dest

psEdit "\\pull\C$\Program Files\WindowsPowerShell\DscService\Configuration\$guid.mof"

#invoke pull
Update-DscConfiguration -CimSession $cim -Wait -Verbose

#Query group memberships
Get-DscConfigurationStatus -CimSession $cim