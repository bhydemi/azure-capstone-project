#!/usr/bin/env pwsh
# Azure Capstone Project - Complete Deployment Script
# Run this script in Azure Cloud Shell (PowerShell mode)

Write-Host "=== Azure Capstone Project Deployment ===" -ForegroundColor Cyan
Write-Host ""

# Verify Azure connection
try {
    $context = Get-AzContext
    if (-not $context) {
        Write-Host "Not connected to Azure. Please run: Connect-AzAccount" -ForegroundColor Red
        exit 1
    }
    Write-Host "Connected to Azure as: $($context.Account.Id)" -ForegroundColor Green
    Write-Host "Subscription: $($context.Subscription.Name)" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "Error checking Azure connection: $_" -ForegroundColor Red
    exit 1
}

$subscriptionId = $context.Subscription.Id
$scope = "/subscriptions/$subscriptionId"

Write-Host "Using Subscription ID: $subscriptionId" -ForegroundColor Yellow
Write-Host "Deployment Scope: $scope" -ForegroundColor Yellow
Write-Host ""

# ============================================================================
# STEP 1: Deploy VM Size Restriction Policy
# ============================================================================
Write-Host "[1/8] Deploying VM Size Restriction Policy..." -ForegroundColor Cyan

try {
    $vmPolicy = Get-AzPolicyDefinition -Name 'restrict-vm-sizes' -ErrorAction SilentlyContinue
    if ($vmPolicy) {
        Write-Host "  Policy definition already exists, updating..." -ForegroundColor Yellow
        Set-AzPolicyDefinition `
            -Name 'restrict-vm-sizes' `
            -Policy 'policy-vm-size-restriction.json' `
            -Mode 'Indexed' | Out-Null
    } else {
        New-AzPolicyDefinition `
            -Name 'restrict-vm-sizes' `
            -DisplayName 'Restrict Virtual Machine SKU Sizes' `
            -Policy 'policy-vm-size-restriction.json' `
            -Mode 'Indexed' | Out-Null
    }
    Write-Host "  ✓ Policy definition created/updated" -ForegroundColor Green

    # Assign the policy
    $vmAssignment = Get-AzPolicyAssignment -Name 'vm-size-restriction' -Scope $scope -ErrorAction SilentlyContinue
    if (-not $vmAssignment) {
        New-AzPolicyAssignment `
            -Name 'vm-size-restriction' `
            -DisplayName 'Restrict Virtual Machine SKU Sizes' `
            -Scope $scope `
            -PolicyDefinition (Get-AzPolicyDefinition -Name 'restrict-vm-sizes') | Out-Null
        Write-Host "  ✓ Policy assigned to subscription" -ForegroundColor Green
    } else {
        Write-Host "  ✓ Policy already assigned" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ✗ Error: $_" -ForegroundColor Red
}

Write-Host ""

# ============================================================================
# STEP 2: Deploy Web Farm SKU Restriction Policy
# ============================================================================
Write-Host "[2/8] Deploying Web Farm SKU Restriction Policy..." -ForegroundColor Cyan

try {
    $webPolicy = Get-AzPolicyDefinition -Name 'restrict-web-farm-skus' -ErrorAction SilentlyContinue
    if ($webPolicy) {
        Write-Host "  Policy definition already exists, updating..." -ForegroundColor Yellow
        Set-AzPolicyDefinition `
            -Name 'restrict-web-farm-skus' `
            -Policy 'policy-web-farm-sku.json' `
            -Mode 'Indexed' | Out-Null
    } else {
        New-AzPolicyDefinition `
            -Name 'restrict-web-farm-skus' `
            -DisplayName 'Restrict App Service Plan SKU Sizes' `
            -Policy 'policy-web-farm-sku.json' `
            -Mode 'Indexed' | Out-Null
    }
    Write-Host "  ✓ Policy definition created/updated" -ForegroundColor Green

    # Assign the policy
    $webAssignment = Get-AzPolicyAssignment -Name 'web-farm-sku-restriction' -Scope $scope -ErrorAction SilentlyContinue
    if (-not $webAssignment) {
        New-AzPolicyAssignment `
            -Name 'web-farm-sku-restriction' `
            -DisplayName 'Restrict App Service Plan SKU Sizes' `
            -Scope $scope `
            -PolicyDefinition (Get-AzPolicyDefinition -Name 'restrict-web-farm-skus') | Out-Null
        Write-Host "  ✓ Policy assigned to subscription" -ForegroundColor Green
    } else {
        Write-Host "  ✓ Policy already assigned" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ✗ Error: $_" -ForegroundColor Red
}

Write-Host ""

# ============================================================================
# STEP 3: Deploy Unified Tagging Policy
# ============================================================================
Write-Host "[3/8] Deploying Unified Tagging Policy..." -ForegroundColor Cyan

try {
    $tagPolicy = Get-AzPolicyDefinition -Name 'require-tag-with-values' -ErrorAction SilentlyContinue
    if ($tagPolicy) {
        Write-Host "  Policy definition already exists, updating..." -ForegroundColor Yellow
        Set-AzPolicyDefinition `
            -Name 'require-tag-with-values' `
            -Policy 'policy-require-tag-with-values.json' `
            -Mode 'Indexed' | Out-Null
    } else {
        New-AzPolicyDefinition `
            -Name 'require-tag-with-values' `
            -DisplayName 'Require tag with allowed values on resources' `
            -Policy 'policy-require-tag-with-values.json' `
            -Mode 'Indexed' | Out-Null
    }
    Write-Host "  ✓ Policy definition created/updated" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Error: $_" -ForegroundColor Red
}

Write-Host ""

# ============================================================================
# STEP 4: Assign Department Tag Policy
# ============================================================================
Write-Host "[4/8] Assigning Department Tag Policy..." -ForegroundColor Cyan

try {
    $deptAssignment = Get-AzPolicyAssignment -Name 'require-department-tag' -Scope $scope -ErrorAction SilentlyContinue
    if (-not $deptAssignment) {
        $deptParams = @{
            'tagName' = 'Department'
            'allowedTagValues' = @('Finance', 'Engineering')
        }

        New-AzPolicyAssignment `
            -Name 'require-department-tag' `
            -DisplayName 'Require Department Tag' `
            -Scope $scope `
            -PolicyDefinition (Get-AzPolicyDefinition -Name 'require-tag-with-values') `
            -PolicyParameterObject $deptParams | Out-Null
        Write-Host "  ✓ Department tag policy assigned (Finance, Engineering)" -ForegroundColor Green
    } else {
        Write-Host "  ✓ Department tag policy already assigned" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ✗ Error: $_" -ForegroundColor Red
}

Write-Host ""

# ============================================================================
# STEP 5: Assign Environment Tag Policy
# ============================================================================
Write-Host "[5/8] Assigning Environment Tag Policy..." -ForegroundColor Cyan

try {
    $envAssignment = Get-AzPolicyAssignment -Name 'require-environment-tag' -Scope $scope -ErrorAction SilentlyContinue
    if (-not $envAssignment) {
        $envParams = @{
            'tagName' = 'Environment'
            'allowedTagValues' = @('Dev', 'Test', 'Prod')
        }

        New-AzPolicyAssignment `
            -Name 'require-environment-tag' `
            -DisplayName 'Require Environment Tag' `
            -Scope $scope `
            -PolicyDefinition (Get-AzPolicyDefinition -Name 'require-tag-with-values') `
            -PolicyParameterObject $envParams | Out-Null
        Write-Host "  ✓ Environment tag policy assigned (Dev, Test, Prod)" -ForegroundColor Green
    } else {
        Write-Host "  ✓ Environment tag policy already assigned" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ✗ Error: $_" -ForegroundColor Red
}

Write-Host ""

# ============================================================================
# STEP 6: Assign Built-in Allowed Locations Policy
# ============================================================================
Write-Host "[6/8] Assigning Built-in Allowed Locations Policy..." -ForegroundColor Cyan

try {
    $locationAssignment = Get-AzPolicyAssignment -Name 'allowed-locations' -Scope $scope -ErrorAction SilentlyContinue
    if (-not $locationAssignment) {
        $locationParams = @{
            'listOfAllowedLocations' = @('eastus2', 'centralus')
        }

        $locationPolicy = Get-AzPolicyDefinition | Where-Object { $_.Properties.DisplayName -eq 'Allowed locations' }

        if ($locationPolicy) {
            New-AzPolicyAssignment `
                -Name 'allowed-locations' `
                -DisplayName 'Restrict to East US 2 and Central US' `
                -Scope $scope `
                -PolicyDefinition $locationPolicy `
                -PolicyParameterObject $locationParams | Out-Null
            Write-Host "  ✓ Allowed locations policy assigned (East US 2, Central US)" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Built-in 'Allowed locations' policy not found" -ForegroundColor Red
        }
    } else {
        Write-Host "  ✓ Allowed locations policy already assigned" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ✗ Error: $_" -ForegroundColor Red
}

Write-Host ""

# ============================================================================
# STEP 7: Create Custom Role for Key Vault
# ============================================================================
Write-Host "[7/8] Creating VaultSecretCertificateManager Custom Role..." -ForegroundColor Cyan

try {
    & ./create-custom-role.ps1
    Write-Host "  ✓ Custom role processed" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Error: $_" -ForegroundColor Red
}

Write-Host ""

# ============================================================================
# STEP 8: Instructions for PCI DSS v4 Initiative
# ============================================================================
Write-Host "[8/8] PCI DSS v4 Initiative Assignment..." -ForegroundColor Cyan
Write-Host "  NOTE: This is best done via Azure Portal due to many parameters" -ForegroundColor Yellow
Write-Host ""
Write-Host "  To assign PCI DSS v4:" -ForegroundColor White
Write-Host "  1. Go to Azure Portal > Policy > Definitions" -ForegroundColor White
Write-Host "  2. Filter by Type: 'Initiative'" -ForegroundColor White
Write-Host "  3. Search for 'PCI DSS v4'" -ForegroundColor White
Write-Host "  4. Click 'Assign'" -ForegroundColor White
Write-Host "  5. Select your subscription as the scope" -ForegroundColor White
Write-Host "  6. Review and create" -ForegroundColor White
Write-Host ""
Write-Host "  OR run this command to assign programmatically:" -ForegroundColor White
Write-Host ""
Write-Host "  `$pcidss = Get-AzPolicySetDefinition | Where-Object { `$_.Properties.DisplayName -like '*PCI DSS v4*' }" -ForegroundColor Gray
Write-Host "  New-AzPolicyAssignment -Name 'pci-dss-v4' -DisplayName 'PCI DSS v4 Compliance' -Scope '$scope' -PolicySetDefinition `$pcidss" -ForegroundColor Gray
Write-Host ""

# ============================================================================
# Summary
# ============================================================================
Write-Host "=== Deployment Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Assign PCI DSS v4 initiative (see instructions above)" -ForegroundColor White
Write-Host "2. Create Azure AD groups and role assignments (if not done yet):" -ForegroundColor White
Write-Host "   - KeyvaultSecretAndCertificateAdmins group" -ForegroundColor White
Write-Host "   - external-contributors group" -ForegroundColor White
Write-Host "3. Set up budget alerts (Azure Portal > Cost Management)" -ForegroundColor White
Write-Host "4. Capture all 14 required screenshots (see SCREENSHOTS-REQUIRED.md)" -ForegroundColor White
Write-Host ""
Write-Host "To verify deployments, run:" -ForegroundColor Yellow
Write-Host "Get-AzPolicyAssignment | Select-Object Name, DisplayName" -ForegroundColor Gray
Write-Host "Get-AzRoleDefinition -Name 'VaultSecretCertificateManager'" -ForegroundColor Gray
Write-Host ""
