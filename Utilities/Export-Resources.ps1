#<Requires PowerShell Direct Win10 or Server2016#>
function Export-Resources ($ISOPath, $VMName)
{
   #mount .ISO to VM
   Set-VMDvdDrive -VMName $VMName -Path $ISOPath
   Invoke-Command -VMName $VMName -ScriptBlock {Copy-Item -Path D:\* -Recurse -Destination "$env:ProgramFiles\WindowsPowerShell\Modules" -Force}
}

