function Connect-Semaphore
{
	<#
		.SYNOPSIS
			Connects to Semaphore.

		.DESCRIPTION
			This function connects to Semaphore.

		.PARAMETER Url
			The URL of the Semaphore instance to connect to.

		.PARAMETER Credential
			The credentials to use to connect to Semaphore.

		.EXAMPLE
			Connect-Semaphore -Url https://semaphore.example.com -Credential (Get-Credential)

			Connects to the Semaphore instance at https://semaphore.example.com using the credentials provided.

		.NOTES
			N/A
	#>

	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[ValidatePattern("^(https?://[\w\.-]+)")]
		[String]$Url,

		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[System.Management.Automation.PSCredential]$Credential
	)


	try
	{
		# Add a trailing slash if it's not there:
		if($Url[-1] -ne '/')
		{
			$Url += '/'
		}
		$APIBaseEndPoint = $Url + 'api'

		# Set a script scoped variable containing the host URL (and any other required data), to be used by all calls within the module:
		$Script:Config = [PSCustomObject]@{
			url = $APIBaseEndPoint
		}
	}
	catch
	{
		throw $_
	}


	Write-Verbose -Message "Logging into $Url as $($Credential.UserName)"
	try
	{
		# Construct the body of the request for logging in:
		$Body = @{
			'auth'     = $Credential.UserName
			'password' = $Credential.GetNetworkCredential().Password
		} | ConvertTo-Json -Compress

		# Make the call to login, storing the session in a script scoped variable to be used by all calls within the module:
		Invoke-RestMethod -Uri "$($Script:Config.url)/auth/login" -Method Post -Body $Body -ContentType 'application/json' -SessionVariable Script:Session | Out-Null
	}
	catch
	{
		throw $_
	}
}