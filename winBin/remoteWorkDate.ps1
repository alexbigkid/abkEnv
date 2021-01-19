$ABK_DATE_STR = Get-Date -UFormat "%F week:%V %a"
Write-Output $ABK_DATE_STR | Set-Clipboard
Write-Host $ABK_DATE_STR
