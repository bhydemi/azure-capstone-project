# Action Plan: Complete Your Azure Capstone Project Submission

This document provides a clear, step-by-step action plan to address all reviewer feedback and complete your project submission.

---

## Current Status

✅ **COMPLETED:**
- All policy JSON files are correct and complete
- PowerShell scripts have proper DataActions for Key Vault role
- Deployment automation scripts created
- Comprehensive documentation created

⏳ **TODO:**
- Capture all 14 required screenshots
- Create budget and action group (if not done)
- Package final submission

---

## Quick Start (3 Steps)

### Step 1: Deploy All Resources (10-15 minutes)
```powershell
# Open PowerShell (Azure Cloud Shell or local with Az module)
cd "/Users/abdulhakeemoyaqoob/Downloads/starter (7)"

# Run the deployment script
./deploy-everything-for-screenshots.ps1
```

This script will:
- Create all custom policy definitions
- Assign all policies to your subscription
- Assign PCI DSS v4 initiative
- Create all resource groups with locks
- Create the custom Key Vault role
- Deploy the Key Vault
- Create managed identity
- Create security groups
- Assign all RBAC roles

### Step 2: Create Budget & Action Group (5-10 minutes)

**Follow the detailed guide:** `BUDGET-AND-ALERTS-SETUP.md`

Quick summary:
1. Create action group "financeteam" with email financeteam@example.com
2. Create budget "targetspend" for $250/month
3. Add alerts at 80% and 100% to budget
4. Link both alerts to "financeteam" action group

### Step 3: Capture Screenshots (15-20 minutes)

**Follow the detailed guide:** `SCREENSHOT-CAPTURE-GUIDE.md`
**Track your progress:** `SCREENSHOT-CHECKLIST.md`

Capture all 14 screenshots following the exact navigation paths provided.

---

## Detailed Action Plan

### Phase 1: Environment Preparation

**Time Estimate:** 15-20 minutes

1. **Verify Azure Access**
   ```powershell
   # Login to Azure
   Connect-AzAccount

   # Verify you're in the correct subscription
   Get-AzContext
   ```

2. **Run Deployment Script**
   ```powershell
   # Navigate to project directory
   cd "/Users/abdulhakeemoyaqoob/Downloads/starter (7)"

   # Run deployment
   ./deploy-everything-for-screenshots.ps1
   ```

3. **Verify Deployment**
   ```powershell
   # Check policies
   Get-AzPolicyAssignment | Select-Object Name, DisplayName | Format-Table

   # Check groups
   Get-AzADGroup | Where-Object {$_.DisplayName -like '*KeyVault*' -or $_.DisplayName -like '*external*'}

   # Check resource groups
   Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -like 'rg-*'}

   # Check key vault
   Get-AzKeyVault | Where-Object {$_.VaultName -like 'kv-devshared-*'}
   ```

### Phase 2: Create Budget and Action Group

**Time Estimate:** 10 minutes

**Detailed Instructions:** See `BUDGET-AND-ALERTS-SETUP.md`

1. **Create Action Group**
   - Portal: Monitor → Alerts → Action groups → + Create
   - Name: `financeteam`
   - Email: `financeteam@example.com`

2. **Create Budget**
   - Portal: Cost Management + Billing → Budgets → + Add
   - Name: `targetspend`
   - Amount: `$250`
   - Period: `Monthly`
   - Alert 1: 80% (Actual), Action Group: financeteam
   - Alert 2: 100% (Actual), Action Group: financeteam

### Phase 3: Capture Screenshots

**Time Estimate:** 20-30 minutes

**Detailed Instructions:** See `SCREENSHOT-CAPTURE-GUIDE.md`
**Progress Tracking:** Use `SCREENSHOT-CHECKLIST.md`

#### Section 1: Policies (5 screenshots)
- [ ] Screenshot 1: VM Size Restriction
- [ ] Screenshot 2: Deployment Location (Built-in)
- [ ] Screenshot 3: Department Tag
- [ ] Screenshot 4: Environment Tag
- [ ] Screenshot 5: Web Farm SKU

#### Section 2: Compliance (1 screenshot)
- [ ] Screenshot 6: PCI DSS v4

#### Section 3: Groups & Roles (5 screenshots)
- [ ] Screenshot 7: KeyVaultSecretAndCertificateAdmins Group
- [ ] Screenshot 8: Group → Reader on Subscription
- [ ] Screenshot 9: Group → VaultSecretCertificateManager on Key Vault
- [ ] Screenshot 10: external-contributors → Contributor on rg-external
- [ ] Screenshot 11: BONUS - Admin can modify secrets

#### Section 4: Budget & Alerts (3 screenshots)
- [ ] Screenshot 12: Budget Configuration
- [ ] Screenshot 13: Action Group
- [ ] Screenshot 14: Alert Rules

### Phase 4: Final Submission Package

**Time Estimate:** 5 minutes

Create a submission folder with:

```
Azure-Capstone-Project-Submission/
├── Policies/
│   ├── policy-vm-size-restriction.json
│   ├── policy-web-farm-sku.json
│   └── policy-require-tag-with-values.json
├── Scripts/
│   ├── create-custom-role.ps1
│   ├── deploy-keyvault.ps1
│   └── audit-script.ps1
├── Screenshots/
│   ├── screenshot-01-policy-vm-size-restriction.png
│   ├── screenshot-02-policy-deployment-location.png
│   ├── screenshot-03-policy-tag-department.png
│   ├── screenshot-04-policy-tag-environment.png
│   ├── screenshot-05-policy-web-farm-sku.png
│   ├── screenshot-06-pci-compliance.png
│   ├── screenshot-07-group-keyvault-admins.png
│   ├── screenshot-08-group-reader-on-subscription.png
│   ├── screenshot-09-group-vaultmanager-on-keyvault.png
│   ├── screenshot-10-external-contributors-on-rg-external.png
│   ├── screenshot-11-bonus-admin-can-modify-secrets.png
│   ├── screenshot-12-budget-configuration.png
│   ├── screenshot-13-action-group.png
│   └── screenshot-14-alert-rules.png
└── Documentation/
    ├── README.md
    ├── REVIEWER-FEEDBACK-RESOLUTION.md
    └── [other supporting docs]
```

---

## Addressing Specific Reviewer Feedback

### ✅ FIXED: Custom Policies (Challenge 3)
**Feedback:** "I would prefer to see the entire policy file, not just the relevant internal sections."

**Resolution:**
- All policy files now include complete JSON structure
- `properties`, `policyType`, `mode`, `description`, `metadata`, and `policyRule`
- Files: `policy-vm-size-restriction.json`, `policy-web-farm-sku.json`

### ✅ FIXED: Deployment Location Policy
**Feedback:** "Restricted Deployment Location should use parameters and only have locations allocated through the assignment, not the policy (hint: this is a built-in policy)."

**Resolution:**
- Using built-in "Allowed locations" policy
- Locations specified as parameters during assignment
- See: `policy-deployment-location-note.md`

### ✅ FIXED: Tagging Policy (Challenge 4)
**Feedback:** "I expected one policy with parameters for the required tag names and values... It should be able to be assigned twice with different values."

**Resolution:**
- Created single parameterized policy: `policy-require-tag-with-values.json`
- Can be assigned multiple times with different parameters
- Assignment 1: Department tag with values ["Finance", "Engineering"]
- Assignment 2: Environment tag with values ["Dev", "Test", "Prod"]
- See: `policy-tag-assignment-examples.md`

### ⏳ TODO: PCI Compliance Screenshot (Challenge 5)
**Feedback:** "I do not see any screenshots for applied policy."

**Action Required:**
- Capture screenshot showing PCI DSS v4 initiative assignment
- See: `SCREENSHOT-CAPTURE-GUIDE.md` → Screenshot 6

### ✅ FIXED: Custom Role DataActions (Challenge 10)
**Feedback:** "This role only grants management operations on the vault resource, not the actual secret/certificate data operations. Secrets and Certificates require data plane permissions ('DataActions')."

**Resolution:**
- Updated `create-custom-role.ps1` to include DataActions
- Role now has proper permissions to manage secrets and certificates
- Lines 33-49 in `create-custom-role.ps1`

### ⏳ TODO: Groups Screenshots (Challenge 14)
**Feedback:** "I don't see a screenshot of this group"

**Action Required:**
- Screenshot 7: KeyVaultSecretAndCertificateAdmins group overview
- See: `SCREENSHOT-CAPTURE-GUIDE.md` → Screenshot 7

### ⏳ TODO: Scopes Screenshots (Challenge 15)
**Feedback:** "I don't see the screenshot of this group, or it's permissions."

**Action Required:**
- Screenshot 8: Group with Reader on Subscription
- Screenshot 9: Group with VaultSecretCertificateManager on Key Vault
- Screenshot 10: external-contributors with Contributor on rg-external
- See: `SCREENSHOT-CAPTURE-GUIDE.md` → Screenshots 8-10

### ⏳ TODO: Budget Screenshots (Challenge 16)
**Feedback:** "I don't see any screenshots for this section."

**Action Required:**
- Screenshot 12: Budget configuration
- Screenshot 13: Action group
- Screenshot 14: Alert rules
- See: `SCREENSHOT-CAPTURE-GUIDE.md` → Screenshots 12-14
- See: `BUDGET-AND-ALERTS-SETUP.md` for setup instructions

---

## Resources Created by Deployment Script

### Custom Policy Definitions
1. `restrict-vm-sku-sizes` - VM Size Restriction
2. `restrict-web-farm-sku-sizes` - Web Farm SKU Restriction
3. `require-tag-with-values` - Tag Enforcement with Values

### Policy Assignments
1. VM SKU Restriction → Subscription
2. Allowed Locations (Built-in) → Subscription → Parameters: eastus2, centralus
3. Department Tag → Subscription → Parameters: Department, [Finance, Engineering]
4. Environment Tag → Subscription → Parameters: Environment, [Dev, Test, Prod]
5. Web Farm SKU Restriction → Subscription
6. PCI DSS v4 Initiative → Subscription

### Resource Groups
1. `rg-shared-vault` - With Delete Lock
2. `rg-electronicsunlimited-web` - No Lock
3. `rg-deployment-resources` - With Delete Lock
4. `rg-external` - No Lock

### Custom Role
- `VaultSecretCertificateManager` - With DataActions for secrets and certificates

### Key Vault
- `kv-devshared-YYYYMMDDxyz` - In rg-shared-vault

### Managed Identity
- `mi-deploy-eu-web-dev` - In rg-deployment-resources
- Assigned Contributor role on rg-electronicsunlimited-web

### Security Groups
1. `KeyVaultSecretAndCertificateAdmins`
   - Reader on Subscription
   - VaultSecretCertificateManager on Key Vault

2. `external-contributors`
   - Contributor on rg-external

---

## Verification Checklist

Before capturing screenshots, verify:

- [ ] All 5 custom policy assignments exist
- [ ] PCI DSS v4 initiative is assigned
- [ ] Both tag policies show correct parameters
- [ ] All 4 resource groups exist with correct tags
- [ ] rg-shared-vault has Delete lock
- [ ] rg-deployment-resources has Delete lock
- [ ] Custom role `VaultSecretCertificateManager` exists
- [ ] Key Vault exists and is RBAC-enabled
- [ ] Both security groups exist
- [ ] KeyVaultSecretAndCertificateAdmins has Reader on subscription
- [ ] KeyVaultSecretAndCertificateAdmins has VaultSecretCertificateManager on vault
- [ ] external-contributors has Contributor on rg-external
- [ ] Budget "targetspend" exists for $250/month
- [ ] Action group "financeteam" exists
- [ ] Budget has alerts at 80% and 100%

---

## Time Estimates

| Phase | Task | Time |
|-------|------|------|
| 1 | Deploy all resources | 10-15 min |
| 2 | Create budget & action group | 5-10 min |
| 3 | Capture screenshots | 20-30 min |
| 4 | Package submission | 5 min |
| **Total** | | **40-60 min** |

---

## Quick Reference: Important Files

| File | Purpose |
|------|---------|
| `ACTION-PLAN.md` | This file - overall action plan |
| `deploy-everything-for-screenshots.ps1` | Deploy all resources automatically |
| `SCREENSHOT-CAPTURE-GUIDE.md` | Detailed navigation for each screenshot |
| `SCREENSHOT-CHECKLIST.md` | Track your screenshot progress |
| `BUDGET-AND-ALERTS-SETUP.md` | Step-by-step budget and alerts setup |
| `REVIEWER-FEEDBACK-RESOLUTION.md` | Explanation of all fixes |
| `README.md` | Project overview |

---

## Troubleshooting

### Problem: Script fails with "Policy definition already exists"
**Solution:** This is expected and okay. The script is idempotent and will skip existing resources.

### Problem: Can't find PCI DSS v4 initiative
**Solution:** Use the search function in Policy → Assignments, or filter by Type: Initiative

### Problem: Role assignment fails
**Solution:** Wait 10-15 seconds after creating groups/roles for them to propagate, then retry

### Problem: Can't create budget
**Solution:** Ensure you have "Cost Management Contributor" or "Contributor" role on subscription

### Problem: Screenshots show different names
**Solution:** This is okay if your unique identifiers (dates, initials) are different. Just ensure the resource types match.

---

## Final Pre-Submission Checklist

- [ ] All policy JSON files included (3 files)
- [ ] All PowerShell scripts included (3+ files)
- [ ] All 14 screenshots captured and named correctly
- [ ] Screenshots are clear and readable
- [ ] All reviewer feedback items addressed
- [ ] Documentation files included
- [ ] Files organized in logical folder structure
- [ ] README explains project structure and fixes

---

## Next Steps

1. **Start Now:** Run `./deploy-everything-for-screenshots.ps1`
2. **Create Budget:** Follow `BUDGET-AND-ALERTS-SETUP.md`
3. **Capture Screenshots:** Follow `SCREENSHOT-CAPTURE-GUIDE.md`
4. **Track Progress:** Use `SCREENSHOT-CHECKLIST.md`
5. **Package:** Create submission folder
6. **Submit:** Upload to project submission portal

---

**You've got this!** All the hard work is done. Now it's just execution. 🚀

**Estimated Total Time:** 1 hour

**Questions?** Refer to the detailed guides for each step.

---

*Good luck with your submission!*
