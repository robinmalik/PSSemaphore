function Get-SemaphoreProjectTemplate
{
	<#
		.SYNOPSIS
			Returns templates for the given project.

		.DESCRIPTION
			This function retrieves information about templates associated with a project.

		.PARAMETER ProjectId
			The ID of the project for which you want to retrieve templates.

		.PARAMETER Id
			(Optional) The ID of the template to retrieve. If specified, only the template with a matching ID will be returned.

		.PARAMETER Name
			(Optional) The name of the template to retrieve. If specified, only the template with a matching name will be returned.

		.EXAMPLE
			Get-SemaphoreProjectTemplate -ProjectId 2

			Retrieves all templates under the project with ID 2.

		.EXAMPLE
			Get-SemaphoreProjectTemplate -ProjectId 5 -TemplateId 2

			Retrieves all templates for the template with ID 2 under the project with ID 5.

		.NOTES
			To use this function, make sure you have already connected using the Connect-Semaphore function.
	#>

	[CmdletBinding(DefaultParameterSetName = 'Default')]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateRange(1, [int]::MaxValue)]
		[int]
		$ProjectId,

		[Parameter(Mandatory = $true, ParameterSetName = "Id")]
		[ValidateRange(1, [int]::MaxValue)]
		$Id,

		[Parameter(Mandatory = $true, ParameterSetName = "Name")]
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
			$Data = Invoke-RestMethod -Uri "$($Script:Config.url)/project/$ProjectId/templates/$Id" -Method Get -ContentType 'application/json' -WebSession $Script:Session
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