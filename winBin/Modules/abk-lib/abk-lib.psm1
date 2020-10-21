# -----------------------------------------------------------------------------
# external variables definitions
# -----------------------------------------------------------------------------
# exit codes
[int64]$ERROR_CODE_SUCCESS=0
[int64]$ERROR_CODE_GENERAL_ERROR=1
[int64]$ERROR_CODE_NEED_FILE_DOES_NOT_EXIST=2
# Set-Variable -Name ERROR_CODE_SUCCESS -Value ([int64]0) -Option Constant, AllScope -Force
# Set-Variable -Name ERROR_CODE_GENERAL_ERROR -Value ([int64]1) -Option Constant, AllScope -Force
# Set-Variable -Name ERROR_CODE_NEED_FILE_DOES_NOT_EXIST -Value ([int64]2) -Option Constant, AllScope -Force

# directory definitions
[string]$BIN_DIR="bin"
[string]$ENV_DIR="env"
[string]$HOME_BIN_DIR="$HOME\$BIN_DIR"
[string]$HOME_ENV_DIR="$HOME\$ENV_DIR"
[string]$SH_BIN_DIR="winBin"
[string]$SH_ENV_DIR="winEnv"
[string]$SH_PACKAGES_DIR="winPackages"
# Set-Variable -Name BIN_DIR -Value ([string]"bin") -Option AllScope -Force
# Set-Variable -Name ENV_DIR -Value ([string]"env") -Option Constant, AllScope -Force
# Set-Variable -Name HOME_BIN_DIR -Value ([string]"$HOME\$BIN_DIR") -Option Constant, AllScope -Force
# Set-Variable -Name HOME_ENV_DIR -Value ([string]"$HOME\$ENV_DIR") -Option Constant, AllScope -Force
# Set-Variable -Name SH_BIN_DIR -Value ([string]"winBin") -Option Constant, AllScope -Force
# Set-Variable -Name SH_ENV_DIR -Value ([string]"winEnv") -Option Constant, AllScope -Force
# Set-Variable -Name SH_PACKAGES_DIR -Value ([string]"winPackages") -Option Constant, AllScope -Force

# -----------------------------------------------------------------------------
# internal variables definitions
# -----------------------------------------------------------------------------
# for here document to add to the profile
# Set-Variable -Name ABK_ENV_BEGIN -Value ([string]"# >>>>>> DO_NOT_REMOVE >>>>>> ABK_ENV >>>> BEGIN") -Option Constant -Scope Local -Force
# Set-Variable -Name ABK_ENV_END -Value ([string]"# <<<<<< DO_NOT_REMOVE <<<<<< ABK_ENV <<<< END") -Option Constant -Scope Local -Force
[string]$ABK_ENV_BEGIN="# >>>>>> DO_NOT_REMOVE >>>>>> ABK_ENV >>>> BEGIN"
[string]$ABK_ENV_END="# <<<<<< DO_NOT_REMOVE <<<<<< ABK_ENV <<<< END"

# -----------------------------------------------------------------------------
# functions
# -----------------------------------------------------------------------------
function Add-AbkEnvironmentSettings () {
    Param(
        [Parameter(Mandatory=$true,Position=0)][string]$fileToAddContentTo,
        [Parameter(Mandatory=$true,Position=1)][string]$fileToAdd
    )
    Write-Host "->" $MyInvocation.MyCommand.Name "($fileToAddContentTo, $fileToAdd)" -ForegroundColor Yellow
    $RESULT=$false

    if ( ( Confirm-FileExist $fileToAddContentTo ) -and ( Confirm-FileExist $fileToAdd ) ) {
        $RESULT=$true

        if( Select-String $fileToAddContentTo -Pattern $fileToAdd -SimpleMatch -Quiet ) {
            Write-Host "   ABK ENV already added. Nothing to do here." -ForegroundColor Yellow
        } else {
            $TEXT_TO_ADD = @"

$ABK_ENV_BEGIN
if ( Test-Path $fileToAdd -PathType Leaf ) {
    $fileToAdd
}
$ABK_ENV_END

"@
            Add-Content -Path $fileToAddContentTo -Value $TEXT_TO_ADD -Encoding ASCII
        }

    } else {
        Write-Host "   One or both files do not exist:", $fileToAddContentTo, $fileToAdd -ForegroundColor Red
    }

    Write-Host "<-" $MyInvocation.MyCommand.Name "($RESULT)" -ForegroundColor Yellow
    return $RESULT
}

# Credit to Antony Howell
# https://searchitoperations.techtarget.com/answer/Manage-the-Windows-PATH-environment-variable-with-PowerShell
function Add-ToPathVariable () {
    Param(
        [Parameter(Mandatory=$true,Position=0)][string]$addPath
    )
    Write-Host "->" $MyInvocation.MyCommand.Name "($addPath)" -ForegroundColor Yellow
    if (Test-Path $addPath) {
        $regexAddPath = [regex]::Escape($addPath)
        $arrPath = $env:Path -split ';' | Where-Object {$_ -notMatch "^$regexAddPath\\?"}
        $env:Path = ($arrPath + $addPath) -join ';'
    }
    Write-Host "<-" $MyInvocation.MyCommand.Name "($RESULT)" -ForegroundColor Yellow
}

