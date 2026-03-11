# Challenge 12: Azure Environment Audit Script
# This script performs a read-only audit of an Azure environment

param(
    [switch]$Verbose
)

# Script Header and Metadata
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "           AZURE ENVIRONMENT DISCOVERY AND AUDIT SCRIPT" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Script Started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Yellow
Write-Host ""

# Initialize collections
$accessibleSubscriptions = @()
$allResourceGroups = @()
$allResources = @()

# Get Current Context and Accessible Subscriptions
Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "SECTION 1: CURRENT CONTEXT AND SUBSCRIPTIONS" -ForegroundColor Green
Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host ""

try {
    $currentContext = Get-AzContext -ErrorAction Stop
    $currentSubName = $currentContext.Subscription.Name
    $currentSubId = $currentContext.Subscription.Id
    $signedInAccount = $currentContext.Account
    
    Write-Host "Current Subscription Name: $currentSubName" -ForegroundColor White
    Write-Host "Signed-in Account: $($signedInAccount.Id)" -ForegroundColor White
    
    # Attempt to get all accessible subscriptions
    try {
        $subscriptions = Get-AzSubscription -ErrorAction Stop | Where-Object { $_.State -eq 'Enabled' }
        
        if ($subscriptions) {
            Write-Host ""
            Write-Host "Accessible Subscriptions:" -ForegroundColor Yellow
            
            $accessibleSubscriptions = @()
            foreach ($sub in $subscriptions) {
                $accessibleSubscriptions += [PSCustomObject]@{
                    SubscriptionName = $sub.Name
                    SubscriptionId = $sub.Id
                    SubscriptionState = $sub.State
                }
                Write-Host "  - Name: $($sub.Name) | ID: $($sub.Id) | State: $($sub.State)"
            }
        } else {
            Write-Host ""
            Write-Host "WARNING: No additional subscriptions accessible beyond current context." -ForegroundColor Yellow
        }
    } catch {
        Write-Host ""
        Write-Host "WARNING: Limited permissions - could not enumerate all subscriptions." -ForegroundColor Yellow
        Write-Host "Using only the current subscription: $currentSubName" -ForegroundColor Yellow
        $accessibleSubscriptions += [PSCustomObject]@{
            SubscriptionName = $currentSubName
            SubscriptionId = $currentSubId
            SubscriptionState = "Enabled"
        }
    }
} catch {
    Write-Error "Failed to get Azure context: $_"
    exit 1
}

Write-Host ""

# Retrieve Resource Groups
Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "SECTION 2: RESOURCE GROUPS" -ForegroundColor Green
Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host ""

