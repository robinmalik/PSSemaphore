function Remove-SemaphoreProject
{
	<#
		.SYNOPSIS
			Removes a Semaphore project.

		.DESCRIPTION
			This function removes a Semaphore project.

		.PARAMETER ProjectId
			The ID of the project to remove.

		.EXAMPLE
			Remove-SemaphoreProject -ProjectId 2

		.NOTES
			To use this function, make sure you have already connected using the Connect-Semaphore function.
	#>

	[CmdletBinding(SupportsShouldProcess)]
	param (
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
				Invoke-RestMethod -Uri "$($Script:Config.url)/project/$Id" -Method Delete -WebSession $Script:Session | Out-Null
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
