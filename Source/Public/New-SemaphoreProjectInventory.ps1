function New-SemaphoreProjectInventory
{
	<#
		.SYNOPSIS
			Creates a new inventory for the given project.

		.DESCRIPTION
			This function creates a new inventory for the given project.

		.PARAMETER ProjectId
			The ID of the project to create the inventory for.

		.PARAMETER KeyId
			The ID of the key to use for the inventory.

		.PARAMETER Name
			The name of the inventory to create.

		.PARAMETER Hostnames
			(Optional) The hostnames to use for the inventory. If not specified, the InventoryFile parameter must be specified.

		.PARAMETER WinRMConnection
			(Optional) Whether to use WinRM for the connection. This works by adding specific variables to the static inventory.

		.PARAMETER InventoryFile
			(Optional) The path to the inventory file to use. If not specified, the Hostnames parameter must be specified.

		.EXAMPLE
			New-SemaphoreProjectInventory -ProjectId 2 -KeyId 1 -Name "Production" -Hostnames "server1", "server2"

			Creates a new inventory with the name "Production" for the project with ID 2, using the key with ID 1, and with the hostnames "server1" and "server2".

		.EXAMPLE
			New-SemaphoreProjectInventory -ProjectId 2 -KeyId 1 -Name "Test" -InventoryFile "/usr/share/ansible/inventories/webhosts.ini"

			Creates a new inventory with the name "Test" for the project with ID 2, using the key with ID 1, and using the inventory file "/usr/share/ansible/inventories/webhosts.ini".

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
		$KeyId,

		[Parameter(Mandatory = $true)]
		[string]
		$Name,

		[Parameter(Mandatory = $true, ParameterSetName = 'Static')]
		[string[]]$Hostnames,

		[Parameter(Mandatory = $false, ParameterSetName = 'Static')]
		[Switch]$WinRMConnection,

		[Parameter(Mandatory = $true, ParameterSetName = 'File')]
		[string]$InventoryFile
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
		#Region Check If Exists
		# Check if already exists by name. Whilst permitted in Semaphore, it's impossible to tell them apart when using them in Task Templates.
		$CheckIfExists = Get-SemaphoreProjectInventory -ProjectId $ProjectId -Name $Name
		if($CheckIfExists)
		{
			throw "An inventory with the name $Name already exists in project $ProjectId. Please use a different name."
		}
		#EndRegion

		#Region Construct body and send the request
		try
		{
			$Body = @{
				"name"          = $Name.ToLower()
				"project_id"    = $ProjectId
				"ssh_key_id"    = $KeyId
				"become_key_id" = $KeyId
			}

			if($Hostnames)
			{
				$InventoryData = "[$Name]`n" + ($Hostnames -join "`n")
				if($WinRMConnection)
				{
					$InventoryData += "`n`n"
					$InventoryData += "[$($Name):vars]`n"
					$InventoryData += "ansible_connection=winrm`n"
					$InventoryData += "ansible_winrm_transport=ntlm`n"
					$InventoryData += "ansible_winrm_server_cert_validation=ignore`n"
				}

				$Body.Add("inventory", $InventoryData)
				$Body.Add("type", "static")
			}
			elseif($InventoryFile)
			{
				$Body.Add("inventory", $InventoryFile)
				$Body.Add("type", "file")
			}

			$Body = $Body | ConvertTo-Json -Compress

			if($PSCmdlet.ShouldProcess("Project $ProjectId", "Create inventory $Name"))
			{
				Invoke-RestMethod -Uri "$($Script:Config.url)/project/$ProjectId/inventory" -Method Post -Body $Body -ContentType 'application/json' -WebSession $Script:Session
				# Return the created object| EDIT: No need because it actually returns the object...
				#Get-SemaphoreProjectInventory -ProjectId $ProjectId -Name $Name
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