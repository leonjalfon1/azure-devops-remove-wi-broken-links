# Remove-BrokenLinks

## Description

Powershell script used to remove Git broken links from workitems (links related to commits from repositories that were deleted) 

## Parameters

 - CollectionUrl: Url of the collection/organization
 - TeamProject: Name of the team project
 - Credentials: Credentials to access Azure DevOps
 - ExtendedLog: Show all links (not only the links to remove) [$true|$false]
 - DryRun: Show which links will be removed (without remove them) [$true|$false]
 - LogFile: Location of the log file created to store the script output [default: .\log.txt]
 - StartFromWorkitemId: Id of the workitem ID to start remove broken links from (used to skip old items) [default: 0]

## Usage

.\Remove-BrokenLinks.ps1 -CollectionUrl "https://dev.azure.com/organization" -TeamProject "MyProject" -Credentials "user:password" -ExtendedLog $true -DryRun $false -StartFromWorkitemId 10500 -LogFile "C:\log.txt"

