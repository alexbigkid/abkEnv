# -----------------------------------------------------------------------------
# variables definitions
# -----------------------------------------------------------------------------
# exit codes
$ERROR_CODE_SUCCESS=0
$ERROR_CODE_GENERAL_ERROR=1
$ERROR_CODE_NEED_FILE_DOES_NOT_EXIST=2
$ERROR_CODE=$ERROR_CODE_SUCCESS

# for here document to add to the profile
$ABK_ENV_BEGIN = "# >>>>>> DON_NOT_REMOVE >>>>>> ABK_ENV >>>> BEGIN"
$ABK_ENV_END = "# <<<<<< DON_NOT_REMOVE <<<<<< ABK_ENV <<<< END"

# -----------------------------------------------------------------------------
# functions
# -----------------------------------------------------------------------------
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
    if (Test-Path $addPath) {
        $regexAddPath = [regex]::Escape($addPath)
        $arrPath = $env:Path -split ';' | Where-Object {$_ -notMatch "^$regexAddPath\\?"}
        $env:Path = ($arrPath + $addPath) -join ';'
    }
    Write-Host "<-" $MyInvocation.MyCommand.Name "($RESULT)" -ForegroundColor Yellow
}

# Credit to Antony Howell
# https://searchitoperations.techtarget.com/answer/Manage-the-Windows-PATH-environment-variable-with-PowerShell
function RemoveFromPathVariable {
    param ([string]$removePath)
    Write-Host "->" $MyInvocation.MyCommand.Name "($removePath)" -ForegroundColor Yellow
    $regexRemovePath = [regex]::Escape($removePath)
    $arrPath = $env:Path -split ';' | Where-Object {$_ -notMatch "^$regexRemovePath\\?"}
    $env:Path = $arrPath -join ';'
    Write-Host "<-" $MyInvocation.MyCommand.Name "($RESULT)" -ForegroundColor Yellow
}

function AddAbkEnvironmentSettings () {
    Write-Host "->" $MyInvocation.MyCommand.Name "($args)" -ForegroundColor Yellow
    $fileToAddContentTo = $args[0]
    $fileToAdd = $args[1]
    $RESULT=$false

    if ( ( DoesFileExist $fileToAddContentTo ) -and ( DoesFileExist $fileToAdd ) ) {
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
