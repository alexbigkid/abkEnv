#Requires -Version 5.0
#Requires -RunAsAdministrator
$ABK_FUNCTION_LIB_FILE="..\winBin\abk_lib.ps1"

# -----------------------------------------------------------------------------
# main
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "->" $MyInvocation.MyCommand.Name "($args)" -ForeGroundColor Green

if ( Test-Path $ABK_FUNCTION_LIB_FILE -PathType Leaf ) {
    . $ABK_FUNCTION_LIB_FILE
}
else {
    Write-Host "ERROR: " -ForeGroundColor Red -NoNewLine
    Write-Host "$ABK_FUNCTION_LIB_FILE does not exist in the local directory."
    Write-Host "  $ABK_FUNCTION_LIB_FILE contains common definitions and functions"
    Write-Host "  $ABK_FUNCTION_LIB_FILE All binaries and shell scripts will be located in ~/bin"
    exit 1
}

if (DoesCommandExist("chocolatey")) {
    chocolatey upgrade all -y
} else {
    Write-Host "ERROR: chocolatey is not installed" -ForeGroundColor Red
    Write-Host "You can install it by executing following PowerShell command with admin rights"
    Write-Host "Set-ExecutionPolicy AllSigned -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
}

Write-Host "<-" $MyInvocation.MyCommand.Name -ForeGroundColor Green
exit $ERROR_CODE
