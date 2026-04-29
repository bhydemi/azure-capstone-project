# Script to find and assign PCI DSS Initiative

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "Finding PCI DSS Initiative" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

# Get current subscription
$subscription = Get-AzSubscription
Write-Host "Current Subscription: $($subscription.Name)" -ForegroundColor Green
Write-Host ""

# Search for PCI initiatives with different variations
Write-Host "Searching for PCI initiatives..." -ForegroundColor Yellow
Write-Host ""

# Try different search patterns
$searchPatterns = @(
    "*PCI*DSS*4*",
    "*PCI*DSS*v4*",
    "*PCI*4.0*",
    "*PCI*",
    "*Payment*Card*"
)

$foundInitiatives = @()

foreach ($pattern in $searchPatterns) {
    Write-Host "Searching for pattern: $pattern" -ForegroundColor Gray
    $results = Get-AzPolicySetDefinition | Where-Object {$_.Properties.DisplayName -like $pattern}
    if ($results) {
        $foundInitiatives += $results
    }
}

# Remove duplicates
$foundInitiatives = $foundInitiatives | Sort-Object -Property PolicySetDefinitionId -Unique

if ($foundInitiatives.Count -eq 0) {
    Write-Host "⚠ No PCI DSS initiatives found." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Let's list ALL available compliance initiatives:" -ForegroundColor Cyan
    Write-Host ""

    # Get all policy set definitions and filter for compliance-related ones
    $allInitiatives = Get-AzPolicySetDefinition | Where-Object {
        $_.Properties.DisplayName -like "*compliance*" -or
        $_.Properties.DisplayName -like "*security*" -or
        $_.Properties.DisplayName -like "*DSS*" -or
        $_.Properties.DisplayName -like "*ISO*" -or
        $_.Properties.DisplayName -like "*NIST*"
    } | Select-Object -First 20

    $allInitiatives | Format-Table -Property @{
        Label="Display Name"
        Expression={$_.Properties.DisplayName}
        Width=60
    }, @{
        Label="Policy Type"
        Expression={$_.Properties.PolicyType}
        Width=10
    } -AutoSize

    Write-Host ""
    Write-Host "To assign a specific initiative, use:" -ForegroundColor Cyan
    Write-Host 'Get-AzPolicySetDefinition | Where-Object {$_.Properties.DisplayName -eq "Full Name Here"}' -ForegroundColor White

} else {
    Write-Host "✓ Found $($foundInitiatives.Count) PCI-related initiative(s):" -ForegroundColor Green
    Write-Host ""

    $foundInitiatives | Format-Table -Property @{
        Label="Display Name"
        Expression={$_.Properties.DisplayName}
        Width=70
    }, @{
        Label="Policy Type"
        Expression={$_.Properties.PolicyType}
        Width=10
    } -AutoSize

    Write-Host ""
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host "Assigning PCI DSS Initiative" -ForegroundColor Cyan
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host ""

    # Use the first found initiative (or you can select a specific one)
    $initiative = $foundInitiatives[0]

    Write-Host "Using initiative: $($initiative.Properties.DisplayName)" -ForegroundColor Yellow
    Write-Host ""

    # Check if already assigned
    $existingAssignment = Get-AzPolicyAssignment -Scope "/subscriptions/$($subscription.Id)" |
        Where-Object {$_.Properties.PolicyDefinitionId -eq $initiative.PolicySetDefinitionId}

    if ($existingAssignment) {
        Write-Host "✓ Initiative already assigned!" -ForegroundColor Green
        Write-Host "Assignment Name: $($existingAssignment.Name)" -ForegroundColor Gray
        Write-Host "Display Name: $($existingAssignment.Properties.DisplayName)" -ForegroundColor Gray
    } else {
        Write-Host "Assigning initiative to subscription..." -ForegroundColor Yellow

        try {
            $assignment = New-AzPolicyAssignment `
                -Name 'pci-dss-compliance' `
                -DisplayName "PCI DSS Compliance - $($initiative.Properties.DisplayName)" `
                -Scope "/subscriptions/$($subscription.Id)" `
                -PolicySetDefinition $initiative `
                -ErrorAction Stop

            Write-Host "✓ Successfully assigned initiative!" -ForegroundColor Green
            Write-Host "Assignment Name: $($assignment.Name)" -ForegroundColor Gray
            Write-Host ""
        } catch {
            Write-Host "✗ Error assigning initiative: $_" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "Complete!" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. In Azure Portal, go to: Policy → Assignments" -ForegroundColor White
Write-Host "2. Find your PCI compliance initiative assignment" -ForegroundColor White
Write-Host "3. Take Screenshot 6 showing the assignment" -ForegroundColor White
Write-Host ""
