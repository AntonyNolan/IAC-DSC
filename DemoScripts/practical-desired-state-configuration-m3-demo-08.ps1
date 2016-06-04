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
      NodeName = 's1'
      Certificatefile = 'c:\certs\s1.cer'
     }
    )
}

ServerAdminsGroup -configurationdata $configdata `
-Credential (Get-Credential -UserName globomantics\duffneyj -Message 'Enter Password') `
-OutputPath c:\DSC\s1

Start-DscConfiguration -Path c:\DSC\s1 -ComputerName s1 -Wait -Force -Verbose

Invoke-Command s1 -ScriptBlock {net localgroup serveradmins}