function Get-SemaphoreProjectEnvironment
{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateRange(1, [int]::MaxValue)]
		[int]
		$ProjectId,

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
		Write-Verbose -Message "Getting environment(s) for project $ProjectId"
		try
		{
			$Data = Invoke-RestMethod -Uri "$($Script:Config.url)/project/$ProjectId/environment" -Method Get -ContentType 'application/json' -WebSession $Script:Session
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