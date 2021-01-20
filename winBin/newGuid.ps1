$NEW_GUID=[guid]::NewGuid().ToString()
Write-Host "Copying to clipboard new GUID: $NEW_GUID"
Write-Output $NEW_GUID | Set-Clipboard
