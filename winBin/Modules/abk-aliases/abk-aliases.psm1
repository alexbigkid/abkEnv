#Requires -Version 5.0

$ABK_BIN_DIR="$HOME\abkBin"

# Only run this in the console and not in the ISE
if (-Not (Test-Path Variable:PSise)) {
    if (-Not (Get-Module -ListAvailable -Name Get-ChildItemColor)) {
        Write-Host "Get-ChildItemColor - Module does not exist"
        Install-Module -AllowClobber Get-ChildItemColor
    } 
    # Import-Module Get-ChildItemColor -Verbose
    Import-Module Get-ChildItemColor
    
    # unix commands
    # Set-Alias ls Get-ChildItemColorFormatWide -Scope Global -Force
    Set-Alias l Get-ChildItemColorFormatWide -Scope Global -Force
    Set-Alias la Get-ChildItem -Scope Global -Force
}

# cd aliases
function cdg { Set-Location -Path $HOME\dev\git }

# find commands scripts
function rgrep { Get-ChildItem -Recurse | Select-String $args[0] -List | Select Path }
function rfind { Get-ChildItem -Path . -Filter $args[0] -Recurse -ErrorAction SilentlyContinue -Force }

# number of cpu's aliases
function pcAll { Get-WmiObject Win32_Processor | Select-Object * }
function pcData { Get-WmiObject Win32_ComputerSystem }
function cpuName { Get-WmiObject Win32_Processor | Select-Object Name }
function pcName { Get-WmiObject Win32_Processor | Select-Object PSComputerName }
function ncpu { Get-WmiObject Win32_Processor | Select-Object NumberOfCores }
function npcpu { Get-WmiObject Win32_Processor | Select-Object NumberOfEnabledCore }
function nlcpu { Get-WmiObject Win32_Processor | Select-Object NumberOfLogicalProcessors }

# git aliases
function gs { git status }
function gp { git pull }
function gpt { git push origin }

function snp { git push; if ( $? ) { fmedia.exe $ABK_BIN_DIR\push_it_x1.m4a --notui; . $ABK_BIN_DIR\AhhPushIt.ps1;} }
function snp2 { git push; if ( $? ) { fmedia.exe $ABK_BIN_DIR\push_it_x2.m4a --notui; . $ABK_BIN_DIR\AhhPushIt2.ps1;} }
function prg { git push; if ( $? ) { fmedia.exe $ABK_BIN_DIR\push_it_rg.m4a --notui; . $ABK_BIN_DIR\PushItRealGood.ps1; } }

function psg { Get-Process $args[0] }
function ppp { $env:Path.split(';') }
function ppps { $env:PSModulePath.split(';') }
function ppv { $args[0] -split ';' }

Export-ModuleMember -Function *
Export-ModuleMember -Variable *
Export-ModuleMember -Alias *
