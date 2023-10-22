function New-SemaphoreProjectEnvironment
{
	<#
		.SYNOPSIS
			Creates a new environment for the given project.

		.DESCRIPTION
			This function creates a new environment for the given project.

		.PARAMETER ProjectId
			The ID of the project to create the environment for.

		.PARAMETER Name
			The name of the environment to create.

		.EXAMPLE
			New-SemaphoreProjectEnvironment -ProjectId 2 -Name "Production"

			Creates a new environment with the name "Production" for the project with ID 2.

		.NOTES
			To use this function, make sure you have already connected using the Connect-Semaphore function.
	#>

	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateRange(1, [int]::MaxValue)]
		[int]
		$ProjectId,

		[Parameter(Mandatory = $true)]
		[String]$Name
	)

	begin
	{
		Write-Verbose -Message "Calling function $($MyInvocation.MyCommand)"
		if(!$Script:Session)
		{
			throw "Please run Connect-Semaphore first"
		}
	}
	process
	{
		#Region Check If Exists
		# Check if already exists by name. Whilst permitted in Semaphore, it's impossible to tell them apart when using them in Task Templates.
		$CheckIfExists = Get-SemaphoreProjectEnvironment -ProjectId $ProjectId -Name $Name
		if($CheckIfExists)
		{
			throw "An environment with the name $Name already exists in project $ProjectId. Please use a different name."
		}
		#EndRegion

		#Region Construct body and send the request
		try
		{
			$Body = @{
				json       = "{}"
				name       = $Name
				project_id = $ProjectId
			} | ConvertTo-Json -Compress
			Invoke-RestMethod -Uri "$($Script:Config.url)/project/$ProjectId/environment" -Method Post -Body $Body -ContentType 'application/json' -WebSession $Script:Session | Out-Null
			# Return the created object:
			Get-SemaphoreProjectEnvironment -ProjectId $ProjectId -Name $Name
		}
		catch
		{
			throw $_
		}
		#EndRegion
	}
	end
	{
	}
}