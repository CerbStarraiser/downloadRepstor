###############################################################################
# downloadRepstor64.ps1
#
# written by Dan Hughes
#
# last updated 2/22/2023
# 
# This script installs the latest 64-bit version of Repstor from their website.
###############################################################################

function main {
    $folderName = 'c:\temp\repstor'
    Get-LatestRepstor -folder $folderName
    Install-LatestRepstor -folder $folderName
}

function Get-LatestRepstor {
    param (
        $folder
    )
    ## Set folder variable for temp directory. If folder exists, remove and recreate.
    $folder = 'C:\temp\repstor'
    if (Test-Path -Path $folder) {
        Remove-Item $folder -Recurse
    }
    New-Item -Path $folder -ItemType Directory

    ## Pull down page content to identify the "latest" link on the page.
    $URL= "https://www.repstor.com/latest/latestCustodianInstaller64.htm"
    $invoke = Invoke-Webrequest -URI $URL -UseBasicParsing
    
    ## Build the URL for the latest file based on the link provided.
    $URL2 = "https://www.repstor.com" + $invoke.Links.href
    Invoke-Webrequest -URI $URL2 -OutFile $folder\RepstorCustodian.zip
}

function Install-LatestRepstor {
    param (
        $folder
    )
    ## Unzip the files and then rename them for ease of use within the scripts, since each version will have a different name.
    Expand-Archive $folder\RepstorCustodian.zip -DestinationPath $folder\unzip
    get-childitem -Path $folder\unzip | Where-Object { $_.Name -like "Repstor Affinity*" } | %{ rename-item -LiteralPath $_.FullName -NewName "RepstorAffinity.msi" }
    get-childitem -Path $folder\unzip | Where-Object { $_.Name -like "Repstor Assist*" } | %{ rename-item -LiteralPath $_.FullName -NewName "RepstorAssist.msi" }
    get-childitem -Path $folder\unzip | Where-Object { $_.Name -like "Repstor Custodian*" } | %{ rename-item -LiteralPath $_.FullName -NewName "RepstorCustodian.msi" }

    ## Install each package in order
    $package = $folder + '\unzip\RepstorAffinity.msi'
    Start-Process msiexec.exe -Wait -ArgumentList "/i `"$package`" /qn"
    $package = $folder + '\unzip\RepstorAssist.msi'
    Start-Process msiexec.exe -Wait -ArgumentList "/i `"$package`" /qn"
    $package = $folder + '\unzip\RepstorCustodian.msi'
    Start-Process msiexec.exe -Wait -ArgumentList "/i `"$package`" /qn"
}

main