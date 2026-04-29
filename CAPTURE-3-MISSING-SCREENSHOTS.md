# Capture the 3 Missing Role Assignment Screenshots

You need 3 more screenshots. I just created all the role assignments, so they should show up now.

## Screenshot 8: Reader Role on Subscription

**Path:**
1. Azure Portal → Search "Subscriptions" → Click "Subscriptions"
2. Click on "Udacity-20"
3. Left menu → Click "Access control (IAM)"
4. Click the "Role assignments" tab (NOT "Check access")
5. In the "Role" filter dropdown, select "Reader"
6. You should see: KeyVaultSecretAndCertificateAdmins with Reader role

**What to capture:**
- The row showing KeyVaultSecretAndCertificateAdmins
- Role: Reader
- Type: Group
- Scope: Subscription

**Save as:** `screenshot-08-group-reader-on-subscription.png`

---

## Screenshot 9: Key Vault Roles on Key Vault

**Path:**
1. Azure Portal → Search "Key vaults" → Click "Key vaults"
2. Click on "kv-devshared-20260428-ho"
3. Left menu → Click "Access control (IAM)"
4. Click the "Role assignments" tab (NOT "Check access")
5. Search for "KeyVaultSecretAndCertificateAdmins" OR scroll down
6. You should see TWO rows:
   - Key Vault Secrets Officer
   - Key Vault Certificates Officer

**What to capture:**
- Both rows showing KeyVaultSecretAndCertificateAdmins
- Roles: Key Vault Secrets Officer AND Key Vault Certificates Officer
- Type: Group
- Scope: Key vault resource

**Save as:** `screenshot-09-group-vaultmanager-on-keyvault.png`

---

## Screenshot 10: Contributor Role on rg-external

**Path:**
1. Azure Portal → Search "Resource groups" → Click "Resource groups"
2. Click on "rg-external"
3. Left menu → Click "Access control (IAM)"
4. Click the "Role assignments" tab (NOT "Check access")
5. **IMPORTANT:** Clear any filters by clicking the X on filter chips
6. Search for "external-contributors" OR scroll down
7. You should see: external-contributors with Contributor role

**What to capture:**
- The row showing external-contributors
- Role: Contributor
- Type: Group
- Scope: rg-external

**Save as:** `screenshot-10-external-contributors-on-rg-external.png`

---

## Important Notes

- Make sure you're on the **"Role assignments" tab**, NOT "Check access"
- Clear all filters if you don't see results
- Wait a minute and refresh if the roles don't appear immediately
- The roles were just created, so they should be visible now

## After Capturing

Just save the 3 screenshots with the exact names above in the project directory, and you're done with all 14 screenshots!
