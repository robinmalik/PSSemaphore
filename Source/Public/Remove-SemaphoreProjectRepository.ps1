function Remove-SemaphoreProjectRepository
{
	<#
		.SYNOPSIS
			Removes a Semaphore project repository.

		.DESCRIPTION
			This function removes a Semaphore project repository.

		.PARAMETER ProjectId
			The ID of the project.

		.PARAMETER Id
			The ID of the repository to remove.

		.EXAMPLE
			Remove-SemaphoreProjectRepository -ProjectId 2 -Id 1

			Removes the repository with ID 1 from the project with ID 2.

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
				Invoke-RestMethod -Uri "$($Script:Config.url)/project/$ProjectId/repositories/$Id" -Method Delete -WebSession $Script:Session | Out-Null
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
