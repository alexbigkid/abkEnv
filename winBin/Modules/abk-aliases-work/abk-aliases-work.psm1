#Requires -Version 5.0

function cdcat { Set-Location -Path C:\Git\mob\webcentral\Centralus-AcceptanceTest }
function cdcspt { Set-Location -Path C:\Git\mob\webcentral\Centralus-SupportPageTerraform }
function cdcf { Set-Location -Path C:\Git\mob\webcentral\Centralus.Firmware }
function cdci { Set-Location -Path C:\Git\mob\webcentral\Centralus.Infrastructure }
function cdcia { Set-Location -Path C:\Git\mob\webcentral\Centralus.InfrastructureAzure }
function cdcl { Set-Location -Path C:\Git\mob\webcentral\Centralus.Lambdas }
function cdhim { Set-Location -Path C:\Git\mob\webcentral\HunterInfrastructureModules }
function cdwas { Set-Location -Path C:\Git\mob\webcentral\WebCentral.ApiServer }
function cdwb { Set-Location -Path C:\Git\mob\webcentral\WebCentral.BDD }
function cdwc { Set-Location -Path C:\Git\mob\webcentral\WebCentral.Common }
function cdwi { Set-Location -Path C:\Git\mob\webcentral\WebCentral.Infrastructure }
function cdwld { Set-Location -Path C:\Git\mob\webcentral\WebCentral.Lambda.DeviceResponseToRDS }
function cdwlf { Set-Location -Path C:\Git\mob\webcentral\WebCentral.Lambda.FirmwareUpdate }
function cdwlll { Set-Location -Path C:\Git\mob\webcentral\WebCentral.Lambda.LambdaLayers }
function cdwll { Set-Location -Path C:\Git\mob\webcentral\WebCentral.Lambdas }
function cdwrs { Set-Location -Path C:\Git\mob\webcentral\WebCentral.RetryServer }
function cdwss { Set-Location -Path C:\Git\mob\webcentral\WebCentral.SecurityServer }
function cdws { Set-Location -Path C:\Git\mob\webcentral\WebCentral.Support }
function cdwu { Set-Location -Path C:\Git\mob\webcentral\WebCentral.Utilities }
function cdwws { Set-Location -Path C:\Git\mob\webcentral\WebCentral.WebServer }

Export-ModuleMember -Function *
Export-ModuleMember -Variable *
Export-ModuleMember -Alias *
