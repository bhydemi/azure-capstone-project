# Azure Capstone Project - Reviewer Feedback Resolution

This document summarizes how all reviewer feedback has been addressed.

## Overview of Changes

All policy definitions have been updated to include complete JSON structures, the tagging policy has been redesigned with parameters, the custom role has been fixed to use DataActions, and comprehensive screenshot instructions have been provided.

---

## 1. Restricted Deployment Location Policy

### Reviewer Feedback
> "Restricted Deployment Location should use parameters and only have locations allocated through the assignment, not the policy (hint: this is a built-in policy)."

### Resolution
**File**: `policy-deployment-location-note.md`

Instead of a custom policy, documented the use of the built-in "Allowed locations" policy:
- **Policy ID**: `e56962a6-4747-49cd-b67b-bf8b01975c4c`
- **Policy Name**: Allowed locations
- Locations (East US 2, Central US) are specified as **parameters during assignment**
- Includes PowerShell example for assignment with parameters

**Why this approach**:
- Built-in policies are maintained by Microsoft
- Parameters allow reusability with different location requirements
- Follows Azure best practices

---

## 2. Tagging Policy (Department & Environment)

### Reviewer Feedback
> "I see two policies for tags on department listed in the project, but it's not correctly defined as a policy. 'field': 'tags.Department' is not valid. You need to reference the tag correctly if you are going to do that as the limitation, however, I don't think you want to limit your policy to a specific tag until assignment."
>
> "Consider using a single policy that both ensures tags exist AND denies unless the tag has a specific name and one of many allowed values. This should be one JSON file not two."

### Resolution
**Files**:
- `policy-require-tag-with-values.json` (complete policy definition)
- `policy-tag-assignment-examples.md` (assignment examples)

Created **ONE** unified policy with parameters:
- **Parameter 1**: `tagName` - Specifies which tag to enforce (e.g., "Department" or "Environment")
- **Parameter 2**: `allowedTagValues` - Array of allowed values for the tag

The policy enforces BOTH requirements:
1. The tag must exist on the resource
2. The tag value must be one of the allowed values

**Can be assigned multiple times**:
- **Assignment 1**: Department tag with values ["Finance", "Engineering"]
- **Assignment 2**: Environment tag with values ["Dev", "Test", "Prod"]
- **Future**: Can be assigned again for CostCenter, Project, etc.

**Technical Implementation**:
```json
"if": {
  "anyOf": [
    {
      "field": "[concat('tags[', parameters('tagName'), ']')]",
      "exists": "false"
    },
    {
      "field": "[concat('tags[', parameters('tagName'), ']')]",
      "notIn": "[parameters('allowedTagValues')]"
    }
  ]
}
```

**Old files removed**: `policy-tag-department.json` and `policy-tag-environment.json` (these were incomplete)

---

## 3. VM Size Restriction Policy

### Reviewer Feedback
> "Also, I would prefer to see the entire policy file, not just the relevant internal sections."

### Resolution
**File**: `policy-vm-size-restriction.json`

Updated to include **complete policy definition**:
```json
{
  "properties": {
    "displayName": "Restrict Virtual Machine SKU Sizes",
    "policyType": "Custom",
    "mode": "Indexed",
    "description": "...",
    "metadata": {
      "category": "Compute",
      "version": "1.0.0"
    },
    "parameters": {},
    "policyRule": {
      // ... complete rule
    }
  }
}
```

Previously contained only the `policyRule` section. Now includes:
- displayName
- policyType
- mode
- description
- metadata
- parameters (empty object, but present)
- policyRule (the actual policy logic)

---

## 4. Web Server Farm SKU Policy

### Reviewer Feedback
> "VM and WebFarm are accurate and complete." (but also requested full policy file)

### Resolution
**File**: `policy-web-farm-sku.json`

Updated to include **complete policy definition** with all required sections:
- Properties wrapper
- Display name and description
- Metadata with category and version
- Parameters object
- Complete policy rule

The policy logic remains accurate (restricts to B1 and P0v3 SKUs), but now includes the full policy definition structure.

---

## 5. VaultSecretCertificateManager Custom Role

### Reviewer Feedback
> "This role only grants management operations on the vault resource, not the actual secret/certificate data operations. Secrets and Certificates require data plane permissions ('DataActions') not ('Actions')."
>
> "While this role would be able to be assigned, the user with this permission would not be able to modify secrets or certificates in the KeyVault since data plane actions are not correctly assigned."

### Resolution
**File**: `create-custom-role.ps1`

**Critical Fix**: Changed from management plane (Actions) to data plane (DataActions)

**Before** (INCORRECT):
```powershell
$role.Actions = @(
    "Microsoft.KeyVault/vaults/secrets/get/action",
    "Microsoft.KeyVault/vaults/secrets/set/action",
    # ... etc
)
```

**After** (CORRECT):
```powershell
# Management plane - read access to vault
$role.Actions = @(
    "Microsoft.KeyVault/vaults/read"
)

# Data plane - actual secret/certificate operations
$role.DataActions = @(
    # Secrets
    "Microsoft.KeyVault/vaults/secrets/getSecret/action",
    "Microsoft.KeyVault/vaults/secrets/setSecret/action",
    "Microsoft.KeyVault/vaults/secrets/delete",
    "Microsoft.KeyVault/vaults/secrets/backup/action",
    "Microsoft.KeyVault/vaults/secrets/restore/action",
    "Microsoft.KeyVault/vaults/secrets/readMetadata/action",
    # Certificates
    "Microsoft.KeyVault/vaults/certificates/read",
    "Microsoft.KeyVault/vaults/certificates/write",
    "Microsoft.KeyVault/vaults/certificates/delete",
    "Microsoft.KeyVault/vaults/certificates/backup/action",
    "Microsoft.KeyVault/vaults/certificates/restore/action",
    "Microsoft.KeyVault/vaults/certificates/managecontacts/action",
    "Microsoft.KeyVault/vaults/certificates/manageissuers/action"
)
```

**Key Differences**:
- **Actions**: Control plane operations (create/delete vault, modify vault settings)
- **DataActions**: Data plane operations (read/write secrets and certificates)

Users with this role can now:
- ✅ Read the Key Vault resource details
- ✅ Get, set, delete secrets
- ✅ Read, write, delete certificates
- ✅ Backup and restore secrets/certificates
- ✅ Manage certificate contacts and issuers

---

## 6. Missing Screenshots

### Reviewer Feedback
Multiple instances of:
> "I do not see any screenshots for applied policy."
> "I don't see a screenshot of this group"
> "I don't see the screenshot of this group, or it's permissions."
> "I don't see any screenshots for this section."

### Resolution
**File**: `SCREENSHOTS-REQUIRED.md`

Created comprehensive checklist with **14 required screenshots**:

**Policy Assignments** (5 screenshots):
1. VM Size Restriction assignment
2. Deployment Location (built-in policy) assignment
3. Department Tag policy assignment with parameters
4. Environment Tag policy assignment with parameters
5. Web Farm SKU policy assignment

**Compliance** (1 screenshot):
6. PCI DSS v4 initiative assignment to subscription

**Groups & Roles** (5 screenshots):
7. KeyvaultSecretAndCertificateAdmins group overview
8. KeyvaultSecretAndCertificateAdmins - Reader role on Subscription
9. KeyvaultSecretAndCertificateAdmins - VaultSecretCertificateManager on Key Vault
10. external-contributors - Contributor on rg-external
11. (Bonus) Admin successfully modifying a secret

**Budgets** (3 screenshots):
12. Budget configuration ($250 limit on Dev subscription)
13. Action group (email/SMS alerts)
14. Alert rules (80% and 100% thresholds)

Each screenshot requirement includes:
- What to capture
- Where to find it in Azure Portal
- What details must be visible
- Step-by-step instructions

---

## 7. PCI DSS v4 Initiative

### Reviewer Feedback
> "I do not see any screenshots for applied policy. Please ensure you have assigned the policy and have then taken a screenshot that shows the policy is applied on the resource group."
>
> "Ensure you have assigned the correct PCI Compliance initiative to the subscription. Initiative: PCI DSS v4"

### Resolution
**File**: `SCREENSHOTS-REQUIRED.md` (Section: Compliance Initiatives)

Provided detailed instructions for:
- Assigning PCI DSS v4 initiative to the subscription
- Capturing screenshot showing:
  - Initiative name: "PCI DSS v4"
  - Scope: Subscription level
  - Assignment status
- Navigation: Azure Portal > Policy > Assignments > Filter by Type: Initiative

---

## Summary of Deliverables

### ✅ Complete Policy JSON Files
1. `policy-vm-size-restriction.json` - Full definition with all properties
2. `policy-web-farm-sku.json` - Full definition with all properties
3. `policy-require-tag-with-values.json` - Unified tagging policy with parameters
4. `policy-deployment-location-note.md` - Built-in policy reference with assignment examples

### ✅ PowerShell Scripts
1. `create-custom-role.ps1` - Fixed to use DataActions for Key Vault secrets/certificates

### ✅ Documentation
1. `SCREENSHOTS-REQUIRED.md` - Complete checklist of 14 required screenshots
2. `policy-tag-assignment-examples.md` - Examples of assigning tagging policy twice
3. `REVIEWER-FEEDBACK-RESOLUTION.md` - This document

### ⏳ Screenshots Needed
- Follow the detailed instructions in `SCREENSHOTS-REQUIRED.md`
- 14 total screenshots required
- Each screenshot must show specific details as outlined

---

## Key Improvements Made

1. **Parameterization**: Policies now use parameters where appropriate, making them reusable
2. **Complete Definitions**: All custom policies include full JSON structure, not just rules
3. **Built-in Policy Usage**: Deployment location uses Azure's built-in policy as recommended
4. **Data Plane Permissions**: Custom role now correctly uses DataActions for Key Vault operations
5. **Unified Tagging**: One policy definition assigned multiple times instead of multiple similar policies
6. **Comprehensive Documentation**: Clear instructions for completing all missing requirements

---

## Next Steps

1. **Deploy Policies**: Use the complete JSON definitions to create/update policy definitions in Azure
2. **Assign Policies**: Follow examples in documentation to assign policies with correct parameters
3. **Run Custom Role Script**: Execute `create-custom-role.ps1` to create/update the role with data plane permissions
4. **Capture Screenshots**: Follow `SCREENSHOTS-REQUIRED.md` checklist to capture all 14 required screenshots
5. **Submit Project**: Submit all JSON files, PowerShell scripts, and screenshots

---

## Testing Recommendations

### Test Tagging Policy
```powershell
# Should succeed - valid tags
New-AzResourceGroup -Name 'test-rg' -Location 'eastus2' -Tag @{
    Department = 'Finance'
    Environment = 'Dev'
}

# Should fail - missing Department tag
New-AzResourceGroup -Name 'test-rg-fail' -Location 'eastus2' -Tag @{
    Environment = 'Dev'
}

# Should fail - invalid Department value
New-AzResourceGroup -Name 'test-rg-fail2' -Location 'eastus2' -Tag @{
    Department = 'Sales'  # Not in allowed values
    Environment = 'Dev'
}
```

### Test Custom Role
```powershell
# After assigning role to a user, test secret operations
$secretValue = ConvertTo-SecureString "TestValue123!" -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName "kv-devshared-*" -Name "test-secret" -SecretValue $secretValue

# Should succeed if DataActions are correct
# Should fail if only Actions (management plane) are assigned
```

---

## Contact
For questions about these changes, refer to the inline documentation in each file or the comprehensive instructions in `SCREENSHOTS-REQUIRED.md`.
