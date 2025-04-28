$LogName = 'Microsoft-Windows-TerminalServices-LocalSessionManager/Operational'
$Results = @()
$Events = Get-WinEvent -LogName $LogName
foreach ($Event in $Events) {
    $EventXml = [xml]$Event.ToXML()

    $ResultHash = @{
        Time        = $Event.TimeCreated.ToString()
        'Event ID'  = $Event.Id
        'Desc'      = ($Event.Message -split "`n")[0]
        Username    = $EventXml.Event.UserData.EventXML.User
        'Source IP' = $EventXml.Event.UserData.EventXML.Address
        'Details'   = $Event.Message
    }

    $Results += (New-Object PSObject -Property $ResultHash)
}

$Results | Export-Csv 'Remote Desktop Users.csv'
