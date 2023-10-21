
# About

A PowerShell module designed to work against the [Ansible Semaphore](https://github.com/ansible-semaphore/semaphore) REST API.

<br>

# Getting Started:

1. Install the module from the PowerShell Gallery: `Install-Module -Name PSSemaphore`.
2. Run: `Connect-Semaphore -Url 'http://semaphore.domain.com' -Credential (Get-Credential)`
3. Try a command from the 'Simple Examples' below.

<br>

# Examples:

### Create a new project and setup a key, environment, inventory source, repository and task template:
```powershell
$Credential = Get-Credential

$Project = New-SemaphoreProject -Name 'My Project' -MaxParallelTasks 5

$Key = New-SemaphoreProjectKey -ProjectId $Project.Id -Name 'MyKey' -Type UserNamePassword -Credential $Credential

$Environment = New-SemaphoreProjectEnvironment -ProjectId $Project.Id -Name 'MyEnvironment'

$Inventory = New-SemaphoreProjectInventory -ProjectId $Project.Id -Name 'MyInventory' -KeyId $Key.Id -InventoryFile '/path/to/inventory.ini'

$Repository = New-SemaphoreProjectRepository -ProjectId $Project.Id -Name 'MyRepository' -Url 'https://github.com/doesnotexist/myrepo.git' -Branch 'main' -KeyId $Key.Id

$Template = New-SemaphoreProjectTemplate -ProjectId $Project.Id -Name 'MyTemplate' -RepositoryId $Repository.Id -Playbook '/path/to/playbook.yml' -InventoryId $Inventory.Id -EnvironmentId $Environment.Id -KeyId $Key.Id
```


### Start a new run of a task template called 'Install Apache', wait for completion, and get the results:
```powershell
$Template = Get-SemaphoreProjectTemplate -ProjectId 1 -Name 'Install Apache'
$StartTask = Start-SemaphoreProjectTask -ProjectId 1 -TemplateId $Template.Id -Wait
Get-SemaphoreProjectTaskOutput -ProjectId 1 -TaskId $StartTask.Id

Name   Results
----   -------
host1  @{changed=0; failures=0; ignored=0; ok=0; rescued=0; skipped=0; unreachable=1}
host2  @{changed=0; failures=0; ignored=0; ok=6; rescued=0; skipped=0; unreachable=0}
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
Get-SemaphoreProjectTaskOutput -ProjectId 1 -Id $Task.Id
```

<br>

# Notes:

For things on the roadmap, see [ToDo.md](ToDo.md).

<br>

# Troubleshooting:

...

<br>

# Resources:

* [Ansible Semaphore Swagger API Documentation](https://www.ansible-semaphore.com/api-docs/#/)