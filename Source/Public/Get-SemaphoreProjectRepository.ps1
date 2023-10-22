function Get-SemaphoreProjectRepository
{
	<#
		.SYNOPSIS
			Returns repositories for the given project.

		.DESCRIPTION
			This function retrieves information about repositories associated with a project.

		.PARAMETER ProjectId
			The ID of the project for which you want to retrieve repositories.

		.PARAMETER Name
			(Optional) The name of the repository to retrieve. If specified, only the repository with a matching name will be returned.

		.EXAMPLE
			Get-SemaphoreProjectRepository -ProjectId 2

			Retrieves all repositories under the project with ID 2.

		.EXAMPLE
			Get-SemaphoreProjectRepository -ProjectId 5 -Name "AnsiblePlaybooks"

			Retrieves the "AnsiblePlaybooks" repository for the project with ID 5.

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
		[String]
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
		try
		{
			$Data = Invoke-RestMethod -Uri "$($Script:Config.url)/project/$ProjectId/repositories" -Method Get -ContentType 'application/json' -WebSession $Script:Session
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