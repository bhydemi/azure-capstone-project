# Challenge 10: Create Custom Role for Key Vault Secrets and Certificates
# This script creates a custom role that allows users to Get/Set/Delete key vault secrets and certificates

# Connect to Azure (uncomment if not running in Cloud Shell)
# Connect-AzAccount

$subscriptionId = (Get-AzContext).Subscription.Id
$roleName = "VaultSecretCertificateManager"
$roleDescription = "Allows users to manage Key Vault secrets and certificates"

# Check if role already exists
$existingRole = Get-AzRoleDefinition -Name $roleName -ErrorAction SilentlyContinue

if ($existingRole) {
    Write-Host "Role '$roleName' already exists. Updating..."
    $role = $existingRole
} else {
    Write-Host "Creating new role '$roleName'..."
    $role = New-Object Microsoft.Azure.Commands.Resources.Models.Authorization.PSRoleDefinition
}

$role.Name = $roleName
$role.Description = $roleDescription
$role.IsCustom = $true
$role.Id = $null

# Define management plane permissions (read access to vault)
$managementActions = @(
    "Microsoft.KeyVault/vaults/read"
)

# Define data plane permissions for Key Vault secrets and certificates
$dataActions = @(
    # Secret data plane permissions
    "Microsoft.KeyVault/vaults/secrets/getSecret/action",
    "Microsoft.KeyVault/vaults/secrets/setSecret/action",
    "Microsoft.KeyVault/vaults/secrets/delete",
    "Microsoft.KeyVault/vaults/secrets/backup/action",
    "Microsoft.KeyVault/vaults/secrets/restore/action",
    "Microsoft.KeyVault/vaults/secrets/readMetadata/action",
    # Certificate data plane permissions
    "Microsoft.KeyVault/vaults/certificates/read",
    "Microsoft.KeyVault/vaults/certificates/write",
    "Microsoft.KeyVault/vaults/certificates/delete",
    "Microsoft.KeyVault/vaults/certificates/backup/action",
    "Microsoft.KeyVault/vaults/certificates/restore/action",
    "Microsoft.KeyVault/vaults/certificates/managecontacts/action",
    "Microsoft.KeyVault/vaults/certificates/manageissuers/action"
)

$role.Actions = $managementActions
$role.NotActions = @()
$role.DataActions = $dataActions
$role.NotDataActions = @()
$role.AssignableScopes = @("/subscriptions/$subscriptionId")

try {
    if ($existingRole) {
        Set-AzRoleDefinition -Role $role | Out-Null
        Write-Host "Role '$roleName' updated successfully."
    } else {
        New-AzRoleDefinition -Role $role | Out-Null
        Write-Host "Role '$roleName' created successfully."
    }
} catch {
    Write-Error "Error creating/updating role: $_"
    exit 1
}

Write-Host "Role creation complete."
