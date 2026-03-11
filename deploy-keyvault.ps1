# Challenge 11: Deploy a Key Vault with PowerShell
# This script creates a Key Vault with a unique name using today's date and initials

# Connect to Azure (uncomment if not running in Cloud Shell)
# Connect-AzAccount

$subscriptionId = (Get-AzContext).Subscription.Id
$resourceGroupName = "rg-shared-vault"
$location = "eastus2"

# Generate unique vault name: kv-devshared-YYYYMMDD + 3 letters
$date = Get-Date -Format "yyyyMMdd"
$initials = "xyz"
$vaultName = "kv-devshared-$date$initials"

$tags = @{
    Environment = "Dev"
    Department = "Engineering"
}

# Check if vault already exists
$existingVault = Get-AzKeyVault -VaultName $vaultName -ErrorAction SilentlyContinue

if ($existingVault) {
    Write-Host "Vault '$vaultName' already exists. Using existing vault."
    $vault = $existingVault
} else {
    Write-Host "Creating new Key Vault: $vaultName"
    
    try {
        $vault = New-AzKeyVault -VaultName $vaultName `
            -ResourceGroupName $resourceGroupName `
            -Location $location `
            -Sku Standard `
            -Tag $tags `
            -EnableRbacAuthorization `
            -ErrorAction Stop
            
        Write-Host "Key Vault '$vaultName' created successfully."
    } catch {
        Write-Error "Error creating Key Vault: $_"
        exit 1
    }
}

# Ensure RBAC is enabled
if (-not $vault.EnableRbacAuthorization) {
    Write-Host "Enabling RBAC authorization on the vault..."
    Set-AzKeyVault -VaultName $vaultName `
        -ResourceGroupName $resourceGroupName `
        -EnableRbacAuthorization | Out-Null
    Write-Host "RBAC authorization enabled."
}

Write-Host "Key Vault deployment complete: $vaultName"
Write-Host "Vault URI: $($vault.VaultUri)"
