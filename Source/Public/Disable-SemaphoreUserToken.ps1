function Disable-SemaphoreUserToken
{
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