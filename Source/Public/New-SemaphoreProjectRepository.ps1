function New-SemaphoreProjectRepository
{
	[CmdletBinding(SupportsShouldProcess)]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateRange(1, [int]::MaxValue)]
		[int]
		$ProjectId,

		[Parameter(Mandatory = $true)]
		[String]$Name,

		[Parameter(Mandatory = $true)]
		[String]$Url,

		[Parameter(Mandatory = $true)]
		[String]$Branch,

		[Parameter(Mandatory = $true)]
		[ValidateRange(1, [int]::MaxValue)]
		[Int]$KeyId
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
		#Region Check If Exists
		# Check if already exists by name. Whilst permitted in Semaphore, it's impossible to tell them apart when using them in Task Templates.
		$CheckIfExists = Get-SemaphoreProjectRepository -ProjectId $ProjectId -Name $Name
		if($CheckIfExists)
		{
			throw "A repository with the name $Name already exists in project $ProjectId. Please use a different name."
		}
		#EndRegion

		#Region Construct body and send the request
		try
		{
			$Body = [Ordered]@{
				name       = $Name
				git_url    = $Url
				git_branch = $Branch
				ssh_key_id = $KeyId
				project_id = $ProjectId
			} | ConvertTo-Json -Compress

			if($PSCmdlet.ShouldProcess("Project $ProjectId", "Create repository $Name"))
			{
				Invoke-RestMethod -Uri "$($Script:Config.url)/project/$ProjectId/repositories" -Method Post -Body $Body -ContentType 'application/json' -WebSession $Script:Session | Out-Null
				# Return the created object:
				Get-SemaphoreProjectRepository -ProjectId $ProjectId -Name $Name
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
