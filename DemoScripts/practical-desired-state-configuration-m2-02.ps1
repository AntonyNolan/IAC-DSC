Configuration RenameComputer {
    param(
        [string]$NodeName,
        [string]$NewName
    )
    
    Import-DscResource -ModuleName xComputerManagement
    
    Node $AllNodes.NodeName {

        LocalConfigurationManager            
        {            
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyAndAutoCorrect'            
            RebootNodeIfNeeded = $true            
        }         
        
        xComputer NewName {
            Name = $Node.MachineName
        } #end xComputer resource
        
    } #end node block
    
} #end configuration

$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = 'WIN-6J22PI2U9RJ'
            NewName = 'PS-S01'            
        }                   
    )             
}  

RenameComputer -ConfigurationData $ConfigData -OutputPath c:\dsc\push

$cim = New-CimSession -ComputerName $ConfigData.AllNodes.NodeName

Set-DscLocalConfigurationManager -CimSession $cim -Path c:\dsc\push -Verbose -Force
Start-DscConfiguration -CimSession $cim -Path c:\dsc\push -Wait -Force -Verbose