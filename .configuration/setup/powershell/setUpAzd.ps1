# Function to create users and assign roles
function New-UsersAndAssignRole {
    param (
        [string]$appId
    )

    try {
        Write-Output "Creating users and assigning roles..."

        # Execute the script to create users and assign roles
        .\Azure\createUsersAndAssignRole.ps1
        if ($LASTEXITCODE -ne 0) {
            throw "Error: Failed to create users and assign roles."
        }

        Write-Output "Users created and roles assigned successfully."
    }
    catch {
        Write-Error "Error: $_"
        return 1
    }
}

New-UsersAndAssignRole

Write-Host "Reseting azd config"
azd config reset --no-prompt
Write-Host "azd config reseted successfully"
Write-Host "Creating new environments"
azd env new dev
azd env new prod
Write-Host "Environments created successfully"
