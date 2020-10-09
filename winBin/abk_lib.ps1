# -----------------------------------------------------------------------------
# variables definitions
# -----------------------------------------------------------------------------

# exit codes
$ERROR_CODE_SUCCESS=0
$ERROR_CODE_GENERAL_ERROR=1
$ERROR_CODE_NOT_BASH_SHELL=2
$ERROR_CODE_IS_INSTALLED_BUT_NO_LINK=3
$ERROR_CODE_NOT_VALID_NUM_OF_PARAMETERS=4
$ERROR_CODE_NOT_VALID_PARAMETER=5
$ERROR_CODE=$ERROR_CODE_SUCCESS

# -----------------------------------------------------------------------------
# functions
# -----------------------------------------------------------------------------
# function GetAbsolutePath () {
#     local DIR_NAME=$(dirname "$1")
#     pushd "$DIR_NAME" > /dev/null
#     local RESULT_PATH=$PWD
#     popd > /dev/null
#     echo $RESULT_PATH
# }

function IsParameterHelp ($NUMBER_OF_PARAMETERS, $PARAMETER) {
    Write-Host "->" $MyInvocation.MyCommand.Name "(numberOfParameters: $NUMBER_OF_PARAMETERS, parameter: $PARAMETER)" -ForegroundColor Yellow
    $RESULT=$false
    if (($NUMBER_OF_PARAMETERS -eq 1) -and ($PARAMETER -eq "--help")) {
        $RESULT=$true
    }
    Write-Host "<-" $MyInvocation.MyCommand.Name "($RESULT)" -ForegroundColor Yellow
    return $RESULT
}

function IsCorrectNumberOfParameters () {
    Write-Host "->" $MyInvocation.MyCommand.Name "($args)" -ForegroundColor Yellow
    $RESULT=$false
    if ($args[0] -eq $args[1]) {
        $RESULT=$true
    }
    Write-Host "<-" $MyInvocation.MyCommand.Name "($RESULT)" -ForegroundColor Yellow
    return $RESULT
}

function DoesCommandExist () {
    Param ($command)
    Write-Host "->" $MyInvocation.MyCommand.Name "($command)" -ForegroundColor Yellow
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference =  "stop"
    $RESULT=$false
   
    try { if(Get-Command -Name $command) { $RESULT=$true } }
    catch {}
    Finally {$ErrorActionPreference=$oldPreference}
    
    Write-Host "<-" $MyInvocation.MyCommand.Name "($RESULT)" -ForegroundColor Yellow
    return $RESULT
}

function DoesDirectoryExist () {
    Write-Host "->" $MyInvocation.MyCommand.Name "($args)" -ForegroundColor Yellow
    $RESULT=$false
    if (Test-Path $args[0]) {
        $RESULT=$true
    }
    Write-Host "<-" $MyInvocation.MyCommand.Name "($RESULT)" -ForegroundColor Yellow
    return $RESULT
}

function DoesFileExist () {
    Write-Host "->" $MyInvocation.MyCommand.Name "($args)" -ForegroundColor Yellow
    $RESULT=$false
    if (Test-Path $args[0] -PathType Leaf) {
        $RESULT=$true
    }
    Write-Host "<-" $MyInvocation.MyCommand.Name "($RESULT)" -ForegroundColor Yellow
    return $RESULT
}

function IsFileALink() {
    Write-Host "->" $MyInvocation.MyCommand.Name "($args)" -ForegroundColor Yellow
    $RESULT=$false
    $file = Get-Item $args[0] -Force -ea SilentlyContinue
    if ($file.Attributes -band [IO.FileAttributes]::ReparsePoint) {
        $RESULT=$true
    }
    Write-Host "<-" $MyInvocation.MyCommand.Name "($RESULT)" -ForegroundColor Yellow
    return $RESULT
}

function ReplaceStringInFile () {
    Write-Host "->" $MyInvocation.MyCommand.Name "($args)" -ForegroundColor Yellow
    $stringToReplace = args[0]
    $stringToReplaceWith = args[1]
    $fileName = args[2]

    (Get-Content -path $fileName -Raw) -replace $stringToReplace, $stringToReplaceWith

    Write-Host "<-" $MyInvocation.MyCommand.Name -ForegroundColor Yellow
}

# Credit to Antony Howell
# https://searchitoperations.techtarget.com/answer/Manage-the-Windows-PATH-environment-variable-with-PowerShell
function AddToPathVariable {
    param ([string]$addPath)
    Write-Host "->" $MyInvocation.MyCommand.Name "($addPath)" -ForegroundColor Yellow
    $RESULT=$false
    if (Test-Path $addPath) {
        $regexAddPath = [regex]::Escape($addPath)
        $arrPath = $env:Path -split ';' | Where-Object {$_ -notMatch "^$regexAddPath\\?"}
        $env:Path = ($arrPath + $addPath) -join ';'
        $RESULT=$true
    }
    Write-Host "<-" $MyInvocation.MyCommand.Name "($RESULT)" -ForegroundColor Yellow
    return $RESULT
}

# Credit to Antony Howell
# https://searchitoperations.techtarget.com/answer/Manage-the-Windows-PATH-environment-variable-with-PowerShell
function RemoveFromPathVariable {
    param ([string]$removePath)
    Write-Host "->" $MyInvocation.MyCommand.Name "($removePath)" -ForegroundColor Yellow
    $RESULT=$true
    $regexRemovePath = [regex]::Escape($removePath)
    $arrPath = $env:Path -split ';' | Where-Object {$_ -notMatch "^$regexRemovePath\\?"}
    $env:Path = $arrPath -join ';'
    $RESULT=$true
    Write-Host "<-" $MyInvocation.MyCommand.Name "($RESULT)" -ForegroundColor Yellow
    return $RESULT
}

# Credit to Jesse Chrisholm from Stackoverflow
# https://stackoverflow.com/users/858542/jesse-chisholm
function ColorWrite ()
{
    # DO NOT SPECIFY param(...)
    #    we parse colors ourselves.

    $allColors = ("-Black",   "-DarkBlue","-DarkGreen","-DarkCyan","-DarkRed","-DarkMagenta","-DarkYellow","-Gray",
                  "-Darkgray","-Blue",    "-Green",    "-Cyan",    "-Red",    "-Magenta",    "-Yellow",    "-White")
    $foreground = (Get-Host).UI.RawUI.ForegroundColor # current foreground
    $color = $foreground
    [bool]$nonewline = $false
    $sofar = ""
    $total = ""

    foreach($arg in $args)
    {
        if ($arg -eq "-nonewline") { $nonewline = $true }
        elseif ($arg -eq "-foreground")
        {
            if ($sofar) { Write-Host $sofar -foreground $color -nonewline }
            $color = $foregrnd
            $sofar = ""
        }
        elseif ($allColors -contains $arg)
        {
            if ($sofar) { Write-Host $sofar -foreground $color -nonewline }
            $color = $arg.substring(1)
            $sofar = ""
        }
        else
        {
            $sofar += "$arg "
            $total += "$arg "
        }
    }
    # last bit done special
    if (!$nonewline)
    {
        Write-Host $sofar -foreground $color
    }
    elseif($sofar)
    {
        Write-Host $sofar -foreground $color -nonewline
    }
}
