function New-SemaphoreUserToken
{
	<#
		.SYNOPSIS
			Creates a new token for the logged in user.

		.DESCRIPTION
			This function creates a new token for the logged in user.

		.EXAMPLE
			New-SemaphoreUserToken

		.NOTES
			To use this function, make sure you have already connected using the Connect-Semaphore function.
	#>


	[CmdletBinding(SupportsShouldProcess)]
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
		#Region Send the request
		try
		{
			Invoke-RestMethod -Uri "$($Script:Config.url)/user/tokens" -Method Post -ContentType 'application/json' -WebSession $Script:Session
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