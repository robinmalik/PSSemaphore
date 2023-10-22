function Get-SemaphoreProjectTask
{
	<#
		.SYNOPSIS
			Returns tasks for the given project and optionally, template.

		.DESCRIPTION
			This function retrieves information about tasks associated with a project and optionally, template.

		.PARAMETER ProjectId
			The ID of the project for which you want to retrieve tasks.

		.PARAMETER Id
			(Optional) The ID of the task to retrieve. If specified, only the task with a matching ID will be returned.

		.PARAMETER TemplateId
			(Optional) The ID of the template to retrieve tasks for. If specified, only tasks associated with the template with a matching ID will be returned.

		.EXAMPLE
			Get-SemaphoreProjectTask -ProjectId 2

			Retrieves all tasks under the project with ID 2.

		.EXAMPLE
			Get-SemaphoreProjectTask -ProjectId 5 -TemplateId 2

			Retrieves all tasks for the template with ID 2 under the project with ID 5.

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
		[ValidateRange(1, [int]::MaxValue)]
		$Id,

		[Parameter(Mandatory = $false)]
		[ValidateRange(1, [int]::MaxValue)]
		$TemplateId
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
			$Data = Invoke-RestMethod -Uri "$($Script:Config.url)/project/$ProjectId/tasks/$Id" -Method Get -ContentType 'application/json' -WebSession $Script:Session
			# E.g. if we only want the tasks for a specific template (note this will only apply if we are getting all tasks for a project)
			if($TemplateId)
			{
				$Data = $Data | Where-Object { $_.template_id -eq $TemplateId }
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