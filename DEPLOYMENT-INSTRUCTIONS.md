# Step-by-Step Deployment Instructions

## Prerequisites

You have two Azure accounts:
1. **Project Resource Account** - Main account for deployment
2. **Exercise Resource Account** - Additional account

## Step 1: Open Azure Cloud Shell

1. Go to https://portal.azure.com
2. Sign in with your **Project Resource** credentials:
   - Username: `student_7pmnzenmmmm8k04w_005061913@vocareumvocareum.onmicrosoft.com`
   - Password: `X#ts$L%W4BUrdo$wOZWK$rkBrHTPo&`
   - Temporary Access Pass: `=nMC8&=q` (if needed)

3. Click the **Cloud Shell** icon (>_) in the top toolbar
4. Select **PowerShell** mode when prompted
5. If first time, follow setup wizard to create storage

## Step 2: Upload Files to Cloud Shell

1. In Cloud Shell, click the **Upload/Download files** button (folder icon)
2. Select **Upload** and upload these files:
   - `policy-vm-size-restriction.json`
   - `policy-web-farm-sku.json`
   - `policy-require-tag-with-values.json`
   - `create-custom-role.ps1`
   - `deploy-all-policies.ps1`

3. Verify files are uploaded:
   ```powershell
   ls -la
   ```

## Step 3: Run the Deployment Script

1. Make the script executable and run it:
   ```powershell
   chmod +x deploy-all-policies.ps1
   ./deploy-all-policies.ps1
   ```

2. The script will:
   - Deploy VM Size Restriction policy ✓
   - Deploy Web Farm SKU Restriction policy ✓
   - Deploy Tagging policy ✓
   - Assign Department tag policy ✓
   - Assign Environment tag policy ✓
   - Assign Allowed Locations policy ✓
   - Create VaultSecretCertificateManager custom role ✓
   - Provide instructions for PCI DSS v4 ✓

3. Watch for any errors (they'll be in red)

## Step 4: Assign PCI DSS v4 Initiative (Manual)

### Option A: Via Azure Portal (Recommended)
1. In Azure Portal, go to **Policy** > **Definitions**
2. Change filter "Type" to **Initiative**
3. Search for "PCI DSS v4"
4. Click on "PCI DSS v4"
5. Click **Assign**
6. Select:
   - Scope: Your subscription
   - Assignment name: `pci-dss-v4`
   - Click **Review + create** > **Create**

### Option B: Via Cloud Shell
```powershell
$pcidss = Get-AzPolicySetDefinition | Where-Object { $_.Properties.DisplayName -like '*PCI DSS v4*' }
New-AzPolicyAssignment -Name 'pci-dss-v4' -DisplayName 'PCI DSS v4 Compliance' -Scope "/subscriptions/$((Get-AzContext).Subscription.Id)" -PolicySetDefinition $pcidss
```

## Step 5: Verify Deployments

Run these commands to verify everything is deployed:

```powershell
# Check policy assignments
Get-AzPolicyAssignment | Select-Object Name, DisplayName, Scope

# Check custom role
Get-AzRoleDefinition -Name 'VaultSecretCertificateManager'

# Check policy definitions
Get-AzPolicyDefinition -Custom | Select-Object Name, DisplayName
```

Expected output:
- 5 policy assignments (vm-size, web-farm, dept-tag, env-tag, locations)
- 1 PCI DSS v4 initiative assignment
- 1 custom role (VaultSecretCertificateManager)
- 3 custom policy definitions

## Step 6: Capture Screenshots

Now that everything is deployed, capture the 14 required screenshots:

### Policy Screenshots (5 screenshots)

1. **VM Size Policy Assignment**
   - Go to: Policy > Assignments
   - Find: "Restrict Virtual Machine SKU Sizes"
   - Screenshot: Assignment details page

2. **Location Policy Assignment**
   - Find: "Restrict to East US 2 and Central US"
   - Click: Parameters tab
   - Screenshot: Showing eastus2 and centralus

3. **Department Tag Policy**
   - Find: "Require Department Tag"
   - Click: Parameters tab
   - Screenshot: Showing tagName="Department", values=Finance,Engineering

4. **Environment Tag Policy**
   - Find: "Require Environment Tag"
   - Click: Parameters tab
   - Screenshot: Showing tagName="Environment", values=Dev,Test,Prod

5. **Web Farm SKU Policy**
   - Find: "Restrict App Service Plan SKU Sizes"
   - Screenshot: Assignment details page

### Compliance Screenshot (1 screenshot)

6. **PCI DSS v4 Initiative**
   - Go to: Policy > Assignments
   - Filter by Type: Initiative
   - Find: "PCI DSS v4"
   - Screenshot: Initiative assignment showing subscription scope

### Groups & Roles Screenshots (5 screenshots)

7. **KeyvaultSecretAndCertificateAdmins Group**
   - Go to: Azure Active Directory > Groups
   - Search: "KeyvaultSecretAndCertificateAdmins"
   - Screenshot: Group overview with members

8. **Group's Custom Role Assignment**
   - In group page, click: "Azure role assignments"
   - Screenshot: Showing VaultSecretCertificateManager role

9. **Group has Reader on Subscription**
   - Go to: Subscriptions > [Your Subscription] > Access Control (IAM)
   - Click: Role assignments tab
   - Search: "KeyvaultSecretAndCertificateAdmins"
   - Screenshot: Showing Reader role

10. **Group has VaultSecretCertificateManager on Key Vault**
    - Go to: Key Vaults > kv-devshared-* > Access Control (IAM)
    - Screenshot: Group with VaultSecretCertificateManager role

11. **external-contributors Group**
    - Go to: Resource Groups > rg-external > Access Control (IAM)
    - Screenshot: external-contributors with Contributor role

### Budget Screenshots (3 screenshots)

12. **Budget Configuration**
    - Go to: Cost Management + Billing > Budgets
    - Screenshot: Budget showing $250 limit on Dev subscription

13. **Budget Alert Rules**
    - Click on budget > View details
    - Screenshot: Alert conditions (80% and 100% thresholds)

14. **Action Group**
    - Click on action group link
    - Screenshot: Email and SMS notification settings

## Step 7: Organize Screenshots

1. Name your screenshots clearly:
   - `01-vm-size-policy.png`
   - `02-location-policy.png`
   - `03-department-tag.png`
   - `04-environment-tag.png`
   - `05-web-farm-sku.png`
   - `06-pci-dss-initiative.png`
   - `07-keyvault-group.png`
   - `08-group-custom-role.png`
   - `09-group-reader-subscription.png`
   - `10-group-keyvault-role.png`
   - `11-external-contributors.png`
   - `12-budget-config.png`
   - `13-budget-alerts.png`
   - `14-action-group.png`

## Troubleshooting

### If policies don't deploy:
```powershell
# Check for errors
Get-AzPolicyDefinition -Name 'restrict-vm-sizes' -ErrorAction Continue
```

### If role creation fails:
```powershell
# Verify you have permissions
Get-AzRoleDefinition | Where-Object { $_.IsCustom -eq $true }
```

### If PCI DSS v4 not found:
- It may take a few minutes for built-in initiatives to load
- Try refreshing the Azure Portal
- Ensure you're looking at the correct subscription

## Final Checklist

Before submitting, verify you have:
- [ ] All 3 policy JSON files
- [ ] create-custom-role.ps1 script
- [ ] All 14 screenshots (clearly labeled)
- [ ] All policies showing as "Assigned" in Azure Portal
- [ ] Custom role exists in Azure AD
- [ ] Groups and role assignments are configured

## Need Help?

- Check `SCREENSHOTS-REQUIRED.md` for detailed screenshot instructions
- Check `QUICK-START-GUIDE.md` for deployment command reference
- Check `REVIEWER-FEEDBACK-RESOLUTION.md` for explanations of fixes

---

**Good luck with your submission!**
