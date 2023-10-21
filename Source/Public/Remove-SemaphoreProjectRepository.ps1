function Remove-SemaphoreProjectRepository
{
	[CmdletBinding(SupportsShouldProcess)]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateRange(1, [int]::MaxValue)]
		[int]
		$ProjectId,

		[Parameter(Mandatory = $true)]
		[ValidateRange(1, [int]::MaxValue)]
		[int]
		$Id
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
		#Region Send the request to remove
		try
		{
			if($PSCmdlet.ShouldProcess("Project $ProjectId", "Remove $Id"))
			{
				Invoke-RestMethod -Uri "$($Script:Config.url)/project/$ProjectId/repositories/$Id" -Method Delete -WebSession $Script:Session | Out-Null
			}
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
