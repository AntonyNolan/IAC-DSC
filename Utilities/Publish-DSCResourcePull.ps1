function Publish-DSCResourcePull {
Param(
    [string[]]
    $Module,
    $ComputerName = $env:COMPUTERNAME,
    $Credential
)

if ($PSBoundParameters.ContainsKey('Credential')){
    $SecurePassword = Read-Host -Prompt "Enter Password" -AsSecureString
    $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Credential,$SecurePassword
}

$Parms = @{
    'ComputerName' = $ComputerName
}

if ($Credential) {$Parms.Add('Credential',$Credential)}

$session = New-PSSession @Parms


foreach ($ModuleName in $Module){
    
    $From = (Get-ChildItem -Path $Env:PROGRAMFILES\WindowsPowerShell\Modules | where Name -eq $ModuleName).FullName
    $To =  "$Env:PROGRAMFILES\WindowsPowerShell\Modules"
    $ModuleVersion = (Get-Module $ModuleName -ListAvailable).Version
    
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
