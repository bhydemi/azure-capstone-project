# Azure Capstone Project - Quick Start Guide

## What Was Fixed

All reviewer feedback has been addressed. Here's what changed:

### 1. Policy Files - Now Complete ✅
All policy JSON files now include **full policy definitions**, not just rules:
- `policy-vm-size-restriction.json` - Complete VM SKU policy
- `policy-web-farm-sku.json` - Complete App Service Plan SKU policy
- `policy-require-tag-with-values.json` - **NEW** unified tagging policy with parameters

### 2. Tagging Policy - Redesigned ✅
- **OLD**: Two separate incomplete policies for Department and Environment tags
- **NEW**: ONE policy with parameters that can be assigned twice
- Can enforce any tag name with any list of allowed values
- See: `policy-tag-assignment-examples.md` for how to use it

### 3. Deployment Location - Use Built-in Policy ✅
- **Should NOT use custom policy**
- Use Azure built-in "Allowed locations" policy (ID: `e56962a6-4747-49cd-b67b-bf8b01975c4c`)
- See: `policy-deployment-location-note.md` for instructions

### 4. Custom Role - Fixed for Data Plane ✅
- `create-custom-role.ps1` now uses **DataActions** (not Actions)
- Users can now actually modify secrets and certificates
- Includes both control plane (vault read) and data plane (secret/cert operations)

### 5. Screenshot Instructions - Comprehensive ✅
- `SCREENSHOTS-REQUIRED.md` has detailed instructions for all 14 required screenshots
- Step-by-step navigation for each screenshot
- Checklist to track completion

---

## Quick Deployment Steps

### Step 1: Deploy Custom Policies (3 policies)

```powershell
# 1. VM Size Restriction
New-AzPolicyDefinition `
    -Name 'restrict-vm-sizes' `
    -DisplayName 'Restrict Virtual Machine SKU Sizes' `
    -Policy 'policy-vm-size-restriction.json' `
    -Mode 'Indexed'

New-AzPolicyAssignment `
    -Name 'vm-size-restriction' `
    -Scope "/subscriptions/<subscription-id>" `
    -PolicyDefinition (Get-AzPolicyDefinition -Name 'restrict-vm-sizes')

# 2. Web Farm SKU Restriction
New-AzPolicyDefinition `
    -Name 'restrict-web-farm-skus' `
    -DisplayName 'Restrict App Service Plan SKU Sizes' `
    -Policy 'policy-web-farm-sku.json' `
    -Mode 'Indexed'

New-AzPolicyAssignment `
    -Name 'web-farm-sku-restriction' `
    -Scope "/subscriptions/<subscription-id>" `
    -PolicyDefinition (Get-AzPolicyDefinition -Name 'restrict-web-farm-skus')

# 3. Tagging Policy (create once, assign twice)
New-AzPolicyDefinition `
    -Name 'require-tag-with-values' `
    -DisplayName 'Require tag with allowed values on resources' `
    -Policy 'policy-require-tag-with-values.json' `
    -Mode 'Indexed'

# Assignment 1: Department tag
$deptParams = @{
    'tagName' = 'Department'
    'allowedTagValues' = @('Finance', 'Engineering')
}

New-AzPolicyAssignment `
    -Name 'require-department-tag' `
    -DisplayName 'Require Department Tag' `
    -Scope "/subscriptions/<subscription-id>" `
    -PolicyDefinition (Get-AzPolicyDefinition -Name 'require-tag-with-values') `
    -PolicyParameterObject $deptParams

# Assignment 2: Environment tag
$envParams = @{
    'tagName' = 'Environment'
    'allowedTagValues' = @('Dev', 'Test', 'Prod')
}

New-AzPolicyAssignment `
    -Name 'require-environment-tag' `
    -DisplayName 'Require Environment Tag' `
    -Scope "/subscriptions/<subscription-id>" `
    -PolicyDefinition (Get-AzPolicyDefinition -Name 'require-tag-with-values') `
    -PolicyParameterObject $envParams
```

### Step 2: Assign Built-in Location Policy

```powershell
$locationParams = @{
    'listOfAllowedLocations' = @('eastus2', 'centralus')
}

New-AzPolicyAssignment `
    -Name 'allowed-locations' `
    -DisplayName 'Restrict to East US 2 and Central US' `
    -Scope "/subscriptions/<subscription-id>" `
    -PolicyDefinition (Get-AzPolicyDefinition | Where-Object {$_.Properties.DisplayName -eq 'Allowed locations'}) `
    -PolicyParameterObject $locationParams
