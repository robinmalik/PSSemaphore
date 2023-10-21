function Get-SemaphoreProject
{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $false)]
		[string]
		$Name
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
		Write-Verbose -Message "Getting projects"
		try
		{
			$Data = Invoke-RestMethod -Uri "$($Script:Config.url)/projects" -Method Get -ContentType 'application/json' -WebSession $Script:Session
			if($Name)
			{
				$Data = $Data | Where-Object { $_.name -eq $Name }
			}
			$Data
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