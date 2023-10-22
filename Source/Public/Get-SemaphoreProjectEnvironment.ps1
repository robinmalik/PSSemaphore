function Get-SemaphoreProjectEnvironment
{
	<#
		.SYNOPSIS
			Returns project environments for the given project.

		.DESCRIPTION
			This function retrieves information about environments associated with a project.

		.PARAMETER ProjectId
			The ID of the project for which you want to retrieve environments.

		.PARAMETER Name
			(Optional) The name of the environment to retrieve. If specified, only the environment with a matching name will be returned.

		.EXAMPLE
			Get-SemaphoreProjectEnvironment -ProjectId 2

			Retrieves all environments under the project with ID 2.

		.EXAMPLE
			Get-SemaphoreProjectEnvironment -ProjectId 5 -Name "Production"

			Retrieves the "Production" environment for the project with ID 5.

		.NOTES
			To use this function, make sure you have already connected using the Connect-Semaphore function.
	#>

	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateRange(1, [int]::MaxValue)]
		[int]
		$ProjectId,

		[Parameter(Mandatory = $false)]
		[string]
		$Name
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
		Write-Verbose -Message "Getting environment(s) for project $ProjectId"
		try
		{
			$Data = Invoke-RestMethod -Uri "$($Script:Config.url)/project/$ProjectId/environment" -Method Get -ContentType 'application/json' -WebSession $Script:Session
			if($Name)
			{
				$Data = $Data | Where-Object { $_.name -eq $Name }
			}
			$Data
		}
		catch
		{
			throw $_
		}
	}
	end
	{
	}
}