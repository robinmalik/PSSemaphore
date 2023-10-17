
# About

A PowerShell module designed to work against the [Ansible Semaphore](https://github.com/ansible-semaphore/semaphore) REST API.

<br>

# Getting Started:

1. Install the module from the PowerShell Gallery: `Install-Module -Name PSSemaphore`.
2. Run: ...
3. Try a command from the 'Simple Examples' below.

<br>

# Examples:

### Start a new run of a task template 'Install Apache', wait for completion, and get the results:
```powershell
$Template = Get-SemaphoreProjectTemplate -ProjectId 1 -Name 'Install Apache'
$StartTask = Start-SemaphoreProjectTask -ProjectId 1 -TemplateId $Template.Id -Wait
Get-SemaphoreProjectTaskOutput -ProjectId 1 -TaskId $StartTask.Id

Name                              Results
----                              -------
noexist.lunrc.lboro.ac.uk         @{changed=0; failures=0; ignored=0; ok=0; rescued=0; skipped=0; unreachable=1}
rcdowhatyouwant.lunrc.lboro.ac.uk @{changed=0; failures=0; ignored=0; ok=6; rescued=0; skipped=0; unreachable=0}
```


### Get a list of all task runs for a task template called 'Install PHP':
```powershell
$Template = Get-SemaphoreProjectTemplate -ProjectId 1 -Name 'Install PHP'
Get-SemaphoreProjectTask -ProjectId 1 -TemplateId $Template.Id

id template_id project_id status debug dry_run  diff playbook environment limit
-- ----------- ---------- ------ ----- -------  ---- -------- ----------- -----
40           1          1 error  False   False False          {}
39           1          1 error  False   False False          {}
38           1          1 error  False   False False          {}
37           1          1 error  False   False False          {}
```

### Get output for the last run of a task for a specific template:
```powershell
$Task = Get-SemaphoreProjectTask -ProjectId 1 -TemplateId 1 | Select-Object -First 1
Get-SemaphoreProjectTaskOutput -ProjectId 1 -TaskId $Task.Id
```

### Create a file based inventory:
```powershell
$Key = Get-SemaphoreProjectKey -ProjectId 1 -Name 'schedule-svc (lunrc)'
New-SemaphoreProjectInventory -ProjectId 1 -KeyId $Key.Id -Name 'all-hosts' -InventoryFile '/inventories/mwss/lunrc/all-hosts/inventory.ini'
```
<br>

# Notes:

...

<br>

# Troubleshooting:

...

<br>

# Resources:

* [Ansible Semaphore Swagger API Documentation](https://www.ansible-semaphore.com/api-docs/#/)