param
(
    [Parameter(Mandatory=$true)]
    $CollectionUrl,
    [Parameter(Mandatory=$true)]
    $TeamProject,
    [Parameter(Mandatory=$true)]
    $Credentials,
    [Parameter(Mandatory=$false)]
    $Verbose="$true",
    [Parameter(Mandatory=$false)]
    $DryRun="$true"
)

function Get-WorkitemsList
{
    param
    (
        [Parameter(Mandatory=$true)]
        $CollectionUrl,
        [Parameter(Mandatory=$true)]
        $TeamProject,
        [Parameter(Mandatory=$true)]
        $Credentials
    )

	try
	{
        $workitemList = @()
        $bulk = 0

        do
        {
            $apiVersion = "4.1"
		    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}" -f $Credentials)))
		    $requestUrl = "$CollectionUrl/$TeamProject/_apis/wit/wiql`?api-version=$apiVersion&`$top=100"

            $WIQL_query = "Select [System.Id] From WorkItems Where [System.Id] > $bulk order by [System.Id] ASC"
            $body = @{ query = $WIQL_query }
            $bodyJson=@($body) | ConvertTo-Json
        
            $responseJson = Invoke-WebRequest -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType application/json -Uri $requestUrl -Method POST -Body $bodyJson -UseBasicParsing
            $response = $responseJson.Content | ConvertFrom-Json           


            foreach($workitemid in $response.workItems.id)
            {
                if(-not($workitemList.Contains($workitemid)))
                {
                    $workitemList += $workitemid
                    Write-Host $workitemid
                }
            }

            $bulk += 100
        }
        while($response.workItems.Count -ne 0)

        return $workitemList
	}
	catch
	{
        Write-Host "Failed to retrieve the workitems list, Exception: $_" -ForegroundColor Red
		return $null
	}
}

function Get-Workitem
{
    param
    (
        [Parameter(Mandatory=$true)]
        $WorkitemId,
        [Parameter(Mandatory=$true)]
        $CollectionUrl,
        [Parameter(Mandatory=$true)]
        $TeamProject,
        [Parameter(Mandatory=$true)]
        $Credentials
    )

	try
	{
        $apiVersion = "4.1"
		$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}" -f $Credentials)))
		$requestUrl = "$CollectionUrl/$TeamProject/_apis/wit/workitems/$WorkitemId`?api-version=$apiVersion&`$expand=all"
        $responseJson = Invoke-WebRequest -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType application/json -Uri $requestUrl -Method GET -UseBasicParsing
        $response = $responseJson.Content | ConvertFrom-Json
		return $response
	}

	catch
	{
        Write-Host "Failed to get Workitem [$WorkitemId], Exception: $_" -ForegroundColor Red
		return $null
	}
}

function Get-ProjectGitRepositoriesIds
{
    param
    (
        [Parameter(Mandatory=$true)]
        $CollectionUrl,
        [Parameter(Mandatory=$true)]
        $TeamProject,
        [Parameter(Mandatory=$true)]
        $Credentials
    )

	try
	{
        $apiVersion = "4.1"
		$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}" -f $Credentials)))
		$requestUrl = "$CollectionUrl/$TeamProject/_apis/git/repositories`?api-version=$apiVersion"
        $responseJson = Invoke-WebRequest -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType application/json -Uri $requestUrl -Method GET -UseBasicParsing
        $response = $responseJson.Content | ConvertFrom-Json
		return $response.value.id
	}

	catch
	{
        Write-Host "Failed to retrieve Git repositories, Exception: $_" -ForegroundColor Red
		return $null
	}
}

function Get-GitRepositoriesIds
{
    param
    (
        [Parameter(Mandatory=$true)]
        $CollectionUrl,
        [Parameter(Mandatory=$true)]
        $TeamProjects,
        [Parameter(Mandatory=$true)]
        $Credentials
    )

	try
	{
        $gitRepositories=@()

        foreach($project in $TeamProjects)
        {
            $apiVersion = "4.1"
		    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}" -f $Credentials)))
		    $requestUrl = "$CollectionUrl/$project/_apis/git/repositories`?api-version=$apiVersion"
            $responseJson = Invoke-WebRequest -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType application/json -Uri $requestUrl -Method GET -UseBasicParsing
            $response = $responseJson.Content | ConvertFrom-Json

            foreach($repoId in $response.value.id)
            {
                $gitRepositories += $repoId
            }
            
		    return $gitRepositories
        } 
	}

	catch
	{
        Write-Host "Failed to retrieve Git repositories, Exception: $_" -ForegroundColor Red
		return $null
	}
}

function Get-TeamProjects
{
    param
    (
        [Parameter(Mandatory=$true)]
        $CollectionUrl,
        [Parameter(Mandatory=$true)]
        $Credentials
    )

	try
	{
        $apiVersion = "4.1"
		$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}" -f $Credentials)))
		$requestUrl = "$CollectionUrl/_apis/projects`?api-version=$apiVersion"
        $responseJson = Invoke-WebRequest -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType application/json -Uri $requestUrl -Method GET -UseBasicParsing
        $response = $responseJson.Content | ConvertFrom-Json
		return $response.value.name
	}

	catch
	{
        Write-Host "Failed to retrieve Team Projects, Exception: $_" -ForegroundColor Red
		return $null
	}
}

