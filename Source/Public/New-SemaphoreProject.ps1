function New-SemaphoreProject
{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[String]$Name,

		[Parameter(Mandatory = $false)]
		[Switch]$Alert,

		[Parameter(Mandatory = $false)]
		[String]$TelegramChatId,

		[Parameter(Mandatory = $false)]
		[ValidateRange(0, [int]::MaxValue)]
		[Int]$MaxParallelTasks
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
		$CheckIfExists = Get-SemaphoreProject -Name $Name
		if($CheckIfExists)
		{
			throw "An project with the name $Name already exists in project $ProjectId. Please use a different name."
		}
		#EndRegion

		#Region Construct body and send the request
		try
		{
			$Body = @{
				name = $Name
			}

			if($Alert)
			{
				$Body.Add("alert", $true)
			}

			if($TelegramChatId)
			{
				$Body.Add("telegram_chat_id", $TelegramChatId)
			}

			if($MaxParallelTasks)
			{
				$Body.Add("max_parallel_tasks", $MaxParallelTasks)
			}

			$Body = $Body | ConvertTo-Json -Compress
			Invoke-RestMethod -Uri "$($Script:Config.url)/projects" -Method Post -Body $Body -ContentType 'application/json' -WebSession $Script:Session
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