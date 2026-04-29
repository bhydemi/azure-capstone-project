# Tag Policy Assignment Examples

This document shows how to assign the `policy-require-tag-with-values.json` policy twice with different parameters.

## Assignment 1: Department Tag

### Azure Portal
1. Create the custom policy definition using `policy-require-tag-with-values.json`
2. Assign the policy with these parameters:
   - **Tag Name**: `Department`
   - **Allowed Tag Values**: `["Finance", "Engineering"]`
   - **Assignment Name**: `require-department-tag`

### PowerShell
```powershell
# Create policy definition (only once)
$policyDef = New-AzPolicyDefinition `
    -Name 'require-tag-with-values' `
    -DisplayName 'Require tag with allowed values on resources' `
    -Policy 'policy-require-tag-with-values.json' `
    -Mode 'Indexed'

# Assignment 1: Department tag
$departmentParams = @{
    'tagName' = 'Department'
    'allowedTagValues' = @('Finance', 'Engineering')
}

New-AzPolicyAssignment `
    -Name 'require-department-tag' `
    -DisplayName 'Require Department Tag with Valid Values' `
    -Scope "/subscriptions/<subscription-id>" `
    -PolicyDefinition $policyDef `
    -PolicyParameterObject $departmentParams
```

## Assignment 2: Environment Tag

### Azure Portal
1. Use the same policy definition created above
2. Create a second assignment with these parameters:
   - **Tag Name**: `Environment`
   - **Allowed Tag Values**: `["Dev", "Test", "Prod"]`
   - **Assignment Name**: `require-environment-tag`

### PowerShell
```powershell
# Assignment 2: Environment tag
$environmentParams = @{
    'tagName' = 'Environment'
    'allowedTagValues' = @('Dev', 'Test', 'Prod')
}

New-AzPolicyAssignment `
    -Name 'require-environment-tag' `
    -DisplayName 'Require Environment Tag with Valid Values' `
    -Scope "/subscriptions/<subscription-id>" `
    -PolicyDefinition $policyDef `
    -PolicyParameterObject $environmentParams
```

## Example: Adding a Third Tag (CostCenter)
```powershell
# Assignment 3: CostCenter tag
$costCenterParams = @{
    'tagName' = 'CostCenter'
    'allowedTagValues' = @('Americas', 'Europe', 'APAC')
}

New-AzPolicyAssignment `
    -Name 'require-costcenter-tag' `
    -DisplayName 'Require CostCenter Tag with Valid Values' `
    -Scope "/subscriptions/<subscription-id>" `
    -PolicyDefinition $policyDef `
    -PolicyParameterObject $costCenterParams
```

## Testing the Policy

### Valid Resource Creation
```powershell
# This should succeed
New-AzResourceGroup `
    -Name 'test-rg' `
    -Location 'eastus2' `
    -Tag @{
        Department = 'Finance'
        Environment = 'Dev'
    }
```

### Invalid Resource Creation
```powershell
# This should fail - missing Department tag
New-AzResourceGroup `
    -Name 'test-rg-fail1' `
    -Location 'eastus2' `
    -Tag @{
        Environment = 'Dev'
    }

# This should fail - invalid Department value
New-AzResourceGroup `
    -Name 'test-rg-fail2' `
    -Location 'eastus2' `
    -Tag @{
        Department = 'Sales'
        Environment = 'Dev'
    }
```
