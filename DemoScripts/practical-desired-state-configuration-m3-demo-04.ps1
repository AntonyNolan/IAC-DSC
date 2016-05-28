#Start Certificate Authority Console mmc
$mmcPath = "c:\Windows\System32\mmc.exe"
$mscPath = "c:\Windows\system32\certsrv.msc"
Start-Process -FilePath $mmcPath -ArgumentList $mscPath