function Start-SemaphoreProjectTask
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
		$TemplateId,

		[Parameter(Mandatory = $false)]
		[String]$CLIArguments,

		[Parameter(Mandatory = $false)]
		[Switch]
		$Wait
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
		$Body = @{
			"template_id" = $TemplateId
			"environment" = "{}"
			"project_id"  = $ProjectId
		}

		if($CLIArguments)
		{
			$Body.Add("cli_arguments", $CLIArguments)
		}

		try
		{
			$Data = Invoke-RestMethod -Uri "$($Script:Config.url)/project/$ProjectId/tasks" -Method Post -Body $Body -ContentType 'application/json' -WebSession $Script:Session
			if(!$Data)
			{
				return $Null
			}
		}
		catch
		{
			throw $_
		}


		if(!$Wait)
		{
			return $Data
		}
		else
		{
			# Start a loop that calls Get-SemaphoreProjectTask with the Id returned from the previous call. If the status property is running or success
			# break out of the loop and return the task object. Attempt the loop for a maximum of 50 attempts with 5 seconds wait between each attempt.
			$AttemptCount = 0
			$MaxAttempts = 50
			$WaitTime = 5
			$TaskId = $Data.id
			do
			{
				$AttemptCount++
				Write-Verbose -Message "Attempt $AttemptCount of $MaxAttempts"
				Write-Progress -Activity "Waiting for task to complete" -Status "Attempt $AttemptCount of $MaxAttempts" -PercentComplete (($AttemptCount / $MaxAttempts) * 100)

				try
				{
					$Task = Get-SemaphoreProjectTask -ProjectId $ProjectId -TaskId $TaskId
					if($Task.status -eq "running")
					{
						Write-Verbose -Message "Task is running"
						Start-Sleep -Seconds $WaitTime
					}
					elseif($Task.status -eq "waiting")
					{
						Write-Verbose -Message "Task is waiting"
						Start-Sleep -Seconds $WaitTime
					}
					else
					{
						Write-Verbose -Message "Task status is: $($Task.status)"
						break
					}
				}
				catch
				{
					throw $_
				}
			}
			until($AttemptCount -eq $MaxAttempts)
		}

		return $Task
	}
	end
	{
	}
}