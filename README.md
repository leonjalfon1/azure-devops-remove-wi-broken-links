# Remove-BrokenLinks

## Description

Powershell script used to remove Git broken links from workitems (links related to commits from repositories that were deleted) 

## Parameters

 - CollectionUrl: Url of the collection/organization
 - TeamProject: Name of the team project
 - Credentials: Credentials to access Azure DevOps
 - Verbose: Show all links (not only the links to remove)
 - DryRun: Show which links will be removed (without remove them)

## Usage

.\Remove-BrokenLinks.ps1 -CollectionUrl "https://dev.azure.com/leonj" -TeamProject "MyProject" -Credentials "user:password" -Verbose $true -DryRun $false

