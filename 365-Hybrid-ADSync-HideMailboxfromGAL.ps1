LOCAL Active Directory:
Import-Module ActiveDirectory
Clear-Host
Push-Location $PSScriptRoot
$ImportCSV = (Get-Content -Path ".\UsersToHide.csv" -Encoding Ascii)
$ImportCSV.Count
foreach ($Mailbox in $ImportCSV){
$isMailboxHidden=Get-ADUser -Identity "$Mailbox" -Properties msExchHideFromAddressLists
IF ($isMailboxHidden.msExchHideFromAddressLists -ne $true){
Write-Host "[Hidding Mailbox] $Mailbox" -ForegroundColor Yellow
Get-ADUser -Identity "$Mailbox" -Properties msExchHideFromAddressLists -ErrorAction SilentlyContinue | Set-ADObject -Replace @{msExchHideFromAddressLists=$true} -WhatIf
} Else{
Write-Host "[Already Hidden] $Mailbox " -ForegroundColor Green 
}
}
Start-ADSyncSyncCycle -PolicyType Initial
--------------------------------------------------------
Office 365 Exchange Online:
#Connect-ExchangeOnline
Clear-Host
Push-Location $PSScriptRoot
$ImportCSV = Get-Content -Path ".\UsersToHidefromGAL.csv" -Encoding Ascii
Write-Host "Number of Mailboxs to Hide:" ($ImportCSV).Count
foreach ($Mailbox in $ImportCSV){
  $isMailboxHidden=(Get-Mailbox -Identity "$Mailbox" -ErrorAction SilentlyContinue)
  IF ($isMailboxHidden){
    IF ($isMailboxHidden.HiddenFromAddressListsEnabled -eq "$True"){
      Write-Host "$Mailbox [Mailbox is Hidden]" -ForegroundColor Green
    }
    ELSE{
      Write-Host "Mailbox is NOT Hidden: $Mailbox" -ForegroundColor Red -BackgroundColor Yellow
#      Set-Mailbox -Identity $Mailbox -HiddenFromAddressListsEnabled $true -WhatIf
    }
  }
}
