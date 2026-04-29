# Azure Portal Screenshot Capture Guide

This guide provides **exact navigation paths** to capture all 14 required screenshots for your Azure Capstone Project submission.

## Login Information
- **Portal**: https://portal.azure.com
- **Username**: `student_7pmnzenmmmm8k04w_005061913@vocareumvocareum.onmicrosoft.com`
- **Password**: `X#ts$L%W4BUrdo$wOZWK$rkBrHTPo&`

---

## Screenshot Checklist (14 Total)

### Section 1: Policy Assignments (5 Screenshots)

#### Screenshot 1: VM Size Restriction Policy Assignment
**Navigation Path:**
1. Azure Portal → Search "Policy" → Click "Policy"
2. Left sidebar → "Assignments"
3. Find assignment for "Restrict Virtual Machine SKU Sizes"
4. Click on the assignment name

**What to Capture:**
- Assignment name
- Scope (subscription)
- Policy definition name: "Restrict Virtual Machine SKU Sizes"
- Status: Enabled

**File Name:** `screenshot-01-policy-vm-size-restriction.png`

---

#### Screenshot 2: Deployment Location Policy Assignment (Built-in)
**Navigation Path:**
1. Azure Portal → Search "Policy" → Click "Policy"
2. Left sidebar → "Assignments"
3. Find assignment for "Allowed locations" (this is the built-in policy)
4. Click on the assignment name

**What to Capture:**
- Assignment name
- Scope (subscription)
- Policy definition name: "Allowed locations"
- Parameters showing: East US 2 and Central US
- Status: Enabled

**File Name:** `screenshot-02-policy-deployment-location.png`

**Note:** If this policy is NOT assigned yet, you need to assign it first:
```powershell
# Assign built-in "Allowed locations" policy
$subscription = Get-AzSubscription
New-AzPolicyAssignment -Name 'allowed-locations-policy' `
    -DisplayName 'Restrict Deployment to East US 2 and Central US' `
    -Scope "/subscriptions/$($subscription.Id)" `
    -PolicyDefinition (Get-AzPolicyDefinition | Where-Object {$_.Properties.DisplayName -eq 'Allowed locations'}) `
    -PolicyParameterObject @{
        'listOfAllowedLocations' = @('eastus2', 'centralus')
    }
```

---

#### Screenshot 3: Department Tag Policy Assignment
**Navigation Path:**
1. Azure Portal → Search "Policy" → Click "Policy"
2. Left sidebar → "Assignments"
3. Find assignment for "Require tag with allowed values" (Department)
4. Click on the assignment name
5. Click "Parameters" tab

**What to Capture:**
- Assignment name (should mention "Department")
- Scope (subscription)
- Parameters tab showing:
  - tagName: "Department"
  - allowedTagValues: ["Finance", "Engineering"]
- Status: Enabled

**File Name:** `screenshot-03-policy-tag-department.png`

**Note:** If this policy is NOT assigned yet, assign it:
```powershell
# First, create the policy definition
$policyDef = New-AzPolicyDefinition -Name 'require-tag-with-values' `
    -DisplayName 'Require tag with allowed values on resources' `
    -Policy (Get-Content './policy-require-tag-with-values.json' -Raw) `
    -Mode Indexed

# Then assign it for Department tag
$subscription = Get-AzSubscription
New-AzPolicyAssignment -Name 'require-department-tag' `
    -DisplayName 'Require Department Tag with Allowed Values' `
    -Scope "/subscriptions/$($subscription.Id)" `
    -PolicyDefinition $policyDef `
    -PolicyParameterObject @{
        'tagName' = 'Department'
        'allowedTagValues' = @('Finance', 'Engineering')
    }
```

---

#### Screenshot 4: Environment Tag Policy Assignment
**Navigation Path:**
1. Azure Portal → Search "Policy" → Click "Policy"
2. Left sidebar → "Assignments"
3. Find assignment for "Require tag with allowed values" (Environment)
4. Click on the assignment name
5. Click "Parameters" tab

**What to Capture:**
- Assignment name (should mention "Environment")
- Scope (subscription)
- Parameters tab showing:
  - tagName: "Environment"
  - allowedTagValues: ["Dev", "Test", "Prod"]
- Status: Enabled

**File Name:** `screenshot-04-policy-tag-environment.png`

**Note:** If this policy is NOT assigned yet, assign it:
```powershell
# Assign the same policy definition for Environment tag
$policyDef = Get-AzPolicyDefinition -Name 'require-tag-with-values'
$subscription = Get-AzSubscription
New-AzPolicyAssignment -Name 'require-environment-tag' `
    -DisplayName 'Require Environment Tag with Allowed Values' `
    -Scope "/subscriptions/$($subscription.Id)" `
    -PolicyDefinition $policyDef `
    -PolicyParameterObject @{
        'tagName' = 'Environment'
        'allowedTagValues' = @('Dev', 'Test', 'Prod')
    }
```

---

#### Screenshot 5: Web Farm SKU Restriction Policy Assignment
**Navigation Path:**
1. Azure Portal → Search "Policy" → Click "Policy"
2. Left sidebar → "Assignments"
3. Find assignment for "Restrict App Service Plan (Server Farm) SKU Sizes"
4. Click on the assignment name

**What to Capture:**
- Assignment name
- Scope (subscription)
- Policy definition name: "Restrict App Service Plan (Server Farm) SKU Sizes"
- Status: Enabled

**File Name:** `screenshot-05-policy-web-farm-sku.png`

---

### Section 2: PCI Compliance Initiative (1 Screenshot)

#### Screenshot 6: PCI DSS v4 Initiative Assignment
**Navigation Path:**
1. Azure Portal → Search "Policy" → Click "Policy"
2. Left sidebar → "Assignments"
3. Find assignment for "PCI DSS v4" or filter by Type: "Initiative"
4. Click on the assignment name

**What to Capture:**
- Assignment name
- Scope (subscription)
- Initiative/Definition name: "PCI DSS v4.0"
- Number of policies included
- Status: Enabled

**File Name:** `screenshot-06-pci-compliance.png`

**Note:** If this initiative is NOT assigned yet, assign it:
```powershell
# Find PCI DSS v4 initiative
$initiative = Get-AzPolicySetDefinition | Where-Object {$_.Properties.DisplayName -like "*PCI DSS*v4*"}

# Assign to subscription
$subscription = Get-AzSubscription
New-AzPolicyAssignment -Name 'pci-dss-v4-compliance' `
    -DisplayName 'PCI DSS v4 Compliance' `
    -Scope "/subscriptions/$($subscription.Id)" `
    -PolicySetDefinition $initiative
```

---

### Section 3: Groups and Role Assignments (5 Screenshots)

#### Screenshot 7: KeyVaultSecretAndCertificateAdmins Group
**Navigation Path:**
1. Azure Portal → Search "Microsoft Entra ID" → Click "Microsoft Entra ID"
2. Left sidebar → "Groups"
3. Find and click "KeyVaultSecretAndCertificateAdmins" (or your unique name)
4. Overview page

**What to Capture:**
- Group name: KeyVaultSecretAndCertificateAdmins
- Group type: Security
- Membership type
- Description: "Administrators of key vaults in the subscription"

**File Name:** `screenshot-07-group-keyvault-admins.png`

**Note:** If this group does NOT exist yet, create it:
```powershell
# Create the security group
New-AzADGroup -DisplayName 'KeyVaultSecretAndCertificateAdmins' `
    -MailNickname 'kvadmins' `
    -Description 'Administrators of key vaults in the subscription' `
    -SecurityEnabled
```

---

#### Screenshot 8: Group Has Reader Role on Subscription
**Navigation Path:**
1. Azure Portal → Search "Subscriptions" → Click "Subscriptions"
2. Click on your subscription
3. Left sidebar → "Access control (IAM)"
4. Click "Role assignments" tab
5. Filter or search for "KeyVaultSecretAndCertificateAdmins"
6. Find the row showing Reader role

**What to Capture:**
- Role: Reader
- Member: KeyVaultSecretAndCertificateAdmins (group)
- Scope: Subscription level
- Type: Group

**File Name:** `screenshot-08-group-reader-on-subscription.png`

**Note:** If this role is NOT assigned yet:
```powershell
# Get the group
$group = Get-AzADGroup -DisplayName 'KeyVaultSecretAndCertificateAdmins'

# Get subscription scope
$subscription = Get-AzSubscription
$scope = "/subscriptions/$($subscription.Id)"

# Assign Reader role
New-AzRoleAssignment -ObjectId $group.Id `
    -RoleDefinitionName 'Reader' `
    -Scope $scope
```

---

#### Screenshot 9: Group Has VaultSecretCertificateManager Role on Key Vault
**Navigation Path:**
1. Azure Portal → Search "Key vaults" → Click "Key vaults"
2. Click on your key vault (kv-devshared-YYYYMMDDxyz)
3. Left sidebar → "Access control (IAM)"
4. Click "Role assignments" tab
5. Find the row showing VaultSecretCertificateManager role

**What to Capture:**
- Role: VaultSecretCertificateManager (custom role)
- Member: KeyVaultSecretAndCertificateAdmins (group)
- Scope: Key vault resource
- Type: Group

**File Name:** `screenshot-09-group-vaultmanager-on-keyvault.png`

**Note:** If this role is NOT assigned yet:
```powershell
# Get the group
$group = Get-AzADGroup -DisplayName 'KeyVaultSecretAndCertificateAdmins'

# Get the key vault
$vault = Get-AzKeyVault -Name 'kv-devshared-YYYYMMDDxyz'  # Replace with your vault name

# Assign custom role
New-AzRoleAssignment -ObjectId $group.Id `
    -RoleDefinitionName 'VaultSecretCertificateManager' `
    -Scope $vault.ResourceId
```

---

#### Screenshot 10: External Contributors Group with Contributor Role on rg-external
**Navigation Path:**
1. Azure Portal → Search "Resource groups" → Click "Resource groups"
2. Click on "rg-external"
3. Left sidebar → "Access control (IAM)"
4. Click "Role assignments" tab
5. Find the row showing Contributor role for external-contributors group

**What to Capture:**
- Role: Contributor
- Member: external-contributors (group)
- Scope: rg-external resource group
- Type: Group

**File Name:** `screenshot-10-external-contributors-on-rg-external.png`

**Note:** If this does NOT exist yet, create it:
```powershell
# Create resource group
New-AzResourceGroup -Name 'rg-external' `
    -Location 'eastus2' `
    -Tag @{Department='Engineering'; Environment='Dev'}

# Create group
New-AzADGroup -DisplayName 'external-contributors' `
    -MailNickname 'extcontrib' `
    -Description 'External contributors with access to rg-external' `
    -SecurityEnabled

# Get the group
$group = Get-AzADGroup -DisplayName 'external-contributors'

# Get resource group
$rg = Get-AzResourceGroup -Name 'rg-external'

# Assign Contributor role
New-AzRoleAssignment -ObjectId $group.Id `
    -RoleDefinitionName 'Contributor' `
    -Scope $rg.ResourceId
```

---

#### Screenshot 11: BONUS - Admin Can Modify Secrets in Vault
**Navigation Path:**
1. Azure Portal → Search "Key vaults" → Click "Key vaults"
2. Click on your key vault (kv-devshared-YYYYMMDDxyz)
3. Left sidebar → "Secrets"
4. Click "+ Generate/Import"
5. Create a test secret (you can capture this screen)

**Alternative - Show Existing Secret:**
1. Azure Portal → Key vault → Secrets
2. Show a secret you created
3. Show you can view/edit it

**What to Capture:**
- Key vault name visible
- Secret creation/editing interface
- Your ability to access the secrets section

**File Name:** `screenshot-11-bonus-admin-can-modify-secrets.png`

**Note:** To test this with PowerShell:
```powershell
# Add yourself to the KeyVaultSecretAndCertificateAdmins group
$group = Get-AzADGroup -DisplayName 'KeyVaultSecretAndCertificateAdmins'
$currentUser = Get-AzADUser -UserPrincipalName (Get-AzContext).Account.Id
Add-AzADGroupMember -TargetGroupObjectId $group.Id -MemberObjectId $currentUser.Id

# Wait a few minutes for permissions to propagate, then:
$secretValue = ConvertTo-SecureString 'TestSecretValue123!' -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName 'kv-devshared-YYYYMMDDxyz' `  # Replace with your vault name
    -Name 'test-secret' `
    -SecretValue $secretValue
```

---

### Section 4: Budget and Alerts (3 Screenshots)

#### Screenshot 12: Budget Configuration
**Navigation Path:**
1. Azure Portal → Search "Cost Management" → Click "Cost Management + Billing"
2. Left sidebar → "Cost Management" → "Budgets"
3. Click on your budget (targetspend)
4. View budget details

**What to Capture:**
- Budget name: targetspend
- Amount: $250
- Time period: Monthly
- Scope: Your subscription
- Alert conditions visible (80% and 100%)

**File Name:** `screenshot-12-budget-configuration.png`

**Note:** If budget does NOT exist yet, create it:
```powershell
# This requires using Azure CLI
az consumption budget create `
    --budget-name 'targetspend' `
    --amount 250 `
    --time-period-start '2026-01-01' `
    --time-period-end '2027-12-31' `
    --time-grain 'Monthly' `
    --category 'Cost' `
    --resource-group-filter '' # Leave empty for subscription scope
```

Or create via Portal:
1. Cost Management + Billing → Budgets → + Add
2. Name: targetspend
3. Amount: 250
4. Reset period: Monthly
5. Add alerts at 80% and 100%

---

#### Screenshot 13: Action Group Configuration
**Navigation Path:**
1. Azure Portal → Search "Monitor" → Click "Monitor"
2. Left sidebar → "Alerts" → "Action groups"
3. Click on "financeteam" action group
4. View configuration

**What to Capture:**
- Action group name: financeteam
- Notifications configured
- Email: financeteam@example.com
- Subscription scope

**File Name:** `screenshot-13-action-group.png`

**Note:** If action group does NOT exist yet, create it:
```powershell
# Create action group via Portal:
# Monitor → Alerts → Action groups → + Create
# Name: financeteam
# Short name: finteam
# Notifications → Email/SMS → Add email: financeteam@example.com
```

Or via CLI:
```bash
az monitor action-group create `
    --name 'financeteam' `
    --short-name 'finteam' `
    --resource-group 'rg-shared-vault' `  # Or another RG
    --action email finance financeteam@example.com
```

---

#### Screenshot 14: Alert Rules (Budget Thresholds)
**Navigation Path:**
1. Azure Portal → Cost Management + Billing → Budgets
2. Click on "targetspend" budget
3. Scroll down to "Alert conditions" or "Alert rules" section

**What to Capture:**
- Alert 1: 80% of budget (actual cost)
- Alert 2: 100% of budget (actual cost)
- Action group: financeteam
- Both alerts enabled

**File Name:** `screenshot-14-alert-rules.png`

**Note:** These alerts should be configured when creating the budget. To edit:
1. Go to budget → Edit
2. Add/edit alert conditions
3. Ensure both 80% and 100% thresholds exist
4. Ensure both reference the "financeteam" action group

---

## Quick Deployment Check Commands

Before capturing screenshots, verify everything is deployed:

```powershell
# Connect to Azure
Connect-AzAccount

# Check policies
Get-AzPolicyAssignment | Select-Object Name, DisplayName | Format-Table

# Check custom role
Get-AzRoleDefinition -Name 'VaultSecretCertificateManager'

# Check groups
Get-AzADGroup -DisplayName 'KeyVaultSecretAndCertificateAdmins'
Get-AzADGroup -DisplayName 'external-contributors'

# Check resource groups
Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -in @('rg-shared-vault', 'rg-external', 'rg-electronicsunlimited-web', 'rg-deployment-resources')}

# Check key vault
Get-AzKeyVault | Where-Object {$_.VaultName -like 'kv-devshared-*'}

# Check role assignments on key vault
$vault = Get-AzKeyVault -Name 'kv-devshared-YYYYMMDDxyz'  # Replace with your vault name
Get-AzRoleAssignment -Scope $vault.ResourceId

# Check budgets (via CLI)
az consumption budget list
```

---

## Screenshot Tips

1. **Use Full Window:** Capture the entire browser window or at least the full Azure portal content area
2. **Clear Navigation:** Ensure the Azure portal navigation breadcrumb is visible
3. **Readable Text:** Make sure all text is clear and readable
4. **No Sensitive Data:** The example emails (example.com) are fine, but don't include any real sensitive information
5. **File Format:** PNG or JPG are both acceptable
6. **File Naming:** Use the exact file names suggested above for easy review

---

## Final Verification Checklist

Before submitting, ensure you have:

- [ ] All 14 screenshots captured and named correctly
- [ ] All policy JSON files (3 files)
- [ ] All PowerShell scripts (3 main scripts)
- [ ] Documentation files (README, guides, etc.)
- [ ] Screenshots are clear and show all required information
- [ ] Policies are actually assigned (not just defined)
- [ ] Groups exist and have correct role assignments
- [ ] Budget and alerts are configured

---

## Need Help?

If any resource doesn't exist yet, use the PowerShell commands provided in each section to create them before capturing screenshots.

**Good luck with your submission!** 🚀
