$EXIT_CODE_SUCCESS=0
$EXIT_CODE_GENERAL_ERROR=1
$EXIT_CODE_INVALID_NUMBER_OF_PARAMETERS=2
$EXIT_CODE_DIRECTORY_ALREADY_EXIST=3

function IsParameterHelp ($NUMBER_OF_PARAMETERS, $PARAMETER) {
    Write-Host "->" $MyInvocation.MyCommand.Name "(numberOfParameters: $NUMBER_OF_PARAMETERS, parameter: $PARAMETER)" -ForegroundColor Yellow
    $RESULT=$false
    if (($NUMBER_OF_PARAMETERS -eq 1) -and ($PARAMETER -eq "--help")) {
        $RESULT=$true
    }
    Write-Host "<-" $MyInvocation.MyCommand.Name "($RESULT)" -ForegroundColor Yellow
    return $RESULT
}

function CheckCorrectNumberOfParameters () {
    Write-Host "->" $MyInvocation.MyCommand.Name "($args)" -ForegroundColor Yellow
    $RESULT=$false
    if ($args[0] -eq $args[1]) {
        $RESULT=$true
    }
    Write-Host "<-" $MyInvocation.MyCommand.Name "($RESULT)" -ForegroundColor Yellow
    return $RESULT
}

function CheckDirectoryExists () {
    Write-Host "->" $MyInvocation.MyCommand.Name "($args)" -ForegroundColor Yellow
    $RESULT=$false
    if (Test-Path $args[0]) {
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

function ColorWrite ()
{
    # Credit to Jesse Chrisholm from Stackoverflow
    # https://stackoverflow.com/users/858542/jesse-chisholm

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