function Remove-WorkitemLink
{
    param
    (
        [Parameter(Mandatory=$true)]
        $WorkitemId,
        [Parameter(Mandatory=$true)]
        $WorkitemLinkIndex,
        [Parameter(Mandatory=$true)]
        $CollectionUrl,
        [Parameter(Mandatory=$true)]
        $TeamProject,
        [Parameter(Mandatory=$true)]
        $Credentials
    )

	try
	{
        $apiVersion = "4.1"
		$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}" -f $Credentials)))
		$requestUrl = "$CollectionUrl/$TeamProject/_apis/wit/workitems/$WorkitemId`?api-version=$apiVersion"
        
        $body = @"
[
  {
    "op": "remove",
    "path": "/relations/$WorkitemLinkIndex"    
  }
]
"@
        $responseJson = Invoke-WebRequest -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType "application/json-patch+json" -Uri $requestUrl -Method PATCH -Body $body -UseBasicParsing
        $response = $responseJson.Content | ConvertFrom-Json

        Write-Host "Link [$WorkitemLinkIndex] from Workitem [$WorkitemId] successfully removed" -ForegroundColor Magenta
		return $response
	}

	catch
	{
        Write-Host "Failed to remove the link [$WorkitemLink] from Workitem [$WorkitemId], Exception: $_" -ForegroundColor Red
		return $null
	}
}

function Remove-BrokenLinks
{
    param
    (
        [Parameter(Mandatory=$true)]
        $GitRepositoriesIds,
        [Parameter(Mandatory=$true)]
        $CollectionUrl,
        [Parameter(Mandatory=$true)]
        $TeamProject,
        [Parameter(Mandatory=$true)]
        $Credentials,
        [Parameter(Mandatory=$true)]
        $Verbose,
        [Parameter(Mandatory=$true)]
        $DryRun="$true"
    )

	try
	{
        $workitemList = @()
        $bulk = 0

        do
        {
            $apiVersion = "4.1"
		    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}" -f $Credentials)))
		    $requestUrl = "$CollectionUrl/$TeamProject/_apis/wit/wiql`?api-version=$apiVersion&`$top=100"

            $WIQL_query = "Select [System.Id] From WorkItems Where [System.Id] > $bulk order by [System.Id] ASC"
            $body = @{ query = $WIQL_query }
            $bodyJson=@($body) | ConvertTo-Json
        
            $responseJson = Invoke-WebRequest -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType application/json -Uri $requestUrl -Method POST -Body $bodyJson -UseBasicParsing
            $response = $responseJson.Content | ConvertFrom-Json           


            foreach($workitemId in $response.workItems.id)
            {
                if(-not($workitemList.Contains($workitemId)))
                {
                    $workitemList += $workitemId
                    $wi = Get-Workitem -WorkitemId $workitemId -CollectionUrl $CollectionUrl -TeamProject $TeamProject -Credentials $Credentials
                    $workitemLinks = $wi.relations
                    $workitemLinkIndex = 0

                    Write-Host "Workitem [$workitemId] contains $($workitemLinks.Count) links"

                    if($workitemLinks.Count -gt 0)
                    {
                        foreach($link in $workitemLinks)
                        {
                            if($link.url.StartsWith("vstfs:///Git/Commit/"))
                            {
                                if(-not($GitRepositoriesIds.Contains($link.url.Substring(20).Split('%')[1].Substring(2))))
                                {
                                    Write-Host "  [$workitemLinkIndex] Broken Link [$($link.url)]" -ForegroundColor Red
                                    if(-not($DryRun))
                                    { 
                                        $removeResponse = Remove-WorkitemLink -WorkitemId $workitemId -WorkitemLinkIndex $workitemLinkIndex -CollectionUrl $CollectionUrl -TeamProject $TeamProject -Credentials $Credentials 
                                        if ($removeResponse -ne $null){ $workitemLinkIndex = $workitemLinkIndex - 1}
                                    }
                                }
                                else
                                {
                                    if($Verbose) { Write-Host "  [$workitemLinkIndex] Valid Link [$($link.url)]" -ForegroundColor Green }
                                }
                                
                                # vstfs:///Git/Commit/{project ID}%2F{repo ID}%2F{commit ID}
                            }
                            else
                            {
                                if($Verbose) { Write-Host "  [$workitemLinkIndex] Valid Link [$($link.url)]" -ForegroundColor Green }
                            }

                            $workitemLinkIndex++
                        }
                    }
                }
            }

            $bulk += 100
        }
        while($response.workItems.Count -ne 0)
	}
	catch
	{
        Write-Host "Failed to remove broken workitem links, Exception: $_" -ForegroundColor Red
		return $null
	}
}


$teamProjects = Get-TeamProjects -CollectionUrl $CollectionUrl -Credentials $Credentials
$repositoriesIds = Get-GitRepositoriesIds -CollectionUrl $CollectionUrl -TeamProjects $teamProjects -Credentials $Credentials
Remove-BrokenLinks -CollectionUrl $CollectionUrl -TeamProject $TeamProject -Credentials $Credentials -GitRepositories $repositoriesIds -Verbose $Verbose -DryRun $DryRun
