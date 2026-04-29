#!/usr/bin/env pwsh
# Troubleshooting Script for Azure Policy Deployment

Write-Host "=== Azure Policy Deployment Troubleshooter ===" -ForegroundColor Cyan
Write-Host ""

# Check 1: Verify we're in the right directory and files exist
Write-Host "[Check 1] Verifying JSON policy files exist..." -ForegroundColor Yellow
$requiredFiles = @(
    'policy-vm-size-restriction.json',
    'policy-web-farm-sku.json',
    'policy-require-tag-with-values.json',
    'create-custom-role.ps1'
)

$allFilesExist = $true
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "  ✓ Found: $file" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Missing: $file" -ForegroundColor Red
        $allFilesExist = $false
    }
}

if (-not $allFilesExist) {
    Write-Host ""
    Write-Host "ERROR: Some required files are missing!" -ForegroundColor Red
    Write-Host "Current directory: $(Get-Location)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Files in current directory:" -ForegroundColor Yellow
    Get-ChildItem | Select-Object Name, Length
    Write-Host ""
    Write-Host "Please ensure all files are uploaded to the current directory." -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "All required files found!" -ForegroundColor Green
Write-Host ""

# Check 2: Verify Azure connection
Write-Host "[Check 2] Verifying Azure connection..." -ForegroundColor Yellow
try {
    $context = Get-AzContext
    Write-Host "  ✓ Connected as: $($context.Account.Id)" -ForegroundColor Green
    Write-Host "  ✓ Subscription: $($context.Subscription.Name) ($($context.Subscription.Id))" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Not connected to Azure" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Check 3: Test creating a single policy manually to see detailed errors
Write-Host "[Check 3] Testing VM Size Policy creation with verbose output..." -ForegroundColor Yellow
Write-Host ""

try {
    $subscriptionId = $context.Subscription.Id

    # Try to create the policy definition
    Write-Host "Attempting to create policy definition..." -ForegroundColor Cyan
    $result = New-AzPolicyDefinition `
        -Name 'restrict-vm-sizes' `
        -DisplayName 'Restrict Virtual Machine SKU Sizes' `
        -Policy 'policy-vm-size-restriction.json' `
        -Mode 'Indexed' `
        -Verbose

    if ($result) {
        Write-Host "  ✓ Policy definition created successfully!" -ForegroundColor Green
        Write-Host "    Policy ID: $($result.PolicyDefinitionId)" -ForegroundColor Gray

        # Now try to assign it
        Write-Host ""
        Write-Host "Attempting to assign policy..." -ForegroundColor Cyan
        $assignment = New-AzPolicyAssignment `
            -Name 'vm-size-restriction' `
            -DisplayName 'Restrict Virtual Machine SKU Sizes' `
            -Scope "/subscriptions/$subscriptionId" `
            -PolicyDefinition $result `
            -Verbose

        if ($assignment) {
            Write-Host "  ✓ Policy assigned successfully!" -ForegroundColor Green
            Write-Host ""
            Write-Host "SUCCESS! The deployment should work now." -ForegroundColor Green
            Write-Host "You can run: ./deploy-all-policies.ps1" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "  ✗ Error occurred:" -ForegroundColor Red
    Write-Host "    $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Detailed Error Information:" -ForegroundColor Yellow
    Write-Host $_ -ForegroundColor Red
    Write-Host ""
    Write-Host "This may indicate:" -ForegroundColor Yellow
    Write-Host "  - JSON file format issue" -ForegroundColor White
    Write-Host "  - Insufficient permissions" -ForegroundColor White
    Write-Host "  - Policy already exists with same name" -ForegroundColor White
}

Write-Host ""
Write-Host "=== Troubleshooting Complete ===" -ForegroundColor Cyan
