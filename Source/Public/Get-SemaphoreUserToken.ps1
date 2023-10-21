function Get-SemaphoreUserToken
{
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