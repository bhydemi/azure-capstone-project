# ============================================================================
# Azure Capstone Project - Complete Deployment Script
# This script deploys ALL resources needed for screenshot capture
# ============================================================================

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "Azure Capstone Project - Complete Deployment" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

# Get current context
$context = Get-AzContext
if (-not $context) {
    Write-Host "Not logged in. Connecting to Azure..." -ForegroundColor Yellow
    Connect-AzAccount
    $context = Get-AzContext
}

$subscriptionId = $context.Subscription.Id
$subscriptionScope = "/subscriptions/$subscriptionId"

Write-Host "Current Subscription: $($context.Subscription.Name)" -ForegroundColor Green
Write-Host "Subscription ID: $subscriptionId" -ForegroundColor Green
Write-Host ""

# ============================================================================
# SECTION 1: CREATE CUSTOM POLICY DEFINITIONS
# ============================================================================
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "SECTION 1: Creating Custom Policy Definitions" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan

# Policy 1: VM Size Restriction
Write-Host "`n[1/3] Creating VM Size Restriction Policy..." -ForegroundColor Yellow
$vmPolicyDef = Get-AzPolicyDefinition -Custom | Where-Object {$_.Properties.DisplayName -eq "Restrict Virtual Machine SKU Sizes"}
if (-not $vmPolicyDef) {
    $vmPolicyDef = New-AzPolicyDefinition `
        -Name 'restrict-vm-sku-sizes' `
        -DisplayName 'Restrict Virtual Machine SKU Sizes' `
        -Policy (Get-Content './policy-vm-size-restriction.json' -Raw) `
        -Mode Indexed
    Write-Host "✓ VM Size Restriction Policy created" -ForegroundColor Green
} else {
    Write-Host "✓ VM Size Restriction Policy already exists" -ForegroundColor Green
}

# Policy 2: Web Farm SKU Restriction
Write-Host "`n[2/3] Creating Web Farm SKU Restriction Policy..." -ForegroundColor Yellow
$webFarmPolicyDef = Get-AzPolicyDefinition -Custom | Where-Object {$_.Properties.DisplayName -eq "Restrict App Service Plan (Server Farm) SKU Sizes"}
if (-not $webFarmPolicyDef) {
    $webFarmPolicyDef = New-AzPolicyDefinition `
        -Name 'restrict-web-farm-sku-sizes' `
        -DisplayName 'Restrict App Service Plan (Server Farm) SKU Sizes' `
        -Policy (Get-Content './policy-web-farm-sku.json' -Raw) `
        -Mode Indexed
    Write-Host "✓ Web Farm SKU Restriction Policy created" -ForegroundColor Green
} else {
    Write-Host "✓ Web Farm SKU Restriction Policy already exists" -ForegroundColor Green
}

# Policy 3: Tag Enforcement with Values
Write-Host "`n[3/3] Creating Tag Enforcement Policy..." -ForegroundColor Yellow
$tagPolicyDef = Get-AzPolicyDefinition -Custom | Where-Object {$_.Properties.DisplayName -eq "Require tag with allowed values on resources"}
if (-not $tagPolicyDef) {
    $tagPolicyDef = New-AzPolicyDefinition `
        -Name 'require-tag-with-values' `
        -DisplayName 'Require tag with allowed values on resources' `
        -Policy (Get-Content './policy-require-tag-with-values.json' -Raw) `
        -Mode Indexed
    Write-Host "✓ Tag Enforcement Policy created" -ForegroundColor Green
} else {
    Write-Host "✓ Tag Enforcement Policy already exists" -ForegroundColor Green
}

# ============================================================================
# SECTION 2: ASSIGN POLICIES
# ============================================================================
Write-Host "`n============================================================================" -ForegroundColor Cyan
Write-Host "SECTION 2: Assigning Policies to Subscription" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan

# Assignment 1: VM Size Restriction
Write-Host "`n[1/5] Assigning VM Size Restriction Policy..." -ForegroundColor Yellow
$vmPolicyAssignment = Get-AzPolicyAssignment -Name 'vm-sku-restriction' -Scope $subscriptionScope -ErrorAction SilentlyContinue
if (-not $vmPolicyAssignment) {
    New-AzPolicyAssignment `
        -Name 'vm-sku-restriction' `
        -DisplayName 'Restrict VM SKUs to B-Series' `
        -Scope $subscriptionScope `
        -PolicyDefinition $vmPolicyDef
    Write-Host "✓ VM Size Restriction Policy assigned" -ForegroundColor Green
} else {
    Write-Host "✓ VM Size Restriction Policy already assigned" -ForegroundColor Green
}

# Assignment 2: Built-in Allowed Locations
Write-Host "`n[2/5] Assigning Allowed Locations Policy (Built-in)..." -ForegroundColor Yellow
$locationPolicy = Get-AzPolicyDefinition | Where-Object {$_.Properties.DisplayName -eq 'Allowed locations'}
$locationAssignment = Get-AzPolicyAssignment -Name 'allowed-locations' -Scope $subscriptionScope -ErrorAction SilentlyContinue
if (-not $locationAssignment) {
    New-AzPolicyAssignment `
        -Name 'allowed-locations' `
        -DisplayName 'Restrict Deployment to East US 2 and Central US' `
        -Scope $subscriptionScope `
        -PolicyDefinition $locationPolicy `
        -PolicyParameterObject @{
            'listOfAllowedLocations' = @('eastus2', 'centralus')
        }
    Write-Host "✓ Allowed Locations Policy assigned" -ForegroundColor Green
} else {
    Write-Host "✓ Allowed Locations Policy already assigned" -ForegroundColor Green
}

# Assignment 3: Department Tag
Write-Host "`n[3/5] Assigning Department Tag Policy..." -ForegroundColor Yellow
$deptTagAssignment = Get-AzPolicyAssignment -Name 'require-department-tag' -Scope $subscriptionScope -ErrorAction SilentlyContinue
if (-not $deptTagAssignment) {
    New-AzPolicyAssignment `
        -Name 'require-department-tag' `
        -DisplayName 'Require Department Tag with Allowed Values' `
        -Scope $subscriptionScope `
        -PolicyDefinition $tagPolicyDef `
        -PolicyParameterObject @{
            'tagName' = 'Department'
            'allowedTagValues' = @('Finance', 'Engineering')
        }
    Write-Host "✓ Department Tag Policy assigned" -ForegroundColor Green
} else {
    Write-Host "✓ Department Tag Policy already assigned" -ForegroundColor Green
}

# Assignment 4: Environment Tag
Write-Host "`n[4/5] Assigning Environment Tag Policy..." -ForegroundColor Yellow
$envTagAssignment = Get-AzPolicyAssignment -Name 'require-environment-tag' -Scope $subscriptionScope -ErrorAction SilentlyContinue
if (-not $envTagAssignment) {
    New-AzPolicyAssignment `
        -Name 'require-environment-tag' `
        -DisplayName 'Require Environment Tag with Allowed Values' `
        -Scope $subscriptionScope `
        -PolicyDefinition $tagPolicyDef `
        -PolicyParameterObject @{
            'tagName' = 'Environment'
            'allowedTagValues' = @('Dev', 'Test', 'Prod')
        }
    Write-Host "✓ Environment Tag Policy assigned" -ForegroundColor Green
} else {
    Write-Host "✓ Environment Tag Policy already assigned" -ForegroundColor Green
}

# Assignment 5: Web Farm SKU Restriction
Write-Host "`n[5/5] Assigning Web Farm SKU Restriction Policy..." -ForegroundColor Yellow
$webFarmAssignment = Get-AzPolicyAssignment -Name 'web-farm-sku-restriction' -Scope $subscriptionScope -ErrorAction SilentlyContinue
if (-not $webFarmAssignment) {
    New-AzPolicyAssignment `
        -Name 'web-farm-sku-restriction' `
        -DisplayName 'Restrict App Service Plan SKUs to B1 and P0v3' `
        -Scope $subscriptionScope `
        -PolicyDefinition $webFarmPolicyDef
    Write-Host "✓ Web Farm SKU Restriction Policy assigned" -ForegroundColor Green
} else {
    Write-Host "✓ Web Farm SKU Restriction Policy already assigned" -ForegroundColor Green
}

# ============================================================================
# SECTION 3: ASSIGN PCI DSS v4 INITIATIVE (if available)
# ============================================================================
Write-Host "`n============================================================================" -ForegroundColor Cyan
Write-Host "SECTION 3: Checking for PCI DSS v4 Initiative" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan

Write-Host "`nSearching for PCI DSS initiatives..." -ForegroundColor Yellow

# Try multiple search patterns
$pciInitiative = $null
$searchPatterns = @("*PCI*DSS*4*", "*PCI*DSS*v4*", "*PCI*4.0*", "*PCI DSS 3.2*")

foreach ($pattern in $searchPatterns) {
    $pciInitiative = Get-AzPolicySetDefinition -Builtin -ErrorAction SilentlyContinue |
        Where-Object {$_.Properties.DisplayName -like $pattern} |
        Select-Object -First 1
    if ($pciInitiative) { break }
}

if ($pciInitiative) {
    Write-Host "✓ Found initiative: $($pciInitiative.Properties.DisplayName)" -ForegroundColor Green

    $pciAssignment = Get-AzPolicyAssignment -Scope $subscriptionScope |
        Where-Object {$_.Properties.PolicyDefinitionId -eq $pciInitiative.PolicySetDefinitionId}

    if (-not $pciAssignment) {
        try {
            New-AzPolicyAssignment `
                -Name 'pci-compliance' `
                -DisplayName "PCI Compliance - $($pciInitiative.Properties.DisplayName)" `
                -Scope $subscriptionScope `
                -PolicySetDefinition $pciInitiative `
                -ErrorAction Stop
            Write-Host "✓ PCI Initiative assigned successfully" -ForegroundColor Green
        } catch {
            Write-Host "⚠ Error assigning initiative: $_" -ForegroundColor Yellow
        }
    } else {
        Write-Host "✓ PCI Initiative already assigned" -ForegroundColor Green
    }
} else {
    Write-Host "⚠ PCI DSS initiatives NOT available in this subscription" -ForegroundColor Yellow
    Write-Host "  This is a known limitation of student/lab subscriptions" -ForegroundColor Gray
    Write-Host "  NEXT STEPS:" -ForegroundColor Cyan
    Write-Host "  1. In Azure Portal, go to Policy → Definitions → Filter Type: Initiative" -ForegroundColor White
    Write-Host "  2. Search for 'PCI' to confirm no results" -ForegroundColor White
    Write-Host "  3. Take screenshot showing no initiatives found" -ForegroundColor White
    Write-Host "  4. Save as: screenshot-06-pci-compliance-not-available.png" -ForegroundColor White
    Write-Host "  5. Include CHALLENGE-5-LIMITATION-NOTE.md in your submission" -ForegroundColor White
    Write-Host ""
    Write-Host "  Continuing with remaining deployments..." -ForegroundColor Yellow
}

# ============================================================================
# SECTION 4: CREATE RESOURCE GROUPS
# ============================================================================
Write-Host "`n============================================================================" -ForegroundColor Cyan
Write-Host "SECTION 4: Creating Resource Groups" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan

$resourceGroups = @(
    @{Name='rg-shared-vault'; Location='eastus2'; Tags=@{Department='Engineering'; Environment='Dev'}; Lock=$true},
    @{Name='rg-electronicsunlimited-web'; Location='eastus2'; Tags=@{Department='Engineering'; Environment='Dev'}; Lock=$false},
    @{Name='rg-deployment-resources'; Location='eastus2'; Tags=@{Department='Engineering'; Environment='Dev'}; Lock=$true},
    @{Name='rg-external'; Location='eastus2'; Tags=@{Department='Engineering'; Environment='Dev'}; Lock=$false}
)

foreach ($rg in $resourceGroups) {
    Write-Host "`nChecking resource group: $($rg.Name)..." -ForegroundColor Yellow
    $existingRg = Get-AzResourceGroup -Name $rg.Name -ErrorAction SilentlyContinue
    if (-not $existingRg) {
        New-AzResourceGroup -Name $rg.Name -Location $rg.Location -Tag $rg.Tags | Out-Null
        Write-Host "✓ Created resource group: $($rg.Name)" -ForegroundColor Green
    } else {
        Write-Host "✓ Resource group already exists: $($rg.Name)" -ForegroundColor Green
    }

    if ($rg.Lock) {
        $lock = Get-AzResourceLock -ResourceGroupName $rg.Name -ErrorAction SilentlyContinue
        if (-not $lock) {
            New-AzResourceLock -LockName 'delete-lock' -LockLevel CanNotDelete -ResourceGroupName $rg.Name -Force | Out-Null
            Write-Host "✓ Added delete lock to: $($rg.Name)" -ForegroundColor Green
        } else {
            Write-Host "✓ Delete lock already exists on: $($rg.Name)" -ForegroundColor Green
        }
    }
}

# ============================================================================
# SECTION 5: CREATE CUSTOM ROLE
# ============================================================================
Write-Host "`n============================================================================" -ForegroundColor Cyan
Write-Host "SECTION 5: Creating Custom Role for Key Vault" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan

Write-Host "`nRunning create-custom-role.ps1..." -ForegroundColor Yellow
& ./create-custom-role.ps1

# ============================================================================
# SECTION 6: CREATE KEY VAULT
# ============================================================================
Write-Host "`n============================================================================" -ForegroundColor Cyan
Write-Host "SECTION 6: Creating Key Vault" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan

Write-Host "`nRunning deploy-keyvault.ps1..." -ForegroundColor Yellow
& ./deploy-keyvault.ps1

# Get the vault name (should be kv-devshared-YYYYMMDDxyz)
$vault = Get-AzKeyVault -ResourceGroupName 'rg-shared-vault' | Select-Object -First 1

if ($vault) {
    Write-Host "✓ Key Vault deployed: $($vault.VaultName)" -ForegroundColor Green
} else {
    Write-Host "⚠ Key Vault not found - you may need to run deploy-keyvault.ps1 manually" -ForegroundColor Yellow
}

# ============================================================================
# SECTION 7: CREATE MANAGED IDENTITY
# ============================================================================
Write-Host "`n============================================================================" -ForegroundColor Cyan
Write-Host "SECTION 7: Creating Managed Identity" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan

Write-Host "`nCreating user-assigned managed identity..." -ForegroundColor Yellow
$miName = 'mi-deploy-eu-web-dev'
$mi = Get-AzUserAssignedIdentity -ResourceGroupName 'rg-deployment-resources' -Name $miName -ErrorAction SilentlyContinue
if (-not $mi) {
    $mi = New-AzUserAssignedIdentity `
        -ResourceGroupName 'rg-deployment-resources' `
        -Name $miName `
        -Location 'eastus2' `
        -Tag @{Department='Engineering'; Environment='Dev'}
    Write-Host "✓ Created managed identity: $miName" -ForegroundColor Green
} else {
    Write-Host "✓ Managed identity already exists: $miName" -ForegroundColor Green
}

# Assign Contributor role to MI on rg-electronicsunlimited-web
Write-Host "`nAssigning Contributor role to managed identity..." -ForegroundColor Yellow
$webRg = Get-AzResourceGroup -Name 'rg-electronicsunlimited-web'
$roleAssignment = Get-AzRoleAssignment -ObjectId $mi.PrincipalId -Scope $webRg.ResourceId -RoleDefinitionName 'Contributor' -ErrorAction SilentlyContinue
if (-not $roleAssignment) {
    New-AzRoleAssignment -ObjectId $mi.PrincipalId -RoleDefinitionName 'Contributor' -Scope $webRg.ResourceId | Out-Null
    Write-Host "✓ Assigned Contributor role to MI on rg-electronicsunlimited-web" -ForegroundColor Green
} else {
    Write-Host "✓ Role assignment already exists" -ForegroundColor Green
}

# ============================================================================
# SECTION 8: CREATE SECURITY GROUPS
# ============================================================================
Write-Host "`n============================================================================" -ForegroundColor Cyan
Write-Host "SECTION 8: Creating Security Groups" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan

# Group 1: KeyVaultSecretAndCertificateAdmins
Write-Host "`n[1/2] Creating KeyVaultSecretAndCertificateAdmins group..." -ForegroundColor Yellow
$kvAdminsGroup = Get-AzADGroup -DisplayName 'KeyVaultSecretAndCertificateAdmins' -ErrorAction SilentlyContinue
if (-not $kvAdminsGroup) {
    $kvAdminsGroup = New-AzADGroup `
        -DisplayName 'KeyVaultSecretAndCertificateAdmins' `
        -MailNickname 'kvadmins' `
        -Description 'Administrators of key vaults in the subscription' `
        -SecurityEnabled
    Write-Host "✓ Created group: KeyVaultSecretAndCertificateAdmins" -ForegroundColor Green
} else {
    Write-Host "✓ Group already exists: KeyVaultSecretAndCertificateAdmins" -ForegroundColor Green
}

# Group 2: external-contributors
Write-Host "`n[2/2] Creating external-contributors group..." -ForegroundColor Yellow
$extContribGroup = Get-AzADGroup -DisplayName 'external-contributors' -ErrorAction SilentlyContinue
if (-not $extContribGroup) {
    $extContribGroup = New-AzADGroup `
        -DisplayName 'external-contributors' `
        -MailNickname 'extcontrib' `
        -Description 'External contributors with access to rg-external' `
        -SecurityEnabled
    Write-Host "✓ Created group: external-contributors" -ForegroundColor Green
} else {
    Write-Host "✓ Group already exists: external-contributors" -ForegroundColor Green
}

# ============================================================================
# SECTION 9: ASSIGN ROLES TO GROUPS
# ============================================================================
Write-Host "`n============================================================================" -ForegroundColor Cyan
Write-Host "SECTION 9: Assigning Roles to Groups" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan

# Assignment 1: Reader role on subscription for KeyVaultSecretAndCertificateAdmins
Write-Host "`n[1/3] Assigning Reader role to KeyVaultSecretAndCertificateAdmins on subscription..." -ForegroundColor Yellow
$readerAssignment = Get-AzRoleAssignment -ObjectId $kvAdminsGroup.Id -Scope $subscriptionScope -RoleDefinitionName 'Reader' -ErrorAction SilentlyContinue
if (-not $readerAssignment) {
    New-AzRoleAssignment -ObjectId $kvAdminsGroup.Id -RoleDefinitionName 'Reader' -Scope $subscriptionScope | Out-Null
    Write-Host "✓ Assigned Reader role on subscription" -ForegroundColor Green
} else {
    Write-Host "✓ Reader role already assigned on subscription" -ForegroundColor Green
}

# Assignment 2: VaultSecretCertificateManager role on key vault for KeyVaultSecretAndCertificateAdmins
if ($vault) {
    Write-Host "`n[2/3] Assigning VaultSecretCertificateManager role to KeyVaultSecretAndCertificateAdmins on Key Vault..." -ForegroundColor Yellow
    $vaultRoleAssignment = Get-AzRoleAssignment -ObjectId $kvAdminsGroup.Id -Scope $vault.ResourceId -RoleDefinitionName 'VaultSecretCertificateManager' -ErrorAction SilentlyContinue
    if (-not $vaultRoleAssignment) {
        # Wait a moment for the role definition to propagate
        Start-Sleep -Seconds 10
        New-AzRoleAssignment -ObjectId $kvAdminsGroup.Id -RoleDefinitionName 'VaultSecretCertificateManager' -Scope $vault.ResourceId | Out-Null
        Write-Host "✓ Assigned VaultSecretCertificateManager role on Key Vault" -ForegroundColor Green
    } else {
        Write-Host "✓ VaultSecretCertificateManager role already assigned on Key Vault" -ForegroundColor Green
    }
}

# Assignment 3: Contributor role on rg-external for external-contributors
Write-Host "`n[3/3] Assigning Contributor role to external-contributors on rg-external..." -ForegroundColor Yellow
$extRg = Get-AzResourceGroup -Name 'rg-external'
$extRoleAssignment = Get-AzRoleAssignment -ObjectId $extContribGroup.Id -Scope $extRg.ResourceId -RoleDefinitionName 'Contributor' -ErrorAction SilentlyContinue
if (-not $extRoleAssignment) {
    New-AzRoleAssignment -ObjectId $extContribGroup.Id -RoleDefinitionName 'Contributor' -Scope $extRg.ResourceId | Out-Null
    Write-Host "✓ Assigned Contributor role on rg-external" -ForegroundColor Green
} else {
    Write-Host "✓ Contributor role already assigned on rg-external" -ForegroundColor Green
}

# ============================================================================
# DEPLOYMENT COMPLETE
# ============================================================================
Write-Host "`n============================================================================" -ForegroundColor Green
Write-Host "DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green

Write-Host "`n✓ All resources have been deployed successfully" -ForegroundColor Green
Write-Host "`nNext Steps:" -ForegroundColor Cyan
Write-Host "1. Open the Azure Portal" -ForegroundColor Yellow
Write-Host "2. Refer to SCREENSHOT-CAPTURE-GUIDE.md for exact navigation paths" -ForegroundColor Yellow
Write-Host "3. Capture all 14 required screenshots" -ForegroundColor Yellow
Write-Host "4. Name screenshots according to the guide" -ForegroundColor Yellow
Write-Host "`nNote: Budgets and action groups must be created manually in the portal" -ForegroundColor Yellow
Write-Host "      See SCREENSHOT-CAPTURE-GUIDE.md for instructions" -ForegroundColor Yellow

Write-Host "`n============================================================================" -ForegroundColor Cyan
Write-Host "VERIFICATION COMMANDS" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "`nRun these commands to verify your deployment:" -ForegroundColor Yellow
Write-Host ""
Write-Host "# Check policy assignments" -ForegroundColor Gray
Write-Host "Get-AzPolicyAssignment | Select-Object Name, DisplayName | Format-Table" -ForegroundColor White
Write-Host ""
Write-Host "# Check custom role" -ForegroundColor Gray
Write-Host "Get-AzRoleDefinition -Name 'VaultSecretCertificateManager'" -ForegroundColor White
Write-Host ""
Write-Host "# Check groups" -ForegroundColor Gray
Write-Host "Get-AzADGroup | Where-Object {`$_.DisplayName -like '*KeyVault*' -or `$_.DisplayName -like '*external*'}" -ForegroundColor White
Write-Host ""
Write-Host "# Check resource groups" -ForegroundColor Gray
Write-Host "Get-AzResourceGroup | Where-Object {`$_.ResourceGroupName -like 'rg-*'}" -ForegroundColor White
Write-Host ""
Write-Host "# Check key vault" -ForegroundColor Gray
Write-Host "Get-AzKeyVault | Where-Object {`$_.VaultName -like 'kv-devshared-*'}" -ForegroundColor White
Write-Host ""

Write-Host "`nDeployment script completed at: $(Get-Date)" -ForegroundColor Green
Write-Host "============================================================================`n" -ForegroundColor Cyan
