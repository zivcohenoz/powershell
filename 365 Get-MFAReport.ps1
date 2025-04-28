Try{
  Write-Host "Finding Azure Active Directory Accounts..."
  $Users = Get-MsolUser -All -ErrorAction Stop | Where-Object { $_.UserType -ne "Guest" }
  $Report = [System.Collections.Generic.List[Object]]::new() # Create output file
  Write-Host "Processing" $Users.Count "accounts..." 
  ForEach ($User in $Users) {
    $MFAMethods = $User.StrongAuthenticationMethods.MethodType
    $MFAEnforced = $User.StrongAuthenticationRequirements.State
    $MFAPhone = $User.StrongAuthenticationUserDetails.PhoneNumber
    $DefaultMFAMethod = ($User.StrongAuthenticationMethods | Where-Object { $_.IsDefault -eq "True" }).MethodType
    If (($MFAEnforced -eq "Enforced") -or ($MFAEnforced -eq "Enabled")) {
        Switch ($DefaultMFAMethod) {
            "OneWaySMS" { $MethodUsed = "One-way SMS" }
            "TwoWayVoiceMobile" { $MethodUsed = "Phone call verification" }
            "PhoneAppOTP" { $MethodUsed = "Hardware token or authenticator app" }
            "PhoneAppNotification" { $MethodUsed = "Authenticator app" }
        }
    }
    Else {
        $MFAEnforced = "Not Enabled"
        $MethodUsed = "MFA Not Used" 
    }
  
    $ReportLine = [PSCustomObject] @{
        User        = $User.UserPrincipalName
        Name        = $User.DisplayName
        MFAUsed     = $MFAEnforced
        MFAMethod   = $MethodUsed 
        PhoneNumber = $MFAPhone
    }
                 
    $Report.Add($ReportLine) 
  }

  Write-Host "Report is in c:\temp\MFAUsers.CSV"
  $Report | Select-Object User, Name, MFAUsed, MFAMethod, PhoneNumber | Sort-Object Name | Out-GridView
  $Report | Sort-Object Name | Export-CSV -NoTypeInformation c:\temp\MFAUsers.csv
}
CATCH{
  Import-Module ExchangeOnlineManagement
  Connect-MsolService
}
