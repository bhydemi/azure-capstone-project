# How to Fix "No Results" - Change the Scope Filter!

All role assignments exist. The problem is the **Scope filter**.

## The Fix (applies to ALL 3 screenshots)

When you're on the "Role assignments" tab and see "No results":

1. Look at the filter chips near the top
2. Click on **"Scope : All scopes"**
3. Select **"This resource"** instead
4. The groups will appear!

---

## Screenshot 8: Subscription Reader

**Path:**
1. Portal → Subscriptions → Udacity-20 → Access control (IAM)
2. Click **"Role assignments"** tab
3. **Click "Scope : All scopes" → Change to "This resource"**
4. Search for "KeyVaultSecretAndCertificateAdmins"
5. You'll see: Reader role

**Save as:** `screenshot-08-group-reader-on-subscription.png`

---

## Screenshot 9: Key Vault Roles

**Path:**
1. Portal → Key vaults → kv-devshared-20260428-ho → Access control (IAM)
2. Click **"Role assignments"** tab
3. **Click "Scope : All scopes" → Change to "This resource"**
4. Search for "KeyVaultSecretAndCertificateAdmins"
5. You'll see TWO rows:
   - Key Vault Secrets Officer
   - Key Vault Certificates Officer

**Save as:** `screenshot-09-group-vaultmanager-on-keyvault.png`

---

## Screenshot 10: rg-external Contributor

**Path:**
1. Portal → Resource groups → rg-external → Access control (IAM)
2. Click **"Role assignments"** tab
3. **Click "Scope : All scopes" → Change to "This resource"**
4. Search for "external-contributors"
5. You'll see: Contributor role

**Save as:** `screenshot-10-external-contributors-on-rg-external.png`

---

## Summary

The magic fix: **Change Scope filter from "All scopes" to "This resource"**

All 3 role assignments are confirmed to exist. Just fix the filter and they'll show up!
