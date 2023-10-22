function Get-SemaphoreUserToken
{
	<#
		.SYNOPSIS
			Returns user tokens for the given project.

		.DESCRIPTION
			This function retrieves user tokens for the logged in user.

		.EXAMPLE
			Get-SemaphoreUserToken

			Retrieves all user tokens for the logged in user.

		.NOTES
			To use this function, make sure you have already connected using the Connect-Semaphore function.
	#>

	[CmdletBinding()]
	param (
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
			Invoke-RestMethod -Uri "$($Script:Config.url)/user/tokens" -Method Get -ContentType 'application/json' -WebSession $Script:Session
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