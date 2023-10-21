function Get-SemaphoreProjectTask
{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateRange(1, [int]::MaxValue)]
		[int]
		$ProjectId,

		[Parameter(Mandatory = $false)]
		[ValidateRange(1, [int]::MaxValue)]
		$Id,

		[Parameter(Mandatory = $false)]
		[ValidateRange(1, [int]::MaxValue)]
		$TemplateId
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
			$Data = Invoke-RestMethod -Uri "$($Script:Config.url)/project/$ProjectId/tasks/$Id" -Method Get -ContentType 'application/json' -WebSession $Script:Session
			# E.g. if we only want the tasks for a specific template (note this will only apply if we are getting all tasks for a project)
			if($TemplateId)
			{
				$Data = $Data | Where-Object { $_.template_id -eq $TemplateId }
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