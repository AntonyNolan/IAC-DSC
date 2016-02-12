function Publish-DSCResourcePull {
Param(
    [string[]]
    $Module
)

foreach ($ModuleName in $Module){
    
    $ModuleVersion = (Get-Module $ModuleName -ListAvailable).Version
    
    Compress-Archive -Update `
    -Path "$Env:PROGRAMFILES\WindowsPowerShell\Modules\$ModuleName\$ModuleVersion\*" `
    -DestinationPath "$Env:PROGRAMFILES\WindowsPowerShell\DscService\Modules\$($ModuleName)_$($ModuleVersion).zip"
    
    New-DscChecksum "$Env:PROGRAMFILES\WindowsPowerShell\DscService\Modules\$($ModuleName)_$($ModuleVersion).zip"
}

}