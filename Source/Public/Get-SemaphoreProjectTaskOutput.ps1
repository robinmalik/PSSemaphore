function Get-SemaphoreProjectTaskOutput
{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateRange(1, [int]::MaxValue)]
		[int]
		$ProjectId,

		[Parameter(Mandatory = $false)]
		[ValidateRange(1, [int]::MaxValue)]
		[int]
		$Id,

		[Parameter(Mandatory = $false)]
		[ValidateSet('json', 'text')]
		[string]
		$ParseType = 'json'
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
			$Data = Invoke-RestMethod -Uri "$($Script:Config.url)/project/$ProjectId/tasks/$Id/output" -Method Get -ContentType 'application/json' -WebSession $Script:Session
			if(!$Data)
			{
				return $Null
			}

			# Write all data to the verbose stream so we can see it if we want to:
			Write-Verbose -Message $($Global:Data | Out-String)
		}
		catch
		{
			throw $_
		}

		if($ParseType -eq 'json')
		{
			# The output, when ansible.cfg is set to return JSON is as followed:
			<#
				task_id task time                output
				------- ---- ----                ------
					25      17/10/2023 13:47:53 Task 25 added to queue
					25      17/10/2023 13:47:58 Started: 25
					25      17/10/2023 13:47:58 Run TaskRunner with template: Test Install Via Choco on TESTHOST
					25      17/10/2023 13:47:58 Preparing: 25
					25      17/10/2023 13:47:58 Updating Repository https://github.com/temp/ansibleplaybooks.git
					25      17/10/2023 13:47:58 From https://github.com/temp/ansibleplaybooks
					25      17/10/2023 13:47:58  * branch            main       -> FETCH_HEAD
					25      17/10/2023 13:47:58 Already up to date.
					25      17/10/2023 13:47:58 No collections/requirements.yml file found. Skip galaxy install process.
					25      17/10/2023 13:47:58 No roles/requirements.yml file found. Skip galaxy install process.
					25      17/10/2023 13:48:45 {
					25      17/10/2023 13:48:45     "custom_stats": {},
					25      17/10/2023 13:48:45     "global_custom_stats": {},
					25      17/10/2023 13:48:45     "plays": [
					25      17/10/2023 13:48:45         {
							..................................... SNIP .....................................
					25      17/10/2023 13:48:45         }
					25      17/10/2023 13:48:45     ],
					25      17/10/2023 13:48:45     "stats": {
					25      17/10/2023 13:48:45         "testhost.domain.com": {
					25      17/10/2023 13:48:45             "changed": 1,
					25      17/10/2023 13:48:45             "failures": 0,
					25      17/10/2023 13:48:45             "ignored": 0,
					25      17/10/2023 13:48:45             "ok": 6,
					25      17/10/2023 13:48:45             "rescued": 0,
					25      17/10/2023 13:48:45             "skipped": 0,
					25      17/10/2023 13:48:45             "unreachable": 0
					25      17/10/2023 13:48:45         }
					25      17/10/2023 13:48:45     }
					25      17/10/2023 13:48:45 }
			#>

			#Region Find Start and End of JSON
			try
			{
				# Find the array number where .output equals exactly "{" as this is the start of the JSON data:
				$JSONStart = $Data.Output.IndexOf('{')
				# If -1 then we have no result data yet.
				if($JSONStart -eq -1)
				{
					return $Null
				}

				# Not sure why but LastIndexOf('}') returns an array. Let's use IndexOf('}') instead. This works as the JSON is returned 'pretty' with indentation so the final line is just }.

				$JSONEnd = $Data.Output.IndexOf('}')

				# If this function is called at exactly the right (wrong) time, it can be possible that the { is found but the } is not. This is because the task data is one line per record
				# and presumably behind the scenes, data is still being written to disk and thus we end up with a partial result.

				# To cater to this, if we've found '{' but '}' isn't a value above 0, use a small retry loop making additional queries for the task data.

				$RetryCount = 0
				while(($JSONEnd -lt 0) -and $RetryCount -lt 20)
				{
					$JSONEnd = $Data.Output.IndexOf('}')
					$Data = Invoke-RestMethod -Uri "$($Script:Config.url)/project/$ProjectId/tasks/$Id/output" -Method Get -ContentType 'application/json' -WebSession $Script:Session -Verbose:$False
					$RetryCount++
					Start-Sleep -Seconds 2
				}

				if($JSONEnd -eq -1)
				{
					throw "Unable to find end of JSON data."
				}

				# We are assuming these are integers here...
				if($JSONStart -and $JSONEnd)
				{
					# Add all items in the array between the start and end to a new array:
					$Global:JSON = $Data.Output[$JSONStart..$JSONEnd]
				}
				else
				{
					return $Null
				}
			}
			catch
			{
				throw $_
			}
			#EndRegion

			#Region Convert to a PowerShell object and hope it doesn't break:
			try
			{
				$Converted = $JSON | ConvertFrom-Json -ErrorAction Stop
			}
			catch
			{
				throw $_
			}
			#EndRegion

			#Region Manipulate data to make it more useful:
			# Unfortunately, .stats is converted to singular PSCustomObject (count = 1!) with the host names as NoteProperties and their value is another PSCustomObject
			# with multiple properties (failures, changed, ok ,etc). This means you can't iterate over it to use with Where/Select statements. So, convert it into a useful array of objects:
			return $Converted.stats | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object { [pscustomobject]@{'Name' = $_; 'Results' = $Converted.stats.$_ } }
			#EndRegion
		}
		elseif($ParseType -eq 'text')
		{
			return $Data
		}
		else
		{
		}
	}
	end
	{
	}
}