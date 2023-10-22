function Start-SemaphoreProjectTask
{
	<#
		.SYNOPSIS
			Triggers a run of a Semaphore template task.

		.DESCRIPTION
			This function triggers a new execution of a task via a Semaphore project template.

		.PARAMETER ProjectId
			The ID of the project.

		.PARAMETER TemplateId
			The ID of the template to run.

		.PARAMETER CLIArguments
			Any CLI arguments to pass to the task.

		.PARAMETER Wait
			Whether to wait for the task to complete before returning.

		.EXAMPLE
			Start-SemaphoreProjectTask -ProjectId 2 -TemplateId 1

			Triggers a run of the template with ID 1 in the project with ID 2.

		.EXAMPLE
			Start-SemaphoreProjectTask -ProjectId 2 -TemplateId 1 -Wait

			Triggers a run of the template with ID 1 in the project with ID 2

		.NOTES
			To use this function, make sure you have already connected using the Connect-Semaphore function.
	#>

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
		#Region Create the body and send the request
		try
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

			$Data = Invoke-RestMethod -Uri "$($Script:Config.url)/project/$ProjectId/tasks" -Method Post -Body $Body -ContentType 'application/json' -WebSession $Script:Session
			if(!$Data)
			{
				return $Null
			}

			# If we're not waiting and polling the task, return data and exit:
			if(!$Wait)
			{
				return $Data
			}
		}
		catch
		{
			throw $_
		}
		#EndRegion


		#Region If Wait, poll the task until it is complete
		if($Wait)
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


			return $Task
		}
		#EndRegion
	}
	end
	{
	}
}