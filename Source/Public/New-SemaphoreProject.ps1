function New-SemaphoreProject
{
	<#
		.SYNOPSIS
			Creates a new project.

		.DESCRIPTION
			Creates a new project.

		.PARAMETER Name
			The name of the project to create.

		.PARAMETER Alert
			(Optional) Whether to send alerts for this project.

		.PARAMETER TelegramChatId
			(Optional) The Telegram chat ID to send alerts to.

		.PARAMETER MaxParallelTasks
			(Optional) The maximum number of parallel tasks to run.

		.EXAMPLE
			New-SemaphoreProject -Name "My Project"

			Creates a new project with the name "My Project".

		.EXAMPLE
			New-SemaphoreProject -Name "My Project" -Alert -TelegramChatId "123456789" -MaxParallelTasks 5

			Creates a new project with the name "My Project", with alerts enabled, sending alerts to the Telegram chat with ID "123456789", and with a maximum of 5 parallel tasks.

		.NOTES
			To use this function, make sure you have already connected using the Connect-Semaphore function.
		#>

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