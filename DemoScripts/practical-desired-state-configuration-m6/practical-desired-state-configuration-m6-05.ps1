#View, Remove, update current subscription
cmd /c wecutil es
cmd /c wecutil gs adsecurity
cmd /c wecutil ds ADSecurity 


#Method 1: Nuke
$Subs = cmd /c wecutil es
if ($Subs -contains 'ADSecurity'){
    Write-Output "Removing Subscription [ADSecurity]"
    cmd /c wecutil ds ADSecurity
}

#Method 2: Compare
$EventSources = cmd /c wecutil gs adsecurity | Select-String -SimpleMatch "Address" | % {($_).tostring().split(':')[1].trim()}
$DCs = (Get-ADDomainController -filter *).HostName

if ((Compare-Object $DCs $EventSources).length -ne 0){
    Write-Output "Removing Subscription [ADSecurity]"
    cmd /c wecutil ds ADSecurity
}

#Re-apply WEF DSC Config
Start-DscConfiguration -Wait -Force -Path c:\DSC\ -Verbose

#Verify Subscription exists
cmd /c wecutil gs adsecurity