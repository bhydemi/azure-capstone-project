# Restricted Deployment Location Policy

## Important Note
This policy should use the Azure **built-in policy** "Allowed locations" rather than a custom policy.

### Built-in Policy Details
- **Policy Name**: Allowed locations
- **Policy ID**: `e56962a6-4747-49cd-b67b-bf8b01975c4c`
- **Display Name**: Allowed locations

### Assignment Instructions
1. Navigate to Azure Policy in the Azure Portal
2. Go to Assignments > Assign Policy
3. Search for "Allowed locations" in the built-in policies
4. Select the policy
5. Choose your scope (Subscription or Resource Group)
6. Under Parameters, select the allowed locations:
   - East US 2
   - Central US
7. Review and create the assignment

### Why Use Built-in Policy?
- Locations should be specified as **parameters during assignment**, not hardcoded in the policy
- This allows the same policy to be reused with different location requirements
- Built-in policies are maintained by Microsoft and follow best practices

### PowerShell Assignment Example
```powershell
$allowedLocations = @('eastus2', 'centralus')
$parameters = @{
    'listOfAllowedLocations' = @{
        'value' = $allowedLocations
    }
}

New-AzPolicyAssignment `
    -Name 'restrict-deployment-locations' `
    -DisplayName 'Restrict Deployment to East US 2 and Central US' `
    -Scope "/subscriptions/<subscription-id>" `
    -PolicyDefinition (Get-AzPolicyDefinition | Where-Object {$_.Properties.DisplayName -eq 'Allowed locations'}) `
    -PolicyParameterObject $parameters
```
