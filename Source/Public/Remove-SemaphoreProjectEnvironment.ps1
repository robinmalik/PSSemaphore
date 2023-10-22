function Remove-SemaphoreProjectEnvironment
{
	<#
		.SYNOPSIS
			Removes an environment from a Semaphore project.

		.DESCRIPTION
			This function removes an environment from a Semaphore project.

		.PARAMETER ProjectId
			The ID of the project.

		.PARAMETER Id
			The ID of the environment to remove.

		.EXAMPLE
			Remove-SemaphoreProjectEnvironment -ProjectId 2 -Id 1

			Removes the environment with ID 1 from the project with ID 2.

		.NOTES
			To use this function, make sure you have already connected using the Connect-Semaphore function.
	#>

	[CmdletBinding(SupportsShouldProcess)]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateRange(1, [int]::MaxValue)]
		[int]
		$ProjectId,

		[Parameter(Mandatory = $true)]
		[ValidateRange(1, [int]::MaxValue)]
		[int]
		$Id
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
		#Region Send the request to remove
		try
		{
			if($PSCmdlet.ShouldProcess("Project $ProjectId", "Remove $Id"))
			{
				Invoke-RestMethod -Uri "$($Script:Config.url)/project/$ProjectId/environment/$Id" -Method Delete -WebSession $Script:Session | Out-Null
			}
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
