# PowerShell script to set up deployment credentials

# Define variables
$appName = "ContosoDevExDevBox"
$displayName = "ContosoDevEx GitHub Actions Enterprise App"

# Function to set up deployment credentials
function Set-Up {
    param (
        [Parameter(Mandatory = $true)]
        [string]$appName,

        [Parameter(Mandatory = $true)]
        [string]$displayName
    )

    try {
        Write-Output "Starting setup for deployment credentials..."

        # Execute the script to generate deployment credentials
        # .\Azure\generateDeploymentCredentials.ps1 -appName $appName -displayName $displayName

        Write-Output "Resetting azd config..."
        azd config reset --no-prompt
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to reset azd config."
        }
        Write-Output "azd config reset successfully."

        Write-Output "Creating new environments..."
        azd env new dev --no-prompt
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to create 'dev' environment."
        }
        azd env new prod --no-prompt
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to create 'prod' environment."
        }
        Write-Output "Environments created successfully."

        Write-Output "Deployment credentials set up successfully."
    }
    catch {
        Write-Error "Error during setup: $_"
        return 1
    }
}

# Main script execution
try {
    Clear-Host
    Set-Up -appName $appName -displayName $displayName
}
catch {
    Write-Error "Script execution failed: $_"
    exit 1
}