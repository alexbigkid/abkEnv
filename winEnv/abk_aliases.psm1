#Requires -Version 5.0

# Only run this in the console and not in the ISE
if (-Not (Test-Path Variable:PSise)) {
    Import-Module Get-ChildItemColor
    
    # unix commands
    Set-Alias la Get-ChildItem -option AllScope
    Set-Alias ls Get-ChildItemColorFormatWide -option AllScope

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
    function cdg { Set-Location -Path $env:Home\dev\git }
    function gs { git status }
    function gp { git pull }
    function gpt { git push origin }

    function snp { git push; if ( $? ) { fmedia.exe $env:Home\env\push_it_x1.m4a --notui; } }
    function snp2 { git push; if ( $? ) { fmedia.exe $env:Home\env\push_it_x2.m4a --notui; } }
    function prg { git push; if ( $? ) { fmedia.exe $env:Home\env\push_it_rg.m4a --notui; . $env:Home\bin\AlexIsAwesome.ps1; } }

    function psg { Get-Process $args[0] }
}
