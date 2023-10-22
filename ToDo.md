# To Do:

### Priority Tasks:

* `Start-SemaphoreProjectTask -Wait` can only parse output if the following is set in ansible.cfg:
  ```
  [defaults]
  stdout_callback=debug
  stderr_callback=debug
   ```
   Need to modify to parse non JSON return.
* `New-SemaphoreProjectEnvironment`: Support extra and environment vars being passed. Currently it's just a dummy entry.
* Add suitable regex to $Name params.
* `New-SemaphoreProjectTemplate`: Check for name first, support suppress_success_alerts, allow_override_args_in_task...

### Other:

* Add `-Id` to all Get-* functions. As the Semaphore UI doesn't enforce name uniqueness, if a user creates a duplicate **named** object in the UI (e.g. task template, inventory) this would create problems for the module.
* Test login against an AD bound instance of Semaphore

