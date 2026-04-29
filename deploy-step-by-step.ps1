#!/usr/bin/env pwsh
# Step-by-Step Deployment with Full Error Visibility

Write-Host "=== Azure Capstone Project - Step by Step Deployment ===" -ForegroundColor Cyan
Write-Host ""

# Get subscription info
$context = Get-AzContext
$subscriptionId = $context.Subscription.Id
$scope = "/subscriptions/$subscriptionId"

Write-Host "Subscription: $($context.Subscription.Name)" -ForegroundColor Green
Write-Host "Subscription ID: $subscriptionId" -ForegroundColor Green
Write-Host ""

# Verify files exist
Write-Host "Checking for required files..." -ForegroundColor Yellow
if (-not (Test-Path 'policy-vm-size-restriction.json')) {
    Write-Host "ERROR: policy-vm-size-restriction.json not found!" -ForegroundColor Red
    Write-Host "Current directory: $(Get-Location)" -ForegroundColor Yellow
    Write-Host "Make sure all JSON files are uploaded to this directory." -ForegroundColor Yellow
    exit 1
}
Write-Host "All files found!" -ForegroundColor Green
Write-Host ""

# ============================================================================
# STEP 1: VM Size Policy
# ============================================================================
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "STEP 1: Creating VM Size Restriction Policy" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

try {
    Write-Host "Creating policy definition 'restrict-vm-sizes'..." -ForegroundColor Yellow

    $vmPolicyDef = New-AzPolicyDefinition `
        -Name 'restrict-vm-sizes' `
        -DisplayName 'Restrict Virtual Machine SKU Sizes' `
        -Policy 'policy-vm-size-restriction.json' `
        -Mode 'Indexed'

    Write-Host "✓ Policy definition created: $($vmPolicyDef.Name)" -ForegroundColor Green
    Write-Host "  ID: $($vmPolicyDef.PolicyDefinitionId)" -ForegroundColor Gray
    Write-Host ""

    Write-Host "Assigning policy to subscription..." -ForegroundColor Yellow

    $vmAssignment = New-AzPolicyAssignment `
        -Name 'vm-size-restriction' `
        -DisplayName 'Restrict Virtual Machine SKU Sizes' `
        -Scope $scope `
        -PolicyDefinition $vmPolicyDef

    Write-Host "✓ Policy assigned: $($vmAssignment.Name)" -ForegroundColor Green
    Write-Host "  Assignment ID: $($vmAssignment.PolicyAssignmentId)" -ForegroundColor Gray
    Write-Host ""

} catch {
    Write-Host "✗ ERROR: $_" -ForegroundColor Red
    Write-Host "Detailed error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""

    # Check if policy already exists
    $existing = Get-AzPolicyDefinition -Name 'restrict-vm-sizes' -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "Policy definition already exists. Trying assignment only..." -ForegroundColor Yellow
        try {
            $vmAssignment = New-AzPolicyAssignment `
                -Name 'vm-size-restriction' `
                -DisplayName 'Restrict Virtual Machine SKU Sizes' `
                -Scope $scope `
                -PolicyDefinition $existing
            Write-Host "✓ Policy assigned successfully" -ForegroundColor Green
        } catch {
            Write-Host "Assignment also failed: $_" -ForegroundColor Red
        }
    }
}

Write-Host ""
Read-Host "Press Enter to continue to Step 2"

# ============================================================================
# STEP 2: Web Farm SKU Policy
# ============================================================================
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "STEP 2: Creating Web Farm SKU Restriction Policy" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

try {
    Write-Host "Creating policy definition 'restrict-web-farm-skus'..." -ForegroundColor Yellow

    $webPolicyDef = New-AzPolicyDefinition `
        -Name 'restrict-web-farm-skus' `
        -DisplayName 'Restrict App Service Plan SKU Sizes' `
        -Policy 'policy-web-farm-sku.json' `
        -Mode 'Indexed'

    Write-Host "✓ Policy definition created: $($webPolicyDef.Name)" -ForegroundColor Green
    Write-Host ""

    Write-Host "Assigning policy to subscription..." -ForegroundColor Yellow

    $webAssignment = New-AzPolicyAssignment `
        -Name 'web-farm-sku-restriction' `
        -DisplayName 'Restrict App Service Plan SKU Sizes' `
        -Scope $scope `
        -PolicyDefinition $webPolicyDef

    Write-Host "✓ Policy assigned: $($webAssignment.Name)" -ForegroundColor Green
    Write-Host ""

} catch {
    Write-Host "✗ ERROR: $_" -ForegroundColor Red

    $existing = Get-AzPolicyDefinition -Name 'restrict-web-farm-skus' -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "Policy definition already exists. Trying assignment only..." -ForegroundColor Yellow
        try {
            $webAssignment = New-AzPolicyAssignment `
                -Name 'web-farm-sku-restriction' `
                -DisplayName 'Restrict App Service Plan SKU Sizes' `
                -Scope $scope `
                -PolicyDefinition $existing
            Write-Host "✓ Policy assigned successfully" -ForegroundColor Green
        } catch {
            Write-Host "Assignment also failed: $_" -ForegroundColor Red
        }
    }
}

Write-Host ""
Read-Host "Press Enter to continue to Step 3"

# ============================================================================
# STEP 3: Tagging Policy
# ============================================================================
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "STEP 3: Creating Unified Tagging Policy" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

