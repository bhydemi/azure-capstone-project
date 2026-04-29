# ============================================================================
# FINAL DEPLOYMENT SCRIPT - Simplified and Robust
# ============================================================================

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "  AZURE CAPSTONE PROJECT - FINAL DEPLOYMENT" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Continue"

# Get context
$context = Get-AzContext
$subscriptionId = $context.Subscription.Id
$subscriptionScope = "/subscriptions/$subscriptionId"

Write-Host "Subscription: $($context.Subscription.Name)" -ForegroundColor Green
Write-Host "Account: $($context.Account.Id)" -ForegroundColor Green
Write-Host ""

# ============================================================================
# STEP 1: CREATE CUSTOM ROLE VIA JSON FILE
# ============================================================================
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "STEP 1: Creating Custom Role" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

$roleJson = @"
{
  "Name": "VaultSecretCertificateManager",
  "IsCustom": true,
  "Description": "Allows users to manage Key Vault secrets and certificates",
  "Actions": [
    "Microsoft.KeyVault/vaults/read"
  ],
  "NotActions": [],
  "DataActions": [
    "Microsoft.KeyVault/vaults/secrets/getSecret/action",
    "Microsoft.KeyVault/vaults/secrets/setSecret/action",
    "Microsoft.KeyVault/vaults/secrets/delete",
    "Microsoft.KeyVault/vaults/secrets/readMetadata/action",
    "Microsoft.KeyVault/vaults/certificates/read",
    "Microsoft.KeyVault/vaults/certificates/write",
    "Microsoft.KeyVault/vaults/certificates/delete"
  ],
  "NotDataActions": [],
  "AssignableScopes": [
    "$subscriptionScope"
  ]
}
"@

# Save role definition to file
$roleJson | Out-File -FilePath ./custom-role-definition.json -Force -Encoding UTF8

Write-Host "Checking if custom role exists..." -ForegroundColor Yellow
$existingRole = Get-AzRoleDefinition | Where-Object {$_.Name -eq 'VaultSecretCertificateManager'}

