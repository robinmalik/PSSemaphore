function Disable-SemaphoreUserToken
{
	<#
		.SYNOPSIS
			Disables a Semaphore user token for the currently authenticated user.

		.DESCRIPTION
			This function disables a Semaphore user token for the currently authenticated user.

		.PARAMETER TokenId
			The ID of the token to disable.

		.EXAMPLE
			Disable-SemaphoreUserToken -TokenId 1

			Disables the token with ID 1.

		.NOTES
			To use this function, make sure you have already connected using the Connect-Semaphore function.
	#>

	[CmdletBinding(SupportsShouldProcess)]
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '', Justification = 'Does not alter system state.')]
	param (
		[Parameter(Mandatory = $true)]
		[String]
		$TokenId
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
		# Encode the token:
		$TokenId = [System.Web.HttpUtility]::UrlEncode($TokenId)

		try
		{
			Invoke-RestMethod -Uri "$($Script:Config.url)/user/tokens/$TokenId" -Method Delete -ContentType 'application/json' -WebSession $Script:Session
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