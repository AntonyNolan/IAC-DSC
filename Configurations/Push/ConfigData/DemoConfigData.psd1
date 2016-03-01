@{
    AllNodes = @( 
       @{
           NodeName = 'DSC'
           Role = 'DSCDemo'
           DomainName = 'Zephyr'
            PsDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true
            TimeZone = 'Central Standard Time'
            IPAddress = '192.168.2.7'
            DefaultGateway = '192.168.2.1'
            DNSIPAddress = '192.168.2.2'
        }
    )
}