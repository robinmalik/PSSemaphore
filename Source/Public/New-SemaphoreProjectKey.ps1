function New-SemaphoreProjectKey
{
	<#
		.SYNOPSIS
			Creates a new key for the given project.

		.DESCRIPTION
			This function creates a new key for the given project.

		.PARAMETER ProjectId
			The ID of the project to create the key for.

		.PARAMETER Name
			The name of the key to create.

		.PARAMETER Type
			The type of key to create. Valid values are "UserNamePassword", "SSHKey", and "Empty".

		.PARAMETER Credential
			The credential to use. This parameter is only used if the Type parameter is set to "UserNamePassword" or "SSHKey".

		.EXAMPLE
			New-SemaphoreProjectKey -ProjectId 2 -Name "MyAccount" -Type "UserNamePassword" -Credential $Credential

			Creates a new key with the name "MyAccount" for the project with ID 2, using the username and password in the $Credential variable.

		.NOTES
			To use this function, make sure you have already connected using the Connect-Semaphore function.
	#>

	[CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'EmptyCredentials')]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateRange(1, [int]::MaxValue)]
		[int]
		$ProjectId,

		[Parameter(Mandatory = $true)]
		[string]
		$Name,

		[Parameter(Mandatory = $true, ParameterSetName = 'Credentials')]
		[ValidateSet('UserNamePassword', 'SSHKey', 'Empty')]
		[String]
		$Type,

		[Parameter(Mandatory = $true, ParameterSetName = 'Credentials')]
		[pscredential]$Credential
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
		$CheckIfExists = Get-SemaphoreProjectKey -ProjectId $ProjectId -Name $Name
		if($CheckIfExists)
		{
			throw "A key with the name $Name already exists in project $ProjectId. Please use a different name."
		}
		#EndRegion

		#Region Construct body and send the request
		try
		{
			$Body = @{
				"name"       = $Name
				"project_id" = $ProjectId
			}

			# If the parameter set is Credentials:
			if($PSCmdlet.ParameterSetName -eq 'Credentials')
			{
				# Append the appropriate key type and credentials:
				if($Type -eq 'UserNamePassword')
				{
					$Body.Add("type", "login_password")
					$Body.Add("login_password", @{
							"login"    = $Credential.UserName
							"password" = $Credential.GetNetworkCredential().Password
						})
				}
				elseif($Type -eq 'SSHKey')
				{
					$Body.Add("type", "ssh")
					$Body.Add("ssh", @{
							"private_key" = $Credential.GetNetworkCredential().Password
							"login"       = $Credential.UserName
						})
				}
			}
			else
			{
				# If the default parameter set is EmptyCredentials, so set the type to none:
				$Body.Add("type", "none")
			}

			$Body = $Body | ConvertTo-Json -Compress

			if($PSCmdlet.ShouldProcess("Project $ProjectId", "Create key $Name"))
			{
				Invoke-RestMethod -Uri "$($Script:Config.url)/project/$ProjectId/keys" -Method Post -Body $Body -ContentType 'application/json' -WebSession $Script:Session | Out-Null
				# Return the created object:
				Get-SemaphoreProjectKey -ProjectId $ProjectId -Name $Name
			}
			else
			{
				Write-Verbose -Message "Would create key $Name in project $ProjectId"
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