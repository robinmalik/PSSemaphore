function Get-SemaphoreProjectKey
{
	<#
		.SYNOPSIS
			Returns keys for the given project.

		.DESCRIPTION
			This function retrieves information about keys associated with a project.

		.PARAMETER ProjectId
			The ID of the project for which you want to retrieve keys.

		.PARAMETER Name
			(Optional) The name of the key to retrieve. If specified, only the key with a matching name will be returned.

		.EXAMPLE
			Get-SemaphoreProjectKey -ProjectId 2

			Retrieves all keys under the project with ID 2.

		.EXAMPLE
			Get-SemaphoreProjectKey -ProjectId 5 -Name "MyAccount"

			Retrieves the "MyAccount" key for the project with ID 5.

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
			$Data = Invoke-RestMethod -Uri "$($Script:Config.url)/project/$ProjectId/keys" -Method Get -ContentType 'application/json' -WebSession $Script:Session
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