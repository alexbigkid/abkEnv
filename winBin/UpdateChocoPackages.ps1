#Requires -Version 5.0
#Requires -RunAsAdministrator
Import-Module "abk-lib" -Force

# -----------------------------------------------------------------------------
# main
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "->" $MyInvocation.MyCommand.Name "($args)" -ForeGroundColor Green

if (Confirm-CommandExist "chocolatey") {
    chocolatey upgrade all -y
} else {
    Write-Host "ERROR: chocolatey is not installed" -ForeGroundColor Red
    Write-Host "You can install it by executing following PowerShell command with admin rights"
    Write-Host "Set-ExecutionPolicy AllSigned -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
}

Write-Host "<-" $MyInvocation.MyCommand.Name -ForeGroundColor Green
exit $ERROR_CODE
