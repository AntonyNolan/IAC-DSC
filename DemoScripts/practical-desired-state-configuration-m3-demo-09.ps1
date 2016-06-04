Configuration ServerAdminsGroup {
    Param (
        [Parameter(Mandatory=$true)]
        [PSCredential]$Credential
    )
    
    Node $AllNodes.NodeName
    {
        Group TestGroup{
            GroupName = 'ServerAdmins'
            Members = 'globomantics\duffneyj'
            Ensure = 'Present'
            Credential = $Credential
        }
    }
}

$configdata = @{
    AllNodes = @(
     @{
      NodeName = 's2'
      Certificatefile = 'c:\certs\s1.cer'
     }
    )
}

#Generate Secure .mof  
ServerAdminsGroup -ConfigurationData $ConfigData -OutputPath c:\dsc\s2

#establish cim and PS sessions
$cim = New-CimSession -ComputerName $ConfigData.AllNodes.NodeName
$PullSession = New-PSSession -ComputerName pull

#stage pull config on pullserver
$guid = Get-DscLocalConfigurationManager -CimSession $cim | Select-Object -ExpandProperty ConfigurationID

$source = "C:\DSC\push\$($ConfigData.AllNodes.NodeName).mof"
$dest = "$Env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"

Copy-Item -Path $source -Destination $dest -ToSession $PullSession -force -verbose

Invoke-Command $PullSession -ScriptBlock {Param($ComputerName,$guid)Rename-Item $env:ProgramFiles\WindowsPowerShell\DscService\Configuration\$ComputerName.mof -NewName $env:ProgramFiles\WindowsPowerShell\DscService\Configuration\$guid.mof} -ArgumentList $($ConfigData.AllNodes.NodeName),$guid
Invoke-Command $PullSession -ScriptBlock {Param($dest)New-DSCChecksum $dest -Force} -ArgumentList $dest

#invoke pull
Update-DscConfiguration -CimSession $cim -Wait -Verbose

#Query group memberships
Invoke-Command s2 -ScriptBlock {net localgroup serveradmins}