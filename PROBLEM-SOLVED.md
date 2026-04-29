# Problem Solved - Duplicate Groups Removed

## What Was Wrong

You had **duplicate groups** with identical names:
- 2x `KeyVaultSecretAndCertificateAdmins` (created Feb 2 and Mar 11)
- 2x `external-contributors` (created Jan 28 and Mar 11)

BOTH old and new groups had role assignments, causing Azure Portal to not display the group names (DisplayName was empty in the CSV).

## What I Fixed

1. Removed all role assignments from the OLD duplicate groups
2. Kept only the NEW groups (Mar 11) with their assignments
3. Now only ONE version of each group has role assignments

## Current State

**✅ KeyVaultSecretAndCertificateAdmins (a8e89258):**
- Reader on Subscription
- Key Vault Secrets Officer on kv-devshared-20260428-ho
- Key Vault Certificates Officer on kv-devshared-20260428-ho

**✅ external-contributors (8f1a4385):**
- Contributor on rg-external

## Next Steps

1. **Wait 2-3 minutes** for Azure to propagate the changes
2. **Refresh your browser** (Ctrl+F5 or Cmd+Shift+R)
3. Go to the portal IAM pages:

### Screenshot 8: Subscription Reader
- Portal → Subscriptions → Udacity-20 → Access control (IAM)
- Click **"Role assignments"** tab
- Remove all filters (click X on each chip)
- Click Refresh
- Search for "KeyVaultSecretAndCertificateAdmins"
- You should see: **Reader** role with the group name NOW visible
- Save as: `screenshot-08-group-reader-on-subscription.png`

### Screenshot 9: Key Vault Roles
- Portal → Key vaults → kv-devshared-20260428-ho → Access control (IAM)
- Click **"Role assignments"** tab
- Remove all filters
- Click Refresh
- Search for "KeyVaultSecretAndCertificateAdmins"
- You should see TWO rows: **Key Vault Secrets Officer** and **Key Vault Certificates Officer**
- Save as: `screenshot-09-group-vaultmanager-on-keyvault.png`

### Screenshot 10: rg-external Contributor
- Portal → Resource groups → rg-external → Access control (IAM)
- Click **"Role assignments"** tab
- Remove all filters
- Click Refresh
- Search for "external-contributors"
- You should see: **Contributor** role with the group name NOW visible
- Save as: `screenshot-10-external-contributors-on-rg-external.png`

---

## If It Still Doesn't Show

If after 5 minutes the groups still don't appear with names:

1. Download the role assignments CSV again
2. Open it in Excel
3. Filter for the ObjectIds:
   - a8e89258-dc65-40e1-b18f-e69099c06f21 (KeyVault group)
   - 8f1a4385-95a7-4e93-a1a4-bea9ef8927cc (external group)
4. Take screenshots of the Excel rows showing the assignments

The role assignments ARE there and verified via CLI - the portal should catch up soon!
