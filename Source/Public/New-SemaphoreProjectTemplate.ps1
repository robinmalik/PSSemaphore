function New-SemaphoreProjectTemplate
{
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
		[String]$Playbook,

		[Parameter(Mandatory = $true)]
		[String]$Name,

		[Parameter(Mandatory = $false)]
		[String]$Description = 'Inventory created by New-SemaphoreProjectTemplate'
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
		<#
			{
				"project_id": 1,
				"inventory_id": 1,
				"repository_id": 1,
				"environment_id": 1,
				"view_id": 1,
				"name": "Test",
				"playbook": "test.yml",
				"arguments": "[]",
				"description": "Hello, World!",
				"": false,
				"limit": "",
				"suppress_success_alerts": true,
				"survey_vars": [
					{
					"name": "string",
					"title": "string",
					"description": "string",
					"type": "String => \"\", Integer => \"int\"",
					"required": true
					}
				]
			}
		#>



		#Region Construct body and send the request
		try
		{
			$Body = @{
				'type'                        = ''
				'name'                        = $Name
				'description'                 = $Description
				'playbook'                    = $Playbook
				'inventory_id'                = $InventoryId
				'repository_id'               = $RepositoryId
				'environment_id'              = $EnvironmentId
				'vault_key_id'                = $KeyId
				'project_id'                  = $ProjectId
				'suppress_success_alerts'     = $SuppressSuccessAlerts
				'allow_override_args_in_task' = $AllowOverrideArgsInTask
			} | ConvertTo-Json
			Invoke-RestMethod -Uri "$($Script:Config.url)/project/$ProjectId/templates" -Method Post -Body $Body -ContentType 'application/json' -WebSession $Script:Session | Out-Null
			# Return the created object:
			Get-SemaphoreProjectTemplate -ProjectId $ProjectId -Name $Name
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