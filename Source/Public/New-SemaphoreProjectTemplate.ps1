function New-SemaphoreProjectTemplate
{
	<#
		.SYNOPSIS
			Creates a new Semaphore project template.

		.DESCRIPTION
			This function creates a new Semaphore project template.

		.PARAMETER ProjectId
			The ID of the project to create the key for.

		.PARAMETER InventoryId
			The ID of the inventory to use for the template.

		.PARAMETER RepositoryId
			The ID of the repository to use for the template.

		.PARAMETER EnvironmentId
			The ID of the environment to use for the template.

		.PARAMETER KeyId
			The ID of the key to use for the template.

		.PARAMETER Playbook
			The playbook to use for the template.

		.PARAMETER Name
			The name of the template to create.

		.PARAMETER Description
			(Optional) The description of the template to create.

		.EXAMPLE
			New-SemaphoreProjectTemplate -ProjectId 2 -InventoryId 1 -RepositoryId 1 -EnvironmentId 1 -KeyId 1 -Playbook "/usr/share/ansible/playbooks/test.yml" -Name "Test"

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
		$InventoryId,

		[Parameter(Mandatory = $true)]
		[ValidateRange(1, [int]::MaxValue)]
		[int]
		$RepositoryId,

		[Parameter(Mandatory = $true)]
		[ValidateRange(1, [int]::MaxValue)]
		[int]
		$EnvironmentId,

		[Parameter(Mandatory = $true)]
		[ValidateRange(1, [int]::MaxValue)]
		[int]
		$KeyId,

		[Parameter(Mandatory = $true)]
		[ValidateSet('ansible')]
		[String]$App,

		[Parameter(Mandatory = $true)]
		[String]$Playbook,

		[Parameter(Mandatory = $true)]
		[String]$Name,

		[Parameter(Mandatory = $false)]
		[Switch]$AllowDebug

		[Parameter(Mandatory = $false)]
		[Switch]$AllowLimit,

		[Parameter(Mandatory = $false)]
		[Switch]$AllowTags,

		[Parameter(Mandatory = $false)]
		[Switch]$AllowSkipTags
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
		#Region Construct body and send the request
		try
		{
			$Body = @{
				'type'           = ''
				'name'           = $Name
				'playbook'       = $Playbook
				'inventory_id'   = $InventoryId
				'repository_id'  = $RepositoryId
				'environment_id' = $EnvironmentId
				'app'            = $App
				'arguments'      = $Arguments
				'project_id'     = $ProjectId
				'task_params'    = @{
					'allow_debug'              = $AllowDebug.IsPresent
					'allow_override_limit'     = $AllowLimit.IsPresent
					'allow_override_tags'      = $AllowTags.IsPresent
					'allow_override_skip_tags' = $AllowSkipTags.IsPresent
				}
			} | ConvertTo-Json

			if($PSCmdlet.ShouldProcess("Project $ProjectId", "Create template $Name"))
			{
				Invoke-RestMethod -Uri "$($Script:Config.url)/project/$ProjectId/templates" -Method Post -Body $Body -ContentType 'application/json' -WebSession $Script:Session | Out-Null
				# Return the created object:
				Get-SemaphoreProjectTemplate -ProjectId $ProjectId -Name $Name
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