```

### Step 3: Create Custom Role

```powershell
# Run the fixed script
./create-custom-role.ps1
```

### Step 4: Assign PCI DSS v4 Initiative

**Use Azure Portal** (recommended):
1. Navigate to Policy > Definitions
2. Filter by Type: "Initiative"
3. Search for "PCI DSS v4"
4. Click Assign
5. Select subscription as scope
6. Review and create

**OR use PowerShell**:
```powershell
$pcidssInitiative = Get-AzPolicySetDefinition | Where-Object {$_.Properties.DisplayName -like "*PCI DSS v4*"}

New-AzPolicyAssignment `
    -Name 'pci-dss-v4' `
    -DisplayName 'PCI DSS v4 Compliance' `
    -Scope "/subscriptions/<subscription-id>" `
    -PolicySetDefinition $pcidssInitiative
```

### Step 5: Capture Screenshots

Follow the detailed checklist in `SCREENSHOTS-REQUIRED.md`:

**Quick Checklist**:
- [ ] 5 Policy assignment screenshots
- [ ] 1 PCI DSS initiative screenshot
- [ ] 2 Group screenshots (KeyvaultSecretAndCertificateAdmins)
- [ ] 3 Permission assignment screenshots
- [ ] 3 Budget/alert screenshots

**Total**: 14 screenshots needed

---

## Files to Submit

### Policy JSON Files
✅ `policy-vm-size-restriction.json`
✅ `policy-web-farm-sku.json`
✅ `policy-require-tag-with-values.json`

### PowerShell Scripts
✅ `create-custom-role.ps1`

### Screenshots
⏳ 14 screenshots (follow `SCREENSHOTS-REQUIRED.md`)

---

## Common Issues & Solutions

### Issue: "Tag validation not working"
**Solution**: Ensure you're using the NEW `policy-require-tag-with-values.json` file, not the old tag-department or tag-environment files.

### Issue: "Users can't modify secrets in Key Vault"
**Solution**: The role must use **DataActions**, not Actions. Use the updated `create-custom-role.ps1` script.

### Issue: "Deployment location policy isn't parameterized"
**Solution**: Use the built-in "Allowed locations" policy, not a custom policy. See `policy-deployment-location-note.md`.

### Issue: "Policy file won't import"
**Solution**: Ensure you're using the complete policy definition with the `properties` wrapper, not just the `policyRule` section.

---

## Validation Tests

### Test 1: VM Size Restriction
```powershell
# Should FAIL - VM size not allowed
New-AzVm -ResourceGroupName "test-rg" -Name "test-vm" -Size "Standard_D2s_v3" -Location "eastus2"

# Should SUCCEED - VM size allowed
New-AzVm -ResourceGroupName "test-rg" -Name "test-vm" -Size "Standard_B2s" -Location "eastus2"
```

### Test 2: Location Restriction
```powershell
# Should FAIL - Location not allowed
New-AzResourceGroup -Name "test-rg" -Location "westus"

# Should SUCCEED - Location allowed
New-AzResourceGroup -Name "test-rg" -Location "eastus2"
```

### Test 3: Tagging
```powershell
# Should FAIL - Missing required tags
New-AzResourceGroup -Name "test-rg" -Location "eastus2"

# Should FAIL - Invalid tag value
New-AzResourceGroup -Name "test-rg" -Location "eastus2" -Tag @{Department = 'HR'; Environment = 'Dev'}

# Should SUCCEED - All tags valid
New-AzResourceGroup -Name "test-rg" -Location "eastus2" -Tag @{Department = 'Finance'; Environment = 'Dev'}
```

### Test 4: Custom Role
```powershell
# Sign in as user with VaultSecretCertificateManager role
$secretValue = ConvertTo-SecureString "TestValue123!" -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName "kv-devshared-*" -Name "test-secret" -SecretValue $secretValue

# Should SUCCEED if DataActions are configured correctly
Get-AzKeyVaultSecret -VaultName "kv-devshared-*" -Name "test-secret"
```

---

## Need Help?

1. **Policy not working?** - Check `REVIEWER-FEEDBACK-RESOLUTION.md` for detailed explanations
2. **Need assignment examples?** - See `policy-tag-assignment-examples.md`
3. **Screenshot instructions?** - See `SCREENSHOTS-REQUIRED.md`
4. **Location policy?** - See `policy-deployment-location-note.md`

---

## Final Submission Checklist

- [ ] All 3 custom policy JSON files created/updated with complete definitions
- [ ] Custom role script (`create-custom-role.ps1`) updated with DataActions
- [ ] Policies deployed to Azure subscription
- [ ] Custom role created in Azure
- [ ] All 14 required screenshots captured
- [ ] Screenshots clearly show required details
- [ ] All files organized and ready to submit

---

**Good luck with your submission!** 🚀
