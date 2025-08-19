$ModuleName = $PSScriptRoot | Split-Path -Parent | Split-Path -Leaf
if(Get-Module -Name $ModuleName) { Remove-Module -Name $ModuleName -Force }
Import-Module -Name "$PSScriptRoot/../Source/$ModuleName.psd1" -Force
$Credential = Import-Clixml -Path "$PSScriptRoot/../Credentials/$([Environment]::MachineName)-semaphore.xml"
Connect-Semaphore -Url 'http://localhost:3000' -Credential $Credential -ErrorAction Stop

InModuleScope $ModuleName {

	Describe "Project Setup" {
		BeforeAll {
			$ProjectName = "PesterTestProject"
			$EnvironmentName = "TestEnvironment"
			$KeyName = "TestKey"
			$TestCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'TestUser', (ConvertTo-SecureString -String 'TestPassword' -AsPlainText -Force)
			$InventoryNameStaticList = "TestInventoryStaticList"
			$InventoryNameFile = "TestInventoryFile"
			$RepositoryName = "TestRepository"
			$RepositoryUrl = "https://github.com/doesnotexist/ansible-playbooks.git"
			$TaskTemplateName = "TestTaskTemplate"
		}

		It "Tests New-SemaphoreProject" {
			{ New-SemaphoreProject -Name $ProjectName } | Should -Not -Throw
		}

		It "Tests New-SemaphoreProjectEnvironment" {
			$ProjectId = (Get-SemaphoreProject -Name $ProjectName).Id
			{ New-SemaphoreProjectEnvironment -ProjectId $ProjectId -Name $EnvironmentName } | Should -Not -Throw
		}

		It "Tests New-SemaphoreProjectKey (without credentials)" {
			$ProjectId = (Get-SemaphoreProject -Name $ProjectName).Id
			{ New-SemaphoreProjectKey -ProjectId $ProjectId -Name "$KeyName-Empty" } | Should -Not -Throw
		}

		It "Tests New-SeamphoreProjectKey (Username and password)" {
			$ProjectId = (Get-SemaphoreProject -Name $ProjectName).Id
			{ New-SemaphoreProjectKey -ProjectId $ProjectId -Name "$KeyName-UserNamePassword" -Type 'UserNamePassword' -Credential $TestCredential } | Should -Not -Throw
		}

		It "Tests New-SemaphoreProjectKey (SSH)" {
			$ProjectId = (Get-SemaphoreProject -Name $ProjectName).Id
			{ New-SemaphoreProjectKey -ProjectId $ProjectId -Name "$KeyName-SSHKey" -Type 'SSHKey' -Credential $TestCredential } | Should -Not -Throw
		}

		It "Tests New-SemaphoreProjectInventory (Static List)" {
			$ProjectId = (Get-SemaphoreProject -Name $ProjectName).Id
			$KeyId = (Get-SemaphoreProjectKey -ProjectId $ProjectId -Name "$KeyName-Empty").Id
			$InventoryData = @('host1', 'host2')
			{ New-SemaphoreProjectInventory -ProjectId $ProjectId -KeyId $KeyId -Name $InventoryNameStaticList -Hostnames $InventoryData } | Should -Not -Throw
		}

		It "Tests New-SemaphoreProjectInventory (File)" {
			$ProjectId = (Get-SemaphoreProject -Name $ProjectName).Id
			$KeyId = (Get-SemaphoreProjectKey -ProjectId $ProjectId -Name "$KeyName-Empty").Id
			$InventoryFile = "/path/to/inventory.ini"
			{ New-SemaphoreProjectInventory -ProjectId $ProjectId -KeyId $KeyId -Name $InventoryNameFile -InventoryFile $InventoryFile } | Should -Not -Throw
		}

		It "Tests New-SemphoreProjectRepository" {
			$ProjectId = (Get-SemaphoreProject -Name $ProjectName).Id
			$KeyId = (Get-SemaphoreProjectKey -ProjectId $ProjectId -Name "$KeyName-Empty").Id
			{ New-SemaphoreProjectRepository -ProjectId $ProjectId -Name $RepositoryName -Url $RepositoryUrl -Branch 'main' -KeyId $KeyId } | Should -Not -Throw
		}

		It "Tests New-SemaphoreProjectTemplate" {
			$ProjectId = (Get-SemaphoreProject -Name $ProjectName).Id
			$KeyId = (Get-SemaphoreProjectKey -ProjectId $ProjectId -Name "$KeyName-Empty").Id
			$InventoryId = (Get-SemaphoreProjectInventory -ProjectId $ProjectId -Name $InventoryNameStaticList).Id
			$RepositoryId = (Get-SemaphoreProjectRepository -ProjectId $ProjectId -Name $RepositoryName).Id
			$EnvironmentId = (Get-SemaphoreProjectEnvironment -ProjectId $ProjectId -Name $EnvironmentName).Id
			$KeyId = (Get-SemaphoreProjectKey -ProjectId $ProjectId -Name "$KeyName-SSHKey").Id
			New-SemaphoreProjectTemplate -ProjectId $ProjectId -InventoryId $InventoryId -RepositoryId $RepositoryId -EnvironmentId $EnvironmentId -KeyId $KeyId -App 'ansible' -Playbook 'test.yml' -Name $TaskTemplateName -AllowLimit
		}
	}

	Describe "Project Teardown" {

		# Remove the project we setup, in reverse order (as dependencies exist):

		BeforeAll {
			$ProjectName = "PesterTestProject"
			$ProjectId = (Get-SemaphoreProject -Name $ProjectName).Id
			$EnvironmentName = "TestEnvironment"
			$KeyName = "TestKey"
			$TestCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'TestUser', (ConvertTo-SecureString -String 'TestPassword' -AsPlainText -Force)
			$InventoryNameStaticList = "TestInventoryStaticList"
			$InventoryNameFile = "TestInventoryFile"
			$RepositoryName = "TestRepository"
			$TaskTemplateName = "TestTaskTemplate"
		}

		# Remove template (top level construct):
		It "Tests Remove-SemaphoreProjectTemplate" {
			$T = Get-SemaphoreProjectTemplate -ProjectId $ProjectId -Name $TaskTemplateName
			{ Remove-SemaphoreProjectTemplate -ProjectId $ProjectId -Id $T.Id } | Should -Not -Throw
		}

		# Remove repository:
		It "Tests Remove-SemaphoreProjectRepository" {
			$R = Get-SemaphoreProjectRepository -ProjectId $ProjectId -Name $RepositoryName
			{ Remove-SemaphoreProjectRepository -ProjectId $ProjectId -Id $R.Id } | Should -Not -Throw
		}

		# Remove inventory:
		It "Tests Remove-SemaphoreProjectInventory" {
			$Inventory = Get-SemaphoreProjectInventory -ProjectId $ProjectId -Name $InventoryNameStaticList
			{ Remove-SemaphoreProjectInventory -ProjectId $ProjectId -Id $Inventory.Id } | Should -Not -Throw

			$Inventory = Get-SemaphoreProjectInventory -ProjectId $ProjectId -Name $InventoryNameFile
			{ Remove-SemaphoreProjectInventory -ProjectId $ProjectId -Id $Inventory.Id } | Should -Not -Throw
		}

		# Remove keys:
		It "Tests Remove-SemaphoreProjectKey" {
			$K = Get-SemaphoreProjectKey -ProjectId $ProjectId -Name "$KeyName-UserNamePassword"
			{ Remove-SemaphoreProjectKey -ProjectId $ProjectId -Id $K.Id } | Should -Not -Throw

			$K = Get-SemaphoreProjectKey -ProjectId $ProjectId -Name "$KeyName-SSHKey"
			{ Remove-SemaphoreProjectKey -ProjectId $ProjectId -Id $K.Id } | Should -Not -Throw

			$K = Get-SemaphoreProjectKey -ProjectId $ProjectId -Name "$KeyName-Empty"
			{ Remove-SemaphoreProjectKey -ProjectId $ProjectId -Id $K.Id } | Should -Not -Throw
		}

		It "Tests Remove-SemaphoreProjectEnvironment" {
			$E = Get-SemaphoreProjectEnvironment -ProjectId $ProjectId -Name $EnvironmentName
			{ Remove-SemaphoreProjectEnvironment -ProjectId $ProjectId -Id $E.Id } | Should -Not -Throw
		}

		# Remove project:
		It "Tests Remove-SemaphoreProject" {
			$P = Get-SemaphoreProject -Name $ProjectName
			{ Remove-SemaphoreProject -Id $P.Id } | Should -Not -Throw
		}
	}
}
Remove-Module -Name $ModuleName -Force