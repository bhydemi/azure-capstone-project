# Challenge 11: Deploy a Key Vault with PowerShell
# This script creates a Key Vault with a unique name using today's date and initials

# Connect to Azure (uncomment if not running in Cloud Shell)
# Connect-AzAccount

$subscriptionId = (Get-AzContext).Subscription.Id
$resourceGroupName = "rg-shared-vault"
$location = "eastus2"

$tags = @{
    Environment = "Dev"
    Department = "Engineering"
}

# Ensure resource group exists
$existingRg = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if (-not $existingRg) {
    Write-Host "Creating resource group '$resourceGroupName'..."
    New-AzResourceGroup -Name $resourceGroupName -Location $location -Tag $tags | Out-Null
    Write-Host "Resource group '$resourceGroupName' created successfully."
} else {
    Write-Host "Resource group '$resourceGroupName' already exists. Updating tags..."
    Set-AzResourceGroup -Name $resourceGroupName -Tag $tags | Out-Null
}

# Ensure Delete lock exists on the resource group
$lockName = "DeleteLock"
$existingLock = Get-AzResourceLock -ResourceGroupName $resourceGroupName -LockName $lockName -ErrorAction SilentlyContinue
if (-not $existingLock) {
    Write-Host "Creating Delete lock '$lockName' on resource group '$resourceGroupName'..."
    New-AzResourceLock -LockName $lockName -LockLevel CanNotDelete -ResourceGroupName $resourceGroupName -Force | Out-Null
    Write-Host "Delete lock created successfully."
} else {
    Write-Host "Delete lock '$lockName' already exists on resource group '$resourceGroupName'."
}

# Generate unique vault name: kv-devshared-YYYYMMDD + 3 letters
$date = Get-Date -Format "yyyyMMdd"
$initials = "xyz"
$vaultName = "kv-devshared-$date$initials"

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
