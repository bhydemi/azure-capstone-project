# Screenshot Renaming Guide

## 📸 You Have 19 Screenshots - Need to Rename 14

Your screenshots are currently named:
- Screenshot 2026-04-28 at XX.XX.XX.png
- Screenshot 2026-04-29 at XX.XX.XX.png

They need to be renamed to match this format:

---

## ✅ Required Screenshot Names

### Section 1: Policy Assignments (5 screenshots)

**1. VM Size Restriction Policy**
- **New name**: `screenshot-01-policy-vm-size-restriction.png`
- **Shows**: Policy assignment for VM size restrictions (B-series)
- **Navigation**: Policy → Assignments → VM size policy

**2. Deployment Location Policy**
- **New name**: `screenshot-02-policy-deployment-location.png`
- **Shows**: "Allowed locations" policy with East US 2, Central US
- **Navigation**: Policy → Assignments → Allowed locations

**3. Department Tag Policy**
- **New name**: `screenshot-03-policy-tag-department.png`
- **Shows**: Tag policy with Department parameter (Finance, Engineering)
- **Navigation**: Policy → Assignments → Department tag → Parameters tab

**4. Environment Tag Policy**
- **New name**: `screenshot-04-policy-tag-environment.png`
- **Shows**: Tag policy with Environment parameter (Dev, Test, Prod)
- **Navigation**: Policy → Assignments → Environment tag → Parameters tab

**5. Web Farm SKU Policy**
- **New name**: `screenshot-05-policy-web-farm-sku.png`
- **Shows**: App Service Plan SKU restriction policy
- **Navigation**: Policy → Assignments → Web farm SKU policy

---

### Section 2: Compliance Initiative (1 screenshot)

**6. CIS Compliance Initiative**
- **New name**: `screenshot-06-cis-compliance.png`
- **Shows**: CIS Microsoft Azure Foundations Benchmark v2.0.0 assignment
- **Navigation**: Policy → Assignments → Filter Type: Initiative → CIS

---

### Section 3: Groups & Role Assignments (5 screenshots)

**7. KeyVault Admin Group**
- **New name**: `screenshot-07-group-keyvault-admins.png`
- **Shows**: KeyVaultSecretAndCertificateAdmins group overview
- **Navigation**: Microsoft Entra ID → Groups → KeyVaultSecretAndCertificateAdmins

**8. Reader Role on Subscription**
- **New name**: `screenshot-08-group-reader-on-subscription.png`
- **Shows**: KeyVaultSecretAndCertificateAdmins with Reader role on subscription
- **Navigation**: Subscriptions → IAM → Role assignments

**9. Vault Role on Key Vault**
- **New name**: `screenshot-09-group-vaultmanager-on-keyvault.png`
- **Shows**: KeyVaultSecretAndCertificateAdmins with Key Vault Secrets Officer on vault
- **Navigation**: Key vaults → kv-devshared-20260428-ho → IAM → Role assignments

**10. Contributor on rg-external**
- **New name**: `screenshot-10-external-contributors-on-rg-external.png`
- **Shows**: external-contributors with Contributor role on rg-external
- **Navigation**: Resource groups → rg-external → IAM → Role assignments

**11. Secrets Access (BONUS)**
- **New name**: `screenshot-11-bonus-admin-can-modify-secrets.png`
- **Shows**: Secrets section in Key Vault kv-devshared-20260428-ho
- **Navigation**: Key vaults → kv-devshared-20260428-ho → Secrets

---

### Section 4: Budget & Alerts (3 screenshots)

**12. Budget Configuration**
- **New name**: `screenshot-12-budget-configuration.png`
- **Shows**: Budget "targetspend" showing $250/month
- **Navigation**: Cost Management + Billing → Budgets → targetspend

**13. Action Group**
- **New name**: `screenshot-13-action-group.png`
- **Shows**: Action group "financeteam" with email financeteam@example.com
- **Navigation**: Monitor → Alerts → Action groups → financeteam

**14. Budget Alerts**
- **New name**: `screenshot-14-alert-rules.png`
- **Shows**: Budget alert conditions (80% and 100% with financeteam)
- **Navigation**: Cost Management + Billing → Budgets → targetspend → Alert conditions

---

## 🔧 How to Rename

### Option 1: Manual Rename (macOS)

1. Open Finder
2. Navigate to: `/Users/abdulhakeemoyaqoob/Downloads/starter (7)`
3. For each screenshot:
   - **Open it** to see what it shows
   - **Right-click** → Rename
   - **Enter the new name** from the list above

### Option 2: Create Missing Screenshots

If you don't have all 14, capture the missing ones:

1. Go to Azure Portal
2. Navigate to each location (see above)
3. **Save screenshot with correct name** (Cmd+Shift+4, then space, click window)
4. **Before saving**, change name to correct format

---

## ✅ Quick Checklist

After renaming, you should have exactly these 14 files:

- [ ] screenshot-01-policy-vm-size-restriction.png
- [ ] screenshot-02-policy-deployment-location.png
- [ ] screenshot-03-policy-tag-department.png
- [ ] screenshot-04-policy-tag-environment.png
- [ ] screenshot-05-policy-web-farm-sku.png
- [ ] screenshot-06-cis-compliance.png
- [ ] screenshot-07-group-keyvault-admins.png
- [ ] screenshot-08-group-reader-on-subscription.png
- [ ] screenshot-09-group-vaultmanager-on-keyvault.png
- [ ] screenshot-10-external-contributors-on-rg-external.png
- [ ] screenshot-11-bonus-admin-can-modify-secrets.png
- [ ] screenshot-12-budget-configuration.png
- [ ] screenshot-13-action-group.png
- [ ] screenshot-14-alert-rules.png

---

## 💡 Tips

1. **Open each screenshot** to identify what it shows
2. **Match it** to the descriptions above
3. **Rename it** to the correct format
4. **Delete duplicates** - you only need 14 screenshots total
5. **Keep the old names** as backup until you're sure they're all correct

---

**Once renamed, your project is complete and ready to submit!** 🚀
