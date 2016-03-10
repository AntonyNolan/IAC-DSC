function Publish-DSCResourcePull {
Param(
    [string[]]
    $Module,
    $ComputerName = $env:COMPUTERNAME,
    [System.Management.Automation.PSCredential]
    [System.Management.Automation.CredentialAttribute()]    
    $Credential
)

    $Parms = @{
        'ComputerName' = $ComputerName
    }

    if ($PSBoundParameters.ContainsKey('Credential')){
            $Parms.Add('Credential',$Credential)
    }

    $session = New-PSSession @Parms


    foreach ($ModuleName in $Module){
    
        $ModuleInfo = Get-Module $ModuleName -ListAvailable | Select-Object ModuleBase,Version
        $From = $ModuleInfo.ModuleBase
        $ModuleVersion = $ModuleInfo.Version
        $To =  "$Env:PROGRAMFILES\WindowsPowerShell\Modules\$ModuleName\$ModuleVersion"
    
        Write-Verbose -Message "Copying $ModuleName to $ComputerName..."

        Copy-Item -Path $From -Recurse -Destination $To -ToSession $session

        Write-Verbose -Message "Creating $ModuleName archive..."

        Invoke-Command -Session $session -ScriptBlock {Param($ModuleName,$ModuleVersion)Compress-Archive -Update `
        -Path "$Env:PROGRAMFILES\WindowsPowerShell\Modules\$ModuleName\$ModuleVersion\*" `
        -DestinationPath "$Env:PROGRAMFILES\WindowsPowerShell\DscService\Modules\$($ModuleName)_$($ModuleVersion).zip"} `
        -ArgumentList $ModuleName,$ModuleVersion

        Write-Verbose -Message "Creating $ModuleName checksum..."
        Invoke-Command -Session $session -ScriptBlock {New-DscChecksum "$Env:PROGRAMFILES\WindowsPowerShell\DscService\Modules\$($ModuleName)_$($ModuleVersion).zip"}
    }

}