foreach ($sub in $accessibleSubscriptions) {
    try {
        $null = Set-AzContext -SubscriptionId $sub.SubscriptionId -ErrorAction Stop
        
        Write-Host "Retrieving Resource Groups from: $($sub.SubscriptionName)" -ForegroundColor White
        
        $resourceGroups = Get-AzResourceGroup -ErrorAction Stop
        
        if ($resourceGroups) {
            foreach ($rg in $resourceGroups) {
                $allResourceGroups += [PSCustomObject]@{
                    SubscriptionName = $sub.SubscriptionName
                    ResourceGroupName = $rg.ResourceGroupName
                    Location = $rg.Location
                    ProvisioningState = $rg.ProvisioningState
                }
            }
            
            Write-Host ""
            Write-Host "Resource Groups in $($sub.SubscriptionName):" -ForegroundColor Yellow
            $allResourceGroups | Format-Table -AutoSize
        } else {
            Write-Host "No resource groups found in $($sub.SubscriptionName)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host ""
        Write-Host "WARNING: Could not access subscription '$($sub.SubscriptionName)': $_" -ForegroundColor Red
        continue
    }
}

if ($allResourceGroups.Count -eq 0) {
    Write-Host "No resource groups found or access was denied." -ForegroundColor Yellow
}

Write-Host ""

# Retrieve Resources
Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "SECTION 3: RESOURCES" -ForegroundColor Green
Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host ""

foreach ($sub in $accessibleSubscriptions) {
    try {
        $null = Set-AzContext -SubscriptionId $sub.SubscriptionId -ErrorAction Stop
        
        Write-Host "Retrieving Resources from: $($sub.SubscriptionName)" -ForegroundColor White
        
        $resources = Get-AzResource -ErrorAction Stop
        
        if ($resources) {
            foreach ($res in $resources) {
                $allResources += [PSCustomObject]@{
                    SubscriptionName = $sub.SubscriptionName
                    ResourceName = $res.Name
                    ResourceType = $res.Type
                    ResourceGroupName = $res.ResourceGroupName
                    Location = $res.Location
                }
            }
            
            Write-Host ""
            Write-Host "Resources in $($sub.SubscriptionName):" -ForegroundColor Yellow
            $allResources | Format-Table -AutoSize
        } else {
            Write-Host "No resources found in $($sub.SubscriptionName)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host ""
        Write-Host "WARNING: Could not access subscription '$($sub.SubscriptionName)': $_" -ForegroundColor Red
        continue
    }
}

if ($allResources.Count -eq 0) {
    Write-Host "No resources found or access was denied." -ForegroundColor Yellow
}

Write-Host ""

# Categorize Resources by Type
Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "SECTION 4: RESOURCES BY CATEGORY" -ForegroundColor Green
Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host ""

if ($allResources.Count -gt 0) {
    # Virtual Machines
    $vms = $allResources | Where-Object { $_.ResourceType -eq 'Microsoft.Compute/virtualMachines' }
    if ($vms) {
        Write-Host "Virtual Machines (Count: $($vms.Count))" -ForegroundColor Yellow
        $vms | Format-Table -AutoSize
    } else {
        Write-Host "Virtual Machines: 0 found" -ForegroundColor Gray
    }
    Write-Host ""
    
    # Virtual Networks
    $vnets = $allResources | Where-Object { $_.ResourceType -eq 'Microsoft.Network/virtualNetworks' }
    if ($vnets) {
        Write-Host "Virtual Networks (Count: $($vnets.Count))" -ForegroundColor Yellow
        $vnets | Format-Table -AutoSize
    } else {
        Write-Host "Virtual Networks: 0 found" -ForegroundColor Gray
    }
    Write-Host ""
    
    # Network Interfaces
    $nics = $allResources | Where-Object { $_.ResourceType -eq 'Microsoft.Network/networkInterfaces' }
    if ($nics) {
        Write-Host "Network Interfaces (Count: $($nics.Count))" -ForegroundColor Yellow
        $nics | Format-Table -AutoSize
    } else {
        Write-Host "Network Interfaces: 0 found" -ForegroundColor Gray
    }
    Write-Host ""
    
    # Network Security Groups
    $nsgs = $allResources | Where-Object { $_.ResourceType -eq 'Microsoft.Network/networkSecurityGroups' }
    if ($nsgs) {
        Write-Host "Network Security Groups (Count: $($nsgs.Count))" -ForegroundColor Yellow
        $nsgs | Format-Table -AutoSize
    } else {
        Write-Host "Network Security Groups: 0 found" -ForegroundColor Gray
    }
    Write-Host ""
    
    # Public IP Addresses
    $publicIPs = $allResources | Where-Object { $_.ResourceType -eq 'Microsoft.Network/publicIPAddresses' }
    if ($publicIPs) {
        Write-Host "Public IP Addresses (Count: $($publicIPs.Count))" -ForegroundColor Yellow
        $publicIPs | Format-Table -AutoSize
    } else {
        Write-Host "Public IP Addresses: 0 found" -ForegroundColor Gray
    }
    Write-Host ""
} else {
    Write-Host "No resources to categorize." -ForegroundColor Yellow
}

Write-Host ""

# Summary Section
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "                              SUMMARY" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Total Accessible Subscriptions: $($accessibleSubscriptions.Count)" -ForegroundColor White
Write-Host "Total Resource Groups Discovered: $($allResourceGroups.Count)" -ForegroundColor White
Write-Host "Total Resources Discovered: $($allResources.Count)" -ForegroundColor White
Write-Host ""

if ($allResources.Count -gt 0) {
    Write-Host "Per-Category Counts:" -ForegroundColor Yellow
    Write-Host "  - Virtual Machines: $($vms.Count)" -ForegroundColor White
    Write-Host "  - Virtual Networks: $($vnets.Count)" -ForegroundColor White
    Write-Host "  - Network Interfaces: $($nics.Count)" -ForegroundColor White
    Write-Host "  - Network Security Groups: $($nsgs.Count)" -ForegroundColor White
    Write-Host "  - Public IP Addresses: $($publicIPs.Count)" -ForegroundColor White
}

Write-Host ""
Write-Host "Script Completed: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Yellow
Write-Host "================================================================================" -ForegroundColor Cyan
