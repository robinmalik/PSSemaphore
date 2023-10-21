function New-SemaphoreUserToken
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