function Confirm-CommandExist () {
    Param(
        [Parameter(Mandatory=$true,Position=0)][string]$command
    )
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

function Confirm-DirectoryExist () {
    Param(
        [Parameter(Mandatory=$true,Position=0)][string]$directory
    )
    Write-Host "->" $MyInvocation.MyCommand.Name "($directory)" -ForegroundColor Yellow
    $RESULT=$false
    if (Test-Path $directory) {
        $RESULT=$true
    }
    Write-Host "<-" $MyInvocation.MyCommand.Name "($RESULT)" -ForegroundColor Yellow
    return $RESULT
}

function Confirm-FileExist () {
    Param(
        [Parameter(Mandatory=$true,Position=0)][string]$fileName
    )
    Write-Host "->" $MyInvocation.MyCommand.Name "($fileName)" -ForegroundColor Yellow
    $RESULT=$false
    if (Test-Path $fileName -PathType Leaf) {
        $RESULT=$true
    }
    Write-Host "<-" $MyInvocation.MyCommand.Name "($RESULT)" -ForegroundColor Yellow
    return $RESULT
}

function Confirm-CorrectNumberOfParameters () {
    Param(
        [Parameter(Mandatory=$true,Position=0)][string]$expectedNumberOfParameters,
        [Parameter(Mandatory=$true,Position=1)][string]$actualNumberOfParameters
    )
    Write-Host "->" $MyInvocation.MyCommand.Name "($expectedNumberOfParameters, $actualNumberOfParameters)" -ForegroundColor Yellow
    $RESULT=$false
    if ($expectedNumberOfParameters -eq $actualNumberOfParameters) {
        $RESULT=$true
    }
    Write-Host "<-" $MyInvocation.MyCommand.Name "($RESULT)" -ForegroundColor Yellow
    return $RESULT
}

function Confirm-FileIsALink () {
    Param(
        [Parameter(Mandatory=$true,Position=0)][string]$fileName
    )
    Write-Host "->" $MyInvocation.MyCommand.Name "($fileName)" -ForegroundColor Yellow
    $RESULT=$false
    $file = Get-Item $fileName -Force -ea SilentlyContinue
    if ($file.Attributes -band [IO.FileAttributes]::ReparsePoint) {
        $RESULT=$true
    }
    Write-Host "<-" $MyInvocation.MyCommand.Name "($RESULT)" -ForegroundColor Yellow
    return $RESULT
}

function Confirm-ParameterIsHelp () {
    Param (
        [Parameter(Mandatory=$false,Position=0)][string]$numberOfParameters,
        [Parameter(Mandatory=$false,Position=1)][string]$parameter
    )
    Write-Host "->" $MyInvocation.MyCommand.Name "(numberOfParameters: $numberOfParameters, parameter: $parameter)" -ForegroundColor Yellow
    $RESULT=$false
    if (($numberOfParameters -eq 1) -and ($parameter -eq "--help")) {
        $RESULT=$true
    }
    Write-Host "<-" $MyInvocation.MyCommand.Name "($RESULT)" -ForegroundColor Yellow
    return $RESULT
}

# Credit to Antony Howell
# https://searchitoperations.techtarget.com/answer/Manage-the-Windows-PATH-environment-variable-with-PowerShell
function Remove-FromPathVariable {
    Param(
        [Parameter(Mandatory=$true,Position=0)][string]$removePath
    )
    Write-Host "->" $MyInvocation.MyCommand.Name "($removePath)" -ForegroundColor Yellow
    $regexRemovePath = [regex]::Escape($removePath)
    $arrPath = $env:Path -split ';' | Where-Object {$_ -notMatch "^$regexRemovePath\\?"}
    $env:Path = $arrPath -join ';'
    Write-Host "<-" $MyInvocation.MyCommand.Name "($RESULT)" -ForegroundColor Yellow
}

function Remove-AbkEnvironmentSettings () {
    Write-Host "->" $MyInvocation.MyCommand.Name "($args)" -ForegroundColor Yellow
    
    Write-Host "<-" $MyInvocation.MyCommand.Name "($RESULT)" -ForegroundColor Yellow
    return $RESULT
}

function Rename-StringInFile () {
    Param(
        [Parameter(Mandatory=$true,Position=0)][string]$stringToReplace,
        [Parameter(Mandatory=$true,Position=1)][string]$stringToReplaceWith,
        [Parameter(Mandatory=$true,Position=1)][string]$fileName
    )
    Write-Host "->" $MyInvocation.MyCommand.Name "($stringToReplace, $stringToReplaceWith, $fileName)" -ForegroundColor Yellow

    (Get-Content -path $fileName -Raw) -replace $stringToReplace, $stringToReplaceWith

    Write-Host "<-" $MyInvocation.MyCommand.Name -ForegroundColor Yellow
}

# Credit to Jesse Chrisholm from Stackoverflow
# https://stackoverflow.com/users/858542/jesse-chisholm
function Write-ColorPrint () {
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

Export-ModuleMember -Function *
# Export-ModuleMember -Variable ERROR_CODE_SUCCESS, ERROR_CODE_GENERAL_ERROR, ERROR_CODE_NEED_FILE_DOES_NOT_EXIST
Export-ModuleMember -Variable ERROR_CODE*
Export-ModuleMember -Variable BIN_DIR, ENV_DIR, HOME_BIN_DIR, HOME_ENV_DIR, SH_BIN_DIR, SH_ENV_DIR, SH_PACKAGES_DIR