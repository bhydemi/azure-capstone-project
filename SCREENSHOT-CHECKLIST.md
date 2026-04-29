# Screenshot Capture Checklist

Use this checklist to track your progress capturing all 14 required screenshots.

## Before You Start

- [ ] Run `./deploy-everything-for-screenshots.ps1` to deploy all resources
- [ ] Login to Azure Portal: https://portal.azure.com
- [ ] Verify all resources exist using the verification commands

---

## Section 1: Policy Assignments (5 Screenshots)

- [ ] **Screenshot 1:** VM Size Restriction Policy Assignment
  - File: `screenshot-01-policy-vm-size-restriction.png`
  - Location: Policy → Assignments → "Restrict Virtual Machine SKU Sizes"

- [ ] **Screenshot 2:** Deployment Location Policy Assignment (Built-in)
  - File: `screenshot-02-policy-deployment-location.png`
  - Location: Policy → Assignments → "Allowed locations"
  - Must show parameters: East US 2, Central US

- [ ] **Screenshot 3:** Department Tag Policy Assignment
  - File: `screenshot-03-policy-tag-department.png`
  - Location: Policy → Assignments → Tag policy (Department)
  - Must show parameters: tagName="Department", allowedTagValues=["Finance", "Engineering"]

- [ ] **Screenshot 4:** Environment Tag Policy Assignment
  - File: `screenshot-04-policy-tag-environment.png`
  - Location: Policy → Assignments → Tag policy (Environment)
  - Must show parameters: tagName="Environment", allowedTagValues=["Dev", "Test", "Prod"]

- [ ] **Screenshot 5:** Web Farm SKU Restriction Policy Assignment
  - File: `screenshot-05-policy-web-farm-sku.png`
  - Location: Policy → Assignments → "Restrict App Service Plan SKU Sizes"

**Section 1 Status:** _____ / 5 complete

---

## Section 2: PCI Compliance Initiative (1 Screenshot)

- [ ] **Screenshot 6:** PCI DSS v4 Initiative Assignment
  - File: `screenshot-06-pci-compliance.png`
  - Location: Policy → Assignments → "PCI DSS v4.0"
  - Must show initiative name and number of policies

**Section 2 Status:** _____ / 1 complete

---

## Section 3: Groups and Role Assignments (5 Screenshots)

- [ ] **Screenshot 7:** KeyVaultSecretAndCertificateAdmins Group
  - File: `screenshot-07-group-keyvault-admins.png`
  - Location: Microsoft Entra ID → Groups → KeyVaultSecretAndCertificateAdmins
  - Must show group name, type, description

- [ ] **Screenshot 8:** Group Has Reader Role on Subscription
  - File: `screenshot-08-group-reader-on-subscription.png`
  - Location: Subscriptions → Your Subscription → IAM → Role assignments
  - Must show KeyVaultSecretAndCertificateAdmins with Reader role

- [ ] **Screenshot 9:** Group Has VaultSecretCertificateManager Role on Key Vault
  - File: `screenshot-09-group-vaultmanager-on-keyvault.png`
  - Location: Key vaults → kv-devshared-* → IAM → Role assignments
  - Must show KeyVaultSecretAndCertificateAdmins with VaultSecretCertificateManager role

- [ ] **Screenshot 10:** External Contributors Group with Contributor Role
  - File: `screenshot-10-external-contributors-on-rg-external.png`
  - Location: Resource groups → rg-external → IAM → Role assignments
  - Must show external-contributors with Contributor role

- [ ] **Screenshot 11:** BONUS - Admin Can Modify Secrets
  - File: `screenshot-11-bonus-admin-can-modify-secrets.png`
  - Location: Key vaults → kv-devshared-* → Secrets
  - Must show ability to create/view secrets

**Section 3 Status:** _____ / 5 complete

---

## Section 4: Budget and Alerts (3 Screenshots)

- [ ] **Screenshot 12:** Budget Configuration
  - File: `screenshot-12-budget-configuration.png`
  - Location: Cost Management + Billing → Budgets → targetspend
  - Must show: Name, Amount ($250), Monthly period, Alerts

- [ ] **Screenshot 13:** Action Group Configuration
  - File: `screenshot-13-action-group.png`
  - Location: Monitor → Alerts → Action groups → financeteam
  - Must show: Name, Email notification (financeteam@example.com)

- [ ] **Screenshot 14:** Alert Rules (Budget Thresholds)
  - File: `screenshot-14-alert-rules.png`
  - Location: Cost Management + Billing → Budgets → targetspend → Alert conditions
  - Must show: 80% alert, 100% alert, both linked to financeteam action group

**Section 4 Status:** _____ / 3 complete

---

## Overall Progress

**Total Screenshots Captured:** _____ / 14

---

## After Capturing Screenshots

- [ ] Verify all file names match exactly as specified
- [ ] Verify all screenshots are clear and readable
- [ ] Verify all required information is visible in each screenshot
- [ ] Organize screenshots into a folder for submission
- [ ] Review REVIEWER-FEEDBACK-RESOLUTION.md to ensure all issues addressed

---

## Files to Submit

### Policy Definitions (JSON Files)
- [ ] `policy-vm-size-restriction.json`
- [ ] `policy-web-farm-sku.json`
- [ ] `policy-require-tag-with-values.json`

### PowerShell Scripts
- [ ] `create-custom-role.ps1`
- [ ] `deploy-keyvault.ps1`
- [ ] `audit-script.ps1`

### Screenshots
- [ ] All 14 screenshots (see above)

### Documentation
- [ ] `README.md`
- [ ] `REVIEWER-FEEDBACK-RESOLUTION.md`
- [ ] `SCREENSHOT-CAPTURE-GUIDE.md`
- [ ] Supporting documentation files

---

## Quick Reference: Portal URLs

After logging in, use these direct navigation paths:

**Policies:** Home → Search "Policy" → Policy
**Entra ID:** Home → Search "Microsoft Entra ID" → Microsoft Entra ID
**Resource Groups:** Home → Search "Resource groups" → Resource groups
**Key Vaults:** Home → Search "Key vaults" → Key vaults
**Subscriptions:** Home → Search "Subscriptions" → Subscriptions
**Cost Management:** Home → Search "Cost Management" → Cost Management + Billing
**Monitor:** Home → Search "Monitor" → Monitor

---

## Need Help?

If something is missing:
1. Check if resource exists using verification commands
2. Re-run `./deploy-everything-for-screenshots.ps1`
3. Refer to `SCREENSHOT-CAPTURE-GUIDE.md` for detailed instructions
4. Use PowerShell commands in the guide to create missing resources

---

**Remember:** Screenshots must clearly show:
- Resource names
- Scope/location
- Role/permission details
- Configuration parameters
- Status (Enabled/Active)

**Good luck!** 🚀
