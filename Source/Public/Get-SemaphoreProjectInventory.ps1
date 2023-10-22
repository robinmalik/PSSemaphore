function Get-SemaphoreProjectInventory
{
	<#
		.SYNOPSIS
			Returns inventories for the given project.

		.DESCRIPTION
			This function retrieves information about inventories associated with a project.

		.PARAMETER ProjectId
			The ID of the project for which you want to retrieve environments.

		.PARAMETER Name
			(Optional) The name of the inventory to retrieve. If specified, only the inventory with a matching name will be returned.

		.EXAMPLE
			Get-SemaphoreProjectInventory -ProjectId 2

			Retrieves all inventories under the project with ID 2.

		.EXAMPLE
			Get-SemaphoreProjectInventory -ProjectId 5 -Name "AllHosts"

			Retrieves the "AllHosts" inventory for the project with ID 5.

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
			$Data = Invoke-RestMethod -Uri "$($Script:Config.url)/project/$ProjectId/inventory" -Method Get -ContentType 'application/json' -WebSession $Script:Session
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