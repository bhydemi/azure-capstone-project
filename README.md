# Azure Capstone Project - Corrected Submission

All reviewer feedback has been addressed. This project now includes complete policy definitions, corrected custom role permissions, and comprehensive documentation.

## 📁 Project Structure

```
├── README.md (this file)
├── QUICK-START-GUIDE.md ⭐ START HERE
├── REVIEWER-FEEDBACK-RESOLUTION.md (detailed explanations)
├── SCREENSHOTS-REQUIRED.md (screenshot checklist)
│
├── Policy Definitions (JSON)
│   ├── policy-vm-size-restriction.json (complete definition)
│   ├── policy-web-farm-sku.json (complete definition)
│   ├── policy-require-tag-with-values.json (unified tagging policy)
│   ├── policy-deployment-location-note.md (built-in policy reference)
│   └── policy-tag-assignment-examples.md (assignment examples)
│
├── PowerShell Scripts
│   ├── create-custom-role.ps1 (FIXED: now uses DataActions)
│   ├── deploy-keyvault.ps1
│   └── audit-script.ps1
│
└── Screenshots (to be captured)
    └── See SCREENSHOTS-REQUIRED.md for complete list
```

## 🚀 Quick Start

**New to this project? Start here:**

1. **Read**: `QUICK-START-GUIDE.md` - Deployment steps and quick reference
2. **Deploy**: Follow the PowerShell commands to deploy policies and roles
3. **Capture**: Use `SCREENSHOTS-REQUIRED.md` checklist for all 14 required screenshots
4. **Review**: Check `REVIEWER-FEEDBACK-RESOLUTION.md` to understand all fixes

## ✅ What Was Fixed

### 1. Deployment Location Policy
- **Changed from**: Custom policy with hardcoded locations
- **Changed to**: Reference to built-in "Allowed locations" policy
- **Why**: Locations should be parameters, not hardcoded
- **File**: `policy-deployment-location-note.md`

### 2. Tagging Policy
- **Changed from**: Two separate incomplete policies
- **Changed to**: ONE parameterized policy assigned twice
- **Why**: Reusable design, validates both existence and values
- **Files**:
  - `policy-require-tag-with-values.json` (policy definition)
  - `policy-tag-assignment-examples.md` (how to use)

### 3. Custom Role (VaultSecretCertificateManager)
- **Changed from**: Uses Actions (management plane)
- **Changed to**: Uses DataActions (data plane)
- **Why**: Users need data plane permissions to modify secrets/certificates
- **File**: `create-custom-role.ps1`

### 4. Policy Definitions
- **Changed from**: Only policyRule section
- **Changed to**: Complete policy definition with all properties
- **Why**: Required for proper policy deployment
- **Files**: All `policy-*.json` files

### 5. Documentation
- **Added**: Comprehensive screenshot instructions
- **Added**: Deployment guides and examples
- **Added**: Testing and validation procedures

## 📋 Required Screenshots (14 total)

Quick checklist - see `SCREENSHOTS-REQUIRED.md` for details:

**Policies** (5):
- [ ] VM Size Restriction assignment
- [ ] Deployment Location assignment (built-in policy)
- [ ] Department Tag assignment with parameters
- [ ] Environment Tag assignment with parameters
- [ ] Web Farm SKU assignment

**Compliance** (1):
- [ ] PCI DSS v4 initiative assignment

**Groups & Roles** (5):
- [ ] KeyvaultSecretAndCertificateAdmins group
- [ ] Group has Reader on Subscription
- [ ] Group has VaultSecretCertificateManager on Key Vault
- [ ] external-contributors has Contributor on rg-external
- [ ] (Bonus) Admin can modify secrets

**Budgets** (3):
- [ ] Budget configuration ($250)
- [ ] Action group (email/SMS)
- [ ] Alert rules (80%, 100%)

## 📦 Files to Submit

### Required Policy Files ✅
1. `policy-vm-size-restriction.json` - Complete VM SKU policy
2. `policy-web-farm-sku.json` - Complete App Service Plan SKU policy
3. `policy-require-tag-with-values.json` - Unified tagging policy

### Required Scripts ✅
1. `create-custom-role.ps1` - Idempotent script with DataActions

### Required Screenshots ⏳
1. Follow `SCREENSHOTS-REQUIRED.md` to capture all 14 screenshots

### Supporting Documentation ✅
1. `policy-deployment-location-note.md` - Built-in policy reference
2. `policy-tag-assignment-examples.md` - Tag policy assignment examples
3. This README and all guides

## 🔧 Key Technical Details

### Tagging Policy Parameters
```json
{
  "tagName": "Department",
  "allowedTagValues": ["Finance", "Engineering"]
}
```

Assign the same policy twice with different parameters:
- Assignment 1: Department tag
- Assignment 2: Environment tag

### Custom Role DataActions
The role now correctly uses:
- **Actions**: `Microsoft.KeyVault/vaults/read` (management plane)
- **DataActions**: Secret and certificate operations (data plane)

This allows users to actually modify secrets and certificates.

### Built-in Location Policy
Policy ID: `e56962a6-4747-49cd-b67b-bf8b01975c4c`

Assign with parameters:
```powershell
$params = @{
    'listOfAllowedLocations' = @('eastus2', 'centralus')
}
```

## 🧪 Testing Your Deployment

### Test Tagging Policy
```powershell
# Should SUCCEED
New-AzResourceGroup -Name 'test-rg' -Location 'eastus2' -Tag @{
    Department = 'Finance'; Environment = 'Dev'
}

# Should FAIL - invalid Department value
New-AzResourceGroup -Name 'test-fail' -Location 'eastus2' -Tag @{
    Department = 'Sales'; Environment = 'Dev'
}
```

### Test Custom Role
```powershell
# User with VaultSecretCertificateManager role should be able to:
$secret = ConvertTo-SecureString "TestValue" -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName "kv-devshared-*" -Name "test" -SecretValue $secret
```

## 📚 Documentation Files

| File | Purpose |
|------|---------|
| `QUICK-START-GUIDE.md` | Fast deployment and testing guide |
| `REVIEWER-FEEDBACK-RESOLUTION.md` | Detailed explanation of all fixes |
| `SCREENSHOTS-REQUIRED.md` | Complete screenshot checklist with instructions |
| `policy-tag-assignment-examples.md` | Examples for assigning tagging policy |
| `policy-deployment-location-note.md` | Built-in location policy reference |

## ❓ Common Questions

**Q: Why use a built-in policy for locations?**
A: Locations should be specified as parameters during assignment, not hardcoded in the policy definition. Built-in policies follow this best practice.

**Q: Why one tagging policy instead of two?**
A: One parameterized policy can be assigned multiple times with different values, making it more flexible and maintainable.

**Q: Why do we need DataActions for the Key Vault role?**
A: Actions grant management plane permissions (managing the vault itself). DataActions grant data plane permissions (accessing secrets and certificates).

**Q: Where are the old tag policy files?**
A: Removed. The old `policy-tag-department.json` and `policy-tag-environment.json` were incomplete and have been replaced by the unified `policy-require-tag-with-values.json`.

## 🎯 Next Steps

1. **Deploy**: Follow `QUICK-START-GUIDE.md` to deploy all policies and roles
2. **Test**: Run the validation tests to ensure everything works
3. **Screenshot**: Capture all 14 required screenshots using the checklist
4. **Submit**: Package all JSON files, PowerShell scripts, and screenshots

## 📞 Support

If you encounter issues:
1. Check the detailed resolution guide: `REVIEWER-FEEDBACK-RESOLUTION.md`
2. Review deployment examples: `QUICK-START-GUIDE.md`
3. Verify screenshot requirements: `SCREENSHOTS-REQUIRED.md`

---

**Status**: All reviewer feedback addressed ✅
**Ready for submission**: After capturing required screenshots ⏳

**Good luck!** 🚀
