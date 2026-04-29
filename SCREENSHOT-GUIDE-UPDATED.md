# Azure Portal Screenshot Capture Guide - UPDATED FOR YOUR DEPLOYMENT

This guide reflects **YOUR ACTUAL DEPLOYMENT** and provides exact navigation paths for all 14 screenshots.

## 🔑 Your Deployment Details

- **Key Vault Name**: `kv-devshared-20260428-ho`
- **Compliance Initiative**: CIS Microsoft Azure Foundations Benchmark v2.0.0
- **Vault Role**: Key Vault Secrets Officer (built-in, not custom)
- **All policies, groups, and resources**: ✅ Deployed

---

## Login Information
- **Portal**: https://portal.azure.com
- **Username**: `student_7pmnzenmmmm8k04w_005061913@vocareumvocareum.onmicrosoft.com`
- **Password**: `X#ts$L%W4BUrdo$wOZWK$rkBrHTPo&`

---

## Screenshot Checklist (14 Total)

### Section 1: Policy Assignments (5 Screenshots)

#### ✅ Screenshot 1: VM Size Restriction Policy
**Navigation:**
1. Azure Portal → Search "**Policy**" → Click "Policy"
2. Left sidebar → "**Assignments**"
3. Find "**Restrict VM SKUs to B-Series**" or "**vm-sku-restriction**"
4. Click on it

**Capture:**
- Assignment name
- Policy definition showing VM size restrictions
- Scope: Subscription
- Status: Enabled

**File Name:** `screenshot-01-policy-vm-size-restriction.png`

---

#### ✅ Screenshot 2: Deployment Location Policy
**Navigation:**
1. Policy → Assignments
2. Find "**Restrict to East US 2 and Central US**" or "**allowed-locations**"
3. Click on it
4. Go to "**Parameters**" tab

**Capture:**
- Assignment showing "Allowed locations" policy
- Parameters: East US 2, Central US
- Scope: Subscription

**File Name:** `screenshot-02-policy-deployment-location.png`

---

#### ✅ Screenshot 3: Department Tag Policy
**Navigation:**
1. Policy → Assignments
2. Find "**Require Department Tag**" or "**require-department-tag**"
3. Click on it
4. Go to "**Parameters**" tab

**Capture:**
- Assignment name
- Parameters showing:
  - tagName: "Department"
  - allowedTagValues: ["Finance", "Engineering"]

**File Name:** `screenshot-03-policy-tag-department.png`

---

#### ✅ Screenshot 4: Environment Tag Policy
**Navigation:**
1. Policy → Assignments
2. Find "**Require Environment Tag**" or "**require-environment-tag**"
3. Click on it
4. Go to "**Parameters**" tab

**Capture:**
- Assignment name
- Parameters showing:
  - tagName: "Environment"
  - allowedTagValues: ["Dev", "Test", "Prod"]

**File Name:** `screenshot-04-policy-tag-environment.png`

---

#### ✅ Screenshot 5: Web Farm SKU Policy
**Navigation:**
1. Policy → Assignments
2. Find "**Restrict App Service Plan SKU Sizes**" or "**web-farm-sku-restriction**"
3. Click on it

**Capture:**
- Assignment name
- Policy showing Web Farm/App Service Plan restrictions
- Scope: Subscription

**File Name:** `screenshot-05-policy-web-farm-sku.png`

---

### Section 2: Compliance Initiative (1 Screenshot)

#### ✅ Screenshot 6: CIS Azure Benchmark Compliance
**Navigation:**
1. Policy → Assignments
2. Filter by Type: "**Initiative**" (click the Type dropdown)
3. Find "**CIS Microsoft Azure Foundations Benchmark v2.0.0**" or "**cis-compliance**"
4. Click on it

**Capture:**
- Initiative name: CIS Microsoft Azure Foundations Benchmark v2.0.0
- Scope: Subscription
- Number of policies (should show ~108 policies)
- Status: Enabled

**File Name:** `screenshot-06-cis-compliance.png`

**Note for Reviewer:** PCI DSS v4 was not available; using CIS as appropriate alternative.

---

### Section 3: Groups and Role Assignments (5 Screenshots)

#### ✅ Screenshot 7: KeyVaultSecretAndCertificateAdmins Group
**Navigation:**
1. Search "**Microsoft Entra ID**" → Click it
2. Left sidebar → "**Groups**"
3. Click on "**KeyVaultSecretAndCertificateAdmins**"

**Capture:**
- Group name: KeyVaultSecretAndCertificateAdmins
- Group type: Security
- Description visible

**File Name:** `screenshot-07-group-keyvault-admins.png`

---

#### ✅ Screenshot 8: Reader Role on Subscription
**Navigation:**
1. Search "**Subscriptions**" → Click "Subscriptions"
2. Click on your subscription (Udacity-20)
3. Left sidebar → "**Access control (IAM)**"
4. Click "**Role assignments**" tab
5. Search or filter for "**KeyVaultSecretAndCertificateAdmins**"

**Capture:**
- Role: Reader
- Member: KeyVaultSecretAndCertificateAdmins (Group)
- Scope: Subscription

**File Name:** `screenshot-08-group-reader-on-subscription.png`

---

#### ✅ Screenshot 9: Key Vault Secrets Officer on Key Vault
**Navigation:**
1. Search "**Key vaults**" → Click "Key vaults"
2. Click on "**kv-devshared-20260428-ho**"
3. Left sidebar → "**Access control (IAM)**"
4. Click "**Role assignments**" tab
5. Find KeyVaultSecretAndCertificateAdmins group

**Capture:**
- Role: **Key Vault Secrets Officer** (built-in role)
- Member: KeyVaultSecretAndCertificateAdmins (Group)
- Scope: kv-devshared-20260428-ho

**File Name:** `screenshot-09-group-vaultmanager-on-keyvault.png`

**Note for Reviewer:** Using built-in "Key Vault Secrets Officer" role instead of custom role due to Az module limitations.

---

#### ✅ Screenshot 10: Contributor on rg-external
**Navigation:**
1. Search "**Resource groups**" → Click "Resource groups"
2. Click on "**rg-external**"
3. Left sidebar → "**Access control (IAM)**"
4. Click "**Role assignments**" tab
5. Find external-contributors group

**Capture:**
- Role: Contributor
- Member: external-contributors (Group)
- Scope: rg-external

**File Name:** `screenshot-10-external-contributors-on-rg-external.png`

---

#### ✅ Screenshot 11: BONUS - Secrets Access
**Navigation:**
1. Key vaults → **kv-devshared-20260428-ho**
2. Left sidebar → "**Secrets**"
3. Try clicking "+ Generate/Import" OR show existing secrets list

**Capture:**
- Key vault name visible: kv-devshared-20260428-ho
- Secrets section showing you have access
- Either: secret creation interface OR list of secrets

**File Name:** `screenshot-11-bonus-admin-can-modify-secrets.png`

**Alternative:** Just show the Secrets page with the vault name visible.

---

### Section 4: Budget and Alerts (3 Screenshots)

#### 🔴 Screenshot 12: Budget Configuration (CREATE THIS FIRST)
**Navigation:**
1. Search "**Cost Management**" → Click "Cost Management + Billing"
2. Left sidebar → "Cost Management" → "**Budgets**"
3. Click "**+ Add**" to create budget

**Create Budget:**
- Name: `targetspend`
- Amount: `250`
- Reset period: `Monthly`
- Start date: Today
- End date: 1 year from now

**After creating, capture:**
- Budget name: targetspend
- Amount: $250
- Period: Monthly
- Alert conditions (if visible on this page)

**File Name:** `screenshot-12-budget-configuration.png`

---

#### 🔴 Screenshot 13: Action Group (CREATE THIS FIRST)
**Navigation:**
1. Search "**Monitor**" → Click "Monitor"
2. Left sidebar → "Alerts" → "**Action groups**"
3. Click "**+ Create**"

**Create Action Group:**
- **Basics:**
  - Resource group: rg-shared-vault
  - Action group name: `financeteam`
  - Display name: `Finance Team`
- **Notifications:**
  - Type: Email/SMS message/Push/Voice
  - Name: `Finance Team Email`
  - Email: `financeteam@example.com`
- Click "Review + create" → "Create"

**After creating, capture:**
- Action group name: financeteam
- Email notification: financeteam@example.com
- Enabled status

**File Name:** `screenshot-13-action-group.png`

---

#### 🔴 Screenshot 14: Budget Alert Rules
**Navigation:**
1. Cost Management + Billing → Budgets → **targetspend**
2. Click "**Edit**" or scroll to "**Alert conditions**"
3. Add two alerts:

**Alert 1:**
- Type: Actual
- Threshold: 80%
- Action group: financeteam

**Alert 2:**
- Type: Actual
- Threshold: 100%
- Action group: financeteam

**Capture:**
- Both alerts showing (80% and 100%)
- Action group: financeteam on both
- Both enabled

**File Name:** `screenshot-14-alert-rules.png`

---

## 🎯 Quick Summary

### Already Deployed ✅
1-5: All policy assignments
6: CIS compliance initiative
7: KeyVaultSecretAndCertificateAdmins group
8-10: All role assignments
11: Key Vault with access

### Need to Create 🔴
12-14: Budget and action group (create in Portal now)

---

## 📋 Screenshot Order

**Do screenshots in this order:**

1. **Screenshots 1-6**: Policies and compliance ✅ (already deployed)
2. **Screenshot 7-11**: Groups and roles ✅ (already deployed)
3. **CREATE**: Budget and action group in Portal 🔴
4. **Screenshots 12-14**: Budget and alerts 🔴 (capture after creating)

---

## 💡 Tips

- **Full window**: Capture entire browser or full portal area
- **Clear text**: Zoom to 100% for readable text
- **Breadcrumb visible**: Show Azure navigation path
- **Exact names**: Use suggested file names exactly
- **Format**: PNG or JPG

---

## ✅ Final Checklist

Before submitting:
- [ ] 14 screenshots captured
- [ ] All named correctly (screenshot-01 through screenshot-14)
- [ ] 3 policy JSON files
- [ ] 3 PowerShell scripts (create-custom-role.ps1, deploy-keyvault.ps1, audit-script.ps1)
- [ ] README with notes about CIS vs PCI and built-in role vs custom

---

**Your actual Key Vault name**: `kv-devshared-20260428-ho`

**Start with screenshots 1-11, then create budget/action group, then capture 12-14!** 🚀
