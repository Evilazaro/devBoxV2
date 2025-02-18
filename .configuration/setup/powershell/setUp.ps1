# PowerShell script to set up deployment credentials

# Define variables
$appName = "ContosoDevExDevBox"
$displayName = "ContosoDevEx GitHub Actions Enterprise App"

# Function to set up deployment credentials
function Set-DeploymentCredentials {
    param (
        [Parameter(Mandatory = $true)]
        [string]$appName,

        [Parameter(Mandatory = $true)]
        [string]$displayName
    )

    try {
        Write-Output "Setting up deployment credentials..."

        # Execute the script to generate deployment credentials
        .\Azure\generateDeploymentCredentials.ps1 -appName $appName -displayName $displayName
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to set up deployment credentials."
        }

        Write-Output "Deployment credentials set up successfully."
    }
    catch {
        Write-Error "Error: $_"
        return 1
    }
}

# Main script execution
try {
    Clear-Host
    Set-DeploymentCredentials -appName $appName -displayName $displayName
}
catch {
    Write-Error "Script execution failed: $_"
    exit 1
}