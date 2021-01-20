$ABK_DATE_STR = Get-Date -UFormat "%Y-%m-%d week:%V %a"
Write-Host "Copying to clipboard the date: $ABK_DATE_STR"
Write-Output $ABK_DATE_STR | Set-Clipboard
