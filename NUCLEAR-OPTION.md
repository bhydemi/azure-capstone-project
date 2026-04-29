# NUCLEAR OPTION - Clear ALL Filters

The role assignments exist. The portal is hiding them with filters.

## Do This Exactly:

### For Screenshot 10 (rg-external):

1. Portal → Resource groups → rg-external → Access control (IAM)
2. Click **"Role assignments"** tab
3. Look at the top - you'll see filter chips like:
   - Type : All
   - Role : All  
   - Scope : All scopes
   - Group by : Role
4. **Click the X on EVERY single filter chip to remove ALL filters**
5. Click the **"Refresh"** button (circular arrow icon)
6. **Scroll down in the list** - don't rely on search
7. Look for "external-contributors" with Contributor role

### Alternative Method:

If that doesn't work:

1. On the Role assignments tab
2. In the search box, type: **external-contributors**
3. Wait 2 seconds
4. Hit Enter or click search icon
5. It should appear

### Another Alternative:

1. Click "Download role assignments" button
2. Open the CSV file
3. Search for "external-contributors" in the CSV
4. Take a screenshot of Excel/CSV showing the assignment
5. OR go back to portal and manually look for that exact principal ID

---

## For Screenshot 8 (Subscription):

Same process:
1. Subscriptions → Udacity-20 → Access control (IAM) → Role assignments tab
2. Remove ALL filters (click X on each chip)
3. Click Refresh
4. Search for: **KeyVaultSecretAndCertificateAdmins**
5. Look for Reader role

---

## For Screenshot 9 (Key Vault):

Same process:
1. Key vaults → kv-devshared-20260428-ho → Access control (IAM) → Role assignments tab
2. Remove ALL filters
3. Click Refresh
4. Search for: **KeyVaultSecretAndCertificateAdmins**
5. Look for Key Vault Secrets Officer and Key Vault Certificates Officer

---

## The Real Issue

The Azure portal's filter system is hiding your results. The assignments ARE there (I verified via CLI).

Try this:
1. Remove every single filter chip
2. Click refresh
3. Scroll down manually through the ENTIRE list
4. The groups are there somewhere in the list

If you still see "No results" after removing ALL filters, wait 5 minutes and try again - Azure might still be propagating the role assignments.

