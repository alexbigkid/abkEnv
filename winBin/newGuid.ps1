$NEW_GUID=[guid]::NewGuid().ToString()
Write-Output $NEW_GUID | Set-Clipboard
Write-Host $NEW_GUID