try {
    Write-Host "Creating policy definition 'require-tag-with-values'..." -ForegroundColor Yellow

    $tagPolicyDef = New-AzPolicyDefinition `
        -Name 'require-tag-with-values' `
        -DisplayName 'Require tag with allowed values on resources' `
        -Policy 'policy-require-tag-with-values.json' `
        -Mode 'Indexed'

    Write-Host "✓ Policy definition created: $($tagPolicyDef.Name)" -ForegroundColor Green
    Write-Host ""

} catch {
    Write-Host "✗ ERROR: $_" -ForegroundColor Red

    $tagPolicyDef = Get-AzPolicyDefinition -Name 'require-tag-with-values' -ErrorAction SilentlyContinue
    if ($tagPolicyDef) {
        Write-Host "Policy definition already exists, will use existing one." -ForegroundColor Yellow
    }
}

# Assignment 1: Department Tag
Write-Host "Assigning policy for Department tag..." -ForegroundColor Yellow

try {
    $deptParams = @{
        'tagName' = 'Department'
        'allowedTagValues' = @('Finance', 'Engineering')
    }

    $deptAssignment = New-AzPolicyAssignment `
        -Name 'require-department-tag' `
        -DisplayName 'Require Department Tag' `
        -Scope $scope `
        -PolicyDefinition $tagPolicyDef `
        -PolicyParameterObject $deptParams

    Write-Host "✓ Department tag policy assigned" -ForegroundColor Green
    Write-Host "  Tag: Department" -ForegroundColor Gray
    Write-Host "  Allowed values: Finance, Engineering" -ForegroundColor Gray
    Write-Host ""

} catch {
    Write-Host "✗ ERROR: $_" -ForegroundColor Red
}

# Assignment 2: Environment Tag
Write-Host "Assigning policy for Environment tag..." -ForegroundColor Yellow

try {
    $envParams = @{
        'tagName' = 'Environment'
        'allowedTagValues' = @('Dev', 'Test', 'Prod')
    }

    $envAssignment = New-AzPolicyAssignment `
        -Name 'require-environment-tag' `
        -DisplayName 'Require Environment Tag' `
        -Scope $scope `
        -PolicyDefinition $tagPolicyDef `
        -PolicyParameterObject $envParams

    Write-Host "✓ Environment tag policy assigned" -ForegroundColor Green
    Write-Host "  Tag: Environment" -ForegroundColor Gray
    Write-Host "  Allowed values: Dev, Test, Prod" -ForegroundColor Gray
    Write-Host ""

} catch {
    Write-Host "✗ ERROR: $_" -ForegroundColor Red
}

Write-Host ""
Read-Host "Press Enter to continue to Step 4"

# ============================================================================
# STEP 4: Location Policy
# ============================================================================
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "STEP 4: Assigning Built-in Location Policy" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

try {
    Write-Host "Finding built-in 'Allowed locations' policy..." -ForegroundColor Yellow

    $locationPolicy = Get-AzPolicyDefinition | Where-Object { $_.Properties.DisplayName -eq 'Allowed locations' }

    if ($locationPolicy) {
        Write-Host "✓ Found built-in policy" -ForegroundColor Green
        Write-Host ""

        Write-Host "Assigning policy with locations: East US 2, Central US..." -ForegroundColor Yellow

        $locationParams = @{
            'listOfAllowedLocations' = @('eastus2', 'centralus')
        }

        $locationAssignment = New-AzPolicyAssignment `
            -Name 'allowed-locations' `
            -DisplayName 'Restrict to East US 2 and Central US' `
            -Scope $scope `
            -PolicyDefinition $locationPolicy `
            -PolicyParameterObject $locationParams

        Write-Host "✓ Location policy assigned" -ForegroundColor Green
        Write-Host "  Allowed locations: East US 2, Central US" -ForegroundColor Gray
        Write-Host ""
    } else {
        Write-Host "✗ Built-in 'Allowed locations' policy not found" -ForegroundColor Red
    }

} catch {
    Write-Host "✗ ERROR: $_" -ForegroundColor Red
}

Write-Host ""
Read-Host "Press Enter to continue to Step 5"

# ============================================================================
# STEP 5: Custom Role
# ============================================================================
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "STEP 5: Creating Custom Role" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

if (Test-Path './create-custom-role.ps1') {
    Write-Host "Running create-custom-role.ps1..." -ForegroundColor Yellow
    & ./create-custom-role.ps1
} else {
    Write-Host "✗ create-custom-role.ps1 not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "Deployment Summary" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""

# Show all policy assignments
Write-Host "Policy Assignments:" -ForegroundColor Cyan
Get-AzPolicyAssignment -Scope $scope | Select-Object Name, DisplayName | Format-Table

# Show custom policies
Write-Host "Custom Policy Definitions:" -ForegroundColor Cyan
Get-AzPolicyDefinition -Custom | Select-Object Name, DisplayName | Format-Table

# Show custom role
Write-Host "Custom Roles:" -ForegroundColor Cyan
Get-AzRoleDefinition -Custom | Where-Object { $_.Name -eq 'VaultSecretCertificateManager' } | Select-Object Name, Description | Format-Table

Write-Host ""
Write-Host "Next: Assign PCI DSS v4 initiative via Azure Portal" -ForegroundColor Yellow
Write-Host ""