if ($existingRole) {
    Write-Host "✓ Custom role already exists" -ForegroundColor Green
} else {
    Write-Host "Creating custom role from JSON..." -ForegroundColor Yellow
    try {
        New-AzRoleDefinition -InputFile ./custom-role-definition.json -ErrorAction Stop | Out-Null
        Write-Host "✓ Custom role created successfully" -ForegroundColor Green
    } catch {
        Write-Host "⚠ Could not create custom role: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "  Will use built-in 'Key Vault Secrets Officer' as fallback" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Waiting 15 seconds for role to propagate..." -ForegroundColor Gray
Start-Sleep -Seconds 15

# ============================================================================
# STEP 2: CREATE KEY VAULT
# ============================================================================
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "STEP 2: Creating Key Vault" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

# Generate unique vault name
$dateStamp = Get-Date -Format 'yyyyMMdd'
$vaultName = "kv-devshared-$dateStamp-ho"  # CHANGE 'ho' TO YOUR INITIALS

Write-Host "Vault name will be: $vaultName" -ForegroundColor Yellow
Write-Host "Checking if vault exists..." -ForegroundColor Yellow

$existingVault = Get-AzKeyVault -ResourceGroupName 'rg-shared-vault' -ErrorAction SilentlyContinue

if ($existingVault) {
    Write-Host "✓ Key Vault already exists: $($existingVault.VaultName)" -ForegroundColor Green
    $vaultName = $existingVault.VaultName
} else {
    Write-Host "Creating Key Vault..." -ForegroundColor Yellow
    try {
        # Create vault (basic parameters only)
        New-AzKeyVault `
            -VaultName $vaultName `
            -ResourceGroupName 'rg-shared-vault' `
            -Location 'eastus2' `
            -Tag @{Department='Engineering'; Environment='Dev'} `
            -ErrorAction Stop | Out-Null

        Write-Host "✓ Key Vault created: $vaultName" -ForegroundColor Green

        # Try to enable RBAC (may not work in all Az module versions)
        Write-Host "Attempting to enable RBAC mode..." -ForegroundColor Yellow
        try {
            Update-AzKeyVault -ResourceGroupName 'rg-shared-vault' -VaultName $vaultName -EnableRbacAuthorization $true -ErrorAction Stop | Out-Null
            Write-Host "✓ RBAC mode enabled" -ForegroundColor Green
        } catch {
            Write-Host "⚠ Could not enable RBAC mode (may not be supported in this environment)" -ForegroundColor Yellow
        }

    } catch {
        Write-Host "⚠ Error creating vault: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# ============================================================================
# STEP 3: ASSIGN COMPLIANCE INITIATIVE
# ============================================================================
Write-Host ""
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "STEP 3: Assigning Compliance Initiative" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Searching for NIST SP 800-53 initiative..." -ForegroundColor Yellow

# Get all built-in initiatives
$allInitiatives = Get-AzPolicySetDefinition -Builtin

# Try to find NIST
$initiative = $allInitiatives | Where-Object {
    $_.DisplayName -like "*NIST SP 800-53*" -and
    $_.DisplayName -like "*Rev. 5*"
} | Select-Object -First 1

if (-not $initiative) {
    # Try without version
    $initiative = $allInitiatives | Where-Object {
        $_.DisplayName -like "*NIST SP 800-53*"
    } | Select-Object -First 1
}

if (-not $initiative) {
    # Try CIS as fallback
    Write-Host "NIST not found, trying CIS Azure Benchmark..." -ForegroundColor Yellow
    $initiative = $allInitiatives | Where-Object {
        $_.DisplayName -like "*CIS Microsoft Azure*"
    } | Select-Object -First 1
}

if ($initiative) {
    Write-Host "Found initiative: $($initiative.DisplayName)" -ForegroundColor Green

    # Check if already assigned
    $existingAssignment = Get-AzPolicyAssignment -Scope $subscriptionScope | Where-Object {
        $_.Properties.PolicyDefinitionId -eq $initiative.PolicySetDefinitionId
    }

    if ($existingAssignment) {
        Write-Host "✓ Initiative already assigned: $($existingAssignment.Properties.DisplayName)" -ForegroundColor Green
    } else {
        Write-Host "Assigning initiative to subscription..." -ForegroundColor Yellow
        try {
            $assignmentName = if ($initiative.DisplayName -like "*NIST*") { "nist-compliance" } else { "cis-compliance" }

            New-AzPolicyAssignment `
                -Name $assignmentName `
                -DisplayName "Compliance - $($initiative.DisplayName)" `
                -Scope $subscriptionScope `
                -PolicySetDefinition $initiative `
                -ErrorAction Stop | Out-Null

            Write-Host "✓ Initiative assigned successfully" -ForegroundColor Green
        } catch {
            Write-Host "⚠ Error assigning initiative: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "⚠ No suitable compliance initiative found" -ForegroundColor Yellow
    Write-Host "  You'll need to manually assign one in the portal" -ForegroundColor Yellow
}

# ============================================================================
# STEP 4: ASSIGN ROLES TO GROUPS
# ============================================================================
Write-Host ""
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "STEP 4: Assigning Roles to Groups" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

# Get groups (select first if duplicates exist)
Write-Host "Getting security groups..." -ForegroundColor Yellow
$kvGroup = Get-AzADGroup -DisplayName 'KeyVaultSecretAndCertificateAdmins' -ErrorAction SilentlyContinue | Select-Object -First 1
$extGroup = Get-AzADGroup -DisplayName 'external-contributors' -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $kvGroup) {
    Write-Host "⚠ KeyVaultSecretAndCertificateAdmins group not found" -ForegroundColor Yellow
} else {
    Write-Host "✓ Found KeyVaultSecretAndCertificateAdmins group" -ForegroundColor Green
}

if (-not $extGroup) {
    Write-Host "⚠ external-contributors group not found" -ForegroundColor Yellow
} else {
    Write-Host "✓ Found external-contributors group" -ForegroundColor Green
}

Write-Host ""

# Assignment 1: Reader on Subscription
if ($kvGroup) {
    Write-Host "[1/3] Assigning Reader role to KeyVault group on subscription..." -ForegroundColor Yellow

    $existing = Get-AzRoleAssignment `
        -ObjectId $kvGroup.Id `
        -Scope $subscriptionScope `
        -RoleDefinitionName 'Reader' `
        -ErrorAction SilentlyContinue

    if ($existing) {
        Write-Host "      ✓ Already assigned" -ForegroundColor Green
    } else {
        try {
            New-AzRoleAssignment `
                -ObjectId $kvGroup.Id `
                -RoleDefinitionName 'Reader' `
                -Scope $subscriptionScope `
                -ErrorAction Stop | Out-Null
            Write-Host "      ✓ Assigned" -ForegroundColor Green
        } catch {
            Write-Host "      ⚠ Error: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
}

# Assignment 2: Vault role on Key Vault
if ($kvGroup -and $vaultName) {
    Write-Host "[2/3] Assigning vault role to KeyVault group on vault..." -ForegroundColor Yellow

    $vault = Get-AzKeyVault -ResourceGroupName 'rg-shared-vault' -VaultName $vaultName -ErrorAction SilentlyContinue

    if ($vault) {
        # Check if custom role exists
        $customRole = Get-AzRoleDefinition -Name 'VaultSecretCertificateManager' -ErrorAction SilentlyContinue

        if ($customRole) {
            $roleName = 'VaultSecretCertificateManager'
        } else {
            Write-Host "      Custom role not available, using 'Key Vault Secrets Officer'" -ForegroundColor Yellow
            $roleName = 'Key Vault Secrets Officer'
        }

        $existing = Get-AzRoleAssignment `
            -ObjectId $kvGroup.Id `
            -Scope $vault.ResourceId `
            -RoleDefinitionName $roleName `
            -ErrorAction SilentlyContinue

        if ($existing) {
            Write-Host "      ✓ Already assigned" -ForegroundColor Green
        } else {
            try {
                New-AzRoleAssignment `
                    -ObjectId $kvGroup.Id `
                    -RoleDefinitionName $roleName `
                    -Scope $vault.ResourceId `
                    -ErrorAction Stop | Out-Null
                Write-Host "      ✓ Assigned ($roleName)" -ForegroundColor Green
            } catch {
                Write-Host "      ⚠ Error: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "      ⚠ Key Vault not found" -ForegroundColor Yellow
    }
}

# Assignment 3: Contributor on rg-external
if ($extGroup) {
    Write-Host "[3/3] Assigning Contributor role to external-contributors on rg-external..." -ForegroundColor Yellow

    $extRg = Get-AzResourceGroup -Name 'rg-external' -ErrorAction SilentlyContinue

    if ($extRg) {
        $existing = Get-AzRoleAssignment `
            -ObjectId $extGroup.Id `
            -Scope $extRg.ResourceId `
            -RoleDefinitionName 'Contributor' `
            -ErrorAction SilentlyContinue

        if ($existing) {
            Write-Host "      ✓ Already assigned" -ForegroundColor Green
        } else {
            try {
                New-AzRoleAssignment `
                    -ObjectId $extGroup.Id `
                    -RoleDefinitionName 'Contributor' `
                    -Scope $extRg.ResourceId `
                    -ErrorAction Stop | Out-Null
                Write-Host "      ✓ Assigned" -ForegroundColor Green
            } catch {
                Write-Host "      ⚠ Error: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "      ⚠ Resource group 'rg-external' not found" -ForegroundColor Yellow
    }
}

# ============================================================================
# FINAL SUMMARY
# ============================================================================
Write-Host ""
Write-Host "============================================================================" -ForegroundColor Green
Write-Host "  DEPLOYMENT SUMMARY" -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green
Write-Host ""

# Policies
Write-Host "POLICIES:" -ForegroundColor Cyan
$policyCount = (Get-AzPolicyAssignment | Where-Object {
    $_.Name -notlike '*SecurityCenter*' -and $_.Name -notlike '*default*'
}).Count
Write-Host "  Custom policy assignments: $policyCount" -ForegroundColor White

# Custom Role
Write-Host ""
Write-Host "CUSTOM ROLE:" -ForegroundColor Cyan
$customRoleExists = Get-AzRoleDefinition -Name 'VaultSecretCertificateManager' -ErrorAction SilentlyContinue
if ($customRoleExists) {
    Write-Host "  ✓ VaultSecretCertificateManager created" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Custom role not created (using built-in fallback)" -ForegroundColor Yellow
}

# Key Vault
Write-Host ""
Write-Host "KEY VAULT:" -ForegroundColor Cyan
if ($vaultName) {
    Write-Host "  ✓ $vaultName" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Not created" -ForegroundColor Yellow
}

# Compliance
Write-Host ""
Write-Host "COMPLIANCE INITIATIVE:" -ForegroundColor Cyan
$complianceAssignment = Get-AzPolicyAssignment | Where-Object {
    $_.Name -like '*compliance*' -and $_.Name -notlike '*SecurityCenter*'
}
if ($complianceAssignment) {
    Write-Host "  ✓ $($complianceAssignment.Properties.DisplayName)" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Not assigned" -ForegroundColor Yellow
}

# Groups
Write-Host ""
Write-Host "SECURITY GROUPS:" -ForegroundColor Cyan
if ($kvGroup) {
    Write-Host "  ✓ KeyVaultSecretAndCertificateAdmins" -ForegroundColor Green
}
if ($extGroup) {
    Write-Host "  ✓ external-contributors" -ForegroundColor Green
}

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "  NEXT STEPS" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. CREATE BUDGET & ACTION GROUP (in Azure Portal):" -ForegroundColor Yellow
Write-Host "   - Action group: 'financeteam' with email financeteam@example.com" -ForegroundColor White
Write-Host "   - Budget: 'targetspend' for `$250/month with 80% and 100% alerts" -ForegroundColor White
Write-Host ""
Write-Host "2. CAPTURE SCREENSHOTS (14 total):" -ForegroundColor Yellow
Write-Host "   - Follow SCREENSHOT-CAPTURE-GUIDE.md for exact navigation" -ForegroundColor White
Write-Host ""
Write-Host "3. SUBMIT PROJECT:" -ForegroundColor Yellow
Write-Host "   - 3 policy JSON files" -ForegroundColor White
Write-Host "   - 3 PowerShell scripts" -ForegroundColor White
Write-Host "   - 14 screenshots" -ForegroundColor White
Write-Host "   - Documentation files" -ForegroundColor White
Write-Host ""
Write-Host "============================================================================" -ForegroundColor Green
Write-Host ""

# Save key information
Write-Host "KEY INFORMATION FOR SCREENSHOTS:" -ForegroundColor Cyan
Write-Host "Key Vault Name: $vaultName" -ForegroundColor White
Write-Host ""
