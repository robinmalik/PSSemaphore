function Get-SemaphoreProject
{
	<#
		.SYNOPSIS
			Returns projects for the current Semaphore instance.

		.DESCRIPTION
			This function returns projects for the current Semaphore instance.

		.PARAMETER Name
			(Optional) The name of the project to retrieve. If specified, only the project with a matching name will be returned.

		.EXAMPLE
			Get-SemaphoreProject

			Retrieves information about all projects.

		.EXAMPLE
			Get-SemaphoreProject -Name "MyProject"

			Retrieves information about the project with the name "MyProject."

		.NOTES
			To use this function, make sure you have already connected using the Connect-Semaphore function.
	#>

	[CmdletBinding()]
	param (
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
		Write-Verbose -Message "Getting projects"
		try
		{
			$Data = Invoke-RestMethod -Uri "$($Script:Config.url)/projects" -Method Get -ContentType 'application/json' -WebSession $Script:Session
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