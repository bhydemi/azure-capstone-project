# Required Screenshots and Completion Checklist

This document outlines all the screenshots and evidence required to complete the Azure Capstone Project based on reviewer feedback.

## Policy Assignments

### 1. Restricted VM Size Policy
**Status**: Policy definition complete
**Required Screenshot**:
- [ ] Screenshot showing the policy assignment on the resource group/subscription
- [ ] Must show: Assignment name, scope, and policy definition

**Steps to capture**:
1. Navigate to Azure Portal > Policy > Assignments
2. Find the "Restrict Virtual Machine SKU Sizes" assignment
3. Click on the assignment to view details
4. Take screenshot showing the assignment details page

### 2. Restricted Deployment Location Policy
**Status**: Should use built-in policy (see `policy-deployment-location-note.md`)
**Required Screenshot**:
- [ ] Screenshot showing the built-in "Allowed locations" policy assignment
- [ ] Must show: Parameters set to East US 2 and Central US

**Steps to capture**:
1. Navigate to Azure Portal > Policy > Assignments
2. Find the "Allowed locations" assignment
3. Click on the assignment and go to Parameters tab
4. Take screenshot showing the allowed locations parameter values

### 3. Tagging Policy Assignments (2 screenshots required)
**Status**: Policy definition complete (`policy-require-tag-with-values.json`)
**Required Screenshots**:
- [ ] Screenshot of Department tag policy assignment
  - Parameters: tagName = "Department", allowedTagValues = ["Finance", "Engineering"]
- [ ] Screenshot of Environment tag policy assignment
  - Parameters: tagName = "Environment", allowedTagValues = ["Dev", "Test", "Prod"]

**Steps to capture**:
1. Navigate to Azure Portal > Policy > Assignments
2. Find the "Require Department Tag" assignment, click to view details, screenshot the Parameters tab
3. Find the "Require Environment Tag" assignment, click to view details, screenshot the Parameters tab

### 4. Web Server Farm SKU Policy
**Status**: Policy definition complete
**Required Screenshot**:
- [ ] Screenshot showing the policy assignment
- [ ] Must show: Assignment details for App Service Plan SKU restrictions

**Steps to capture**:
1. Navigate to Azure Portal > Policy > Assignments
2. Find the "Restrict App Service Plan SKU Sizes" assignment
3. Take screenshot of the assignment details

## Compliance Initiatives

### 5. PCI DSS v4 Initiative Assignment
**Required Screenshot**:
- [ ] Screenshot showing PCI DSS v4 initiative assigned to the subscription
- [ ] Must show: Initiative name, scope (subscription), and assignment details

**Steps to capture**:
1. Navigate to Azure Portal > Policy > Assignments
2. Filter by Type: "Initiative"
3. Find the "PCI DSS v4" assignment
4. Click to view details
5. Take screenshot showing:
   - Initiative display name: "PCI DSS v4"
   - Scope: Your subscription
   - Assignment status

## Azure AD Groups and Role Assignments

### 6. KeyvaultSecretAndCertificateAdmins Group
**Required Screenshots** (2 screenshots):
- [ ] Screenshot showing the group exists in Azure AD
  - Navigate to Azure AD > Groups
  - Search for "KeyvaultSecretAndCertificateAdmins"
  - Screenshot the group overview page showing members
- [ ] Screenshot showing the custom role assignment
  - Navigate to the group's "Azure role assignments" page
  - Screenshot showing "VaultSecretCertificateManager" role assigned

**Steps to capture**:
1. Azure Portal > Azure Active Directory > Groups
2. Click on "KeyvaultSecretAndCertificateAdmins" group
3. Screenshot 1: Overview page showing group name and members
4. Click "Azure role assignments" in the left menu
5. Screenshot 2: Role assignments showing "VaultSecretCertificateManager"

### 7. KeyVaultSecretAndCertificateAdmins Permissions (2 screenshots)
**Required Screenshots**:
- [ ] Reader role on Subscription
  - Navigate to Subscription > Access Control (IAM) > Role assignments
  - Filter by group name
  - Screenshot showing Reader role assignment
- [ ] VaultSecretCertificateManager role on Key Vault (kv-devshared-yyyymmddzzz)
  - Navigate to Key Vault > Access Control (IAM) > Role assignments
  - Screenshot showing VaultSecretCertificateManager role assignment

**Steps to capture**:
1. Azure Portal > Subscriptions > [Your Subscription]
2. Click "Access Control (IAM)" > "Role assignments" tab
3. Search for "KeyvaultSecretAndCertificateAdmins"
4. Screenshot 1: Showing the group has "Reader" role at subscription scope
5. Navigate to your Key Vault resource (kv-devshared-*)
6. Click "Access Control (IAM)" > "Role assignments" tab
7. Screenshot 2: Showing the group has "VaultSecretCertificateManager" role

### 8. external-contributors Group Permissions
**Required Screenshot**:
- [ ] Contributor role on rg-external resource group
  - Navigate to Resource Group > Access Control (IAM)
  - Screenshot showing external-contributors group with Contributor role

**Steps to capture**:
1. Azure Portal > Resource Groups > "rg-external"
2. Click "Access Control (IAM)" > "Role assignments" tab
3. Search for "external-contributors"
4. Screenshot showing Contributor role assignment

### 9. Bonus: Prove Admin Can Modify Secrets
**Optional Screenshot**:
- [ ] Screenshot showing a user from KeyvaultSecretAndCertificateAdmins group successfully:
  - Creating or updating a secret in the Key Vault
  - Screenshot from the Key Vault Secrets page showing the operation succeeded

**Steps to capture**:
1. Sign in as a user who is member of KeyvaultSecretAndCertificateAdmins group
2. Navigate to the Key Vault > Secrets
3. Create or update a secret
4. Screenshot showing the secret was created/updated successfully

## Budgets and Alerts

### 10. Dev Subscription Budget (3 screenshots required)
**Required Screenshots**:
- [ ] Screenshot of the budget configuration
  - Must show: $250 limit, scope (Dev subscription)
- [ ] Screenshot of the action group
  - Must show: Email and SMS alert contacts
- [ ] Screenshot of alert rules/triggers
  - Must show: 80% threshold alert, 100% threshold alert

**Steps to capture**:
1. Azure Portal > Cost Management + Billing > Budgets
2. Find the budget for Dev subscription
3. Screenshot 1: Budget overview showing:
   - Budget name
   - Amount: $250
   - Scope: Dev subscription
   - Time period
4. Click on the budget to view details
5. Screenshot 2: Alert conditions showing:
   - Alert at 80% of budget
   - Alert at 100% of budget
6. Click on the action group link
7. Screenshot 3: Action group details showing:
   - Email notifications configured
   - SMS notifications configured

## Summary Checklist

**Policy Assignments**: 5 screenshots
- [ ] VM Size Restriction
- [ ] Deployment Location (built-in)
- [ ] Department Tag
- [ ] Environment Tag
- [ ] Web Farm SKU

**Compliance**: 1 screenshot
- [ ] PCI DSS v4 Initiative

**Groups & Roles**: 5 screenshots
- [ ] KeyvaultSecretAndCertificateAdmins group exists
- [ ] KeyvaultSecretAndCertificateAdmins has Reader on Subscription
- [ ] KeyvaultSecretAndCertificateAdmins has VaultSecretCertificateManager on Key Vault
- [ ] external-contributors has Contributor on rg-external
- [ ] (Bonus) Admin can modify secrets

**Budgets**: 3 screenshots
- [ ] Budget configuration ($250 limit)
- [ ] Action group (email/SMS)
- [ ] Alert rules (80% and 100% triggers)

**Total Required Screenshots**: 14 (15 with bonus)

## Files to Submit

1. **Policy Definitions** (JSON):
   - ✅ `policy-vm-size-restriction.json` (complete policy definition)
   - ✅ `policy-web-farm-sku.json` (complete policy definition)
   - ✅ `policy-require-tag-with-values.json` (unified tagging policy with parameters)
   - ✅ `policy-deployment-location-note.md` (explains built-in policy usage)

2. **PowerShell Scripts**:
   - ✅ `create-custom-role.ps1` (idempotent, with DataActions for secrets/certificates)

3. **Documentation**:
   - ✅ `policy-tag-assignment-examples.md` (shows how to assign tagging policy twice)
   - ✅ This file: `SCREENSHOTS-REQUIRED.md`

4. **Screenshots**: All screenshots listed above
