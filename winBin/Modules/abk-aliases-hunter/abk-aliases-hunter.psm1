#Requires -Version 5.0

function cdcat { Set-Location -Path C:\Git\mob\webcentral\Centralus-AcceptanceTest }
function cdcspt { Set-Location -Path C:\Git\mob\webcentral\Centralus-SupportPageTerraform }
function cdcas { Set-Location -Path C:\Git\mob\webcentral\Centralus.ApiServer }
function cdcc { Set-Location -Path C:\Git\mob\webcentral\Centralus.Common }
function cdcct { Set-Location -Path C:\Git\mob\webcentral\Centralus.ControllerTranslation }
function cdcf { Set-Location -Path C:\Git\mob\webcentral\Centralus.Firmware }
function cdci { Set-Location -Path C:\Git\mob\webcentral\Centralus.Infrastructure }
function cdcia { Set-Location -Path C:\Git\mob\webcentral\Centralus.InfrastructureAzure }
function cdcl { Set-Location -Path C:\Git\mob\webcentral\Centralus.Lambdas }
function cdcp { Set-Location -Path C:\Git\mob\webcentral\Centralus.ProC2 }
function cdcrs { Set-Location -Path C:\Git\mob\webcentral\Centralus.RetryServer }
function cdcss { Set-Location -Path C:\Git\mob\webcentral\Centralus.SecurityServer }
function cdcs { Set-Location -Path C:\Git\mob\webcentral\Centralus.Support }
function cdcu { Set-Location -Path C:\Git\mob\webcentral\Centralus.Utilities }
function cdcws { Set-Location -Path C:\Git\mob\webcentral\Centralus.WebServer }
function cdhim { Set-Location -Path C:\Git\mob\webcentral\HunterInfrastructureModules }
function cdwb { Set-Location -Path C:\Git\mob\webcentral\WebCentral.BDD }
function cdwi { Set-Location -Path C:\Git\mob\webcentral\WebCentral.Infrastructure }
function cdwld { Set-Location -Path C:\Git\mob\webcentral\WebCentral.Lambda.DeviceResponseToRDS }
function cdwlf { Set-Location -Path C:\Git\mob\webcentral\WebCentral.Lambda.FirmwareUpdate }
function cdwlll { Set-Location -Path C:\Git\mob\webcentral\WebCentral.Lambda.LambdaLayers }
function cdwll { Set-Location -Path C:\Git\mob\webcentral\WebCentral.Lambdas }

Export-ModuleMember -Function *
Export-ModuleMember -Variable *
Export-ModuleMember -Alias *
