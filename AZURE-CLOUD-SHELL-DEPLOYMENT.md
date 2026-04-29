# Azure Cloud Shell Deployment Guide

Follow these steps to deploy all resources using Azure Cloud Shell.

---

## Step 1: Open Azure Cloud Shell

1. **Navigate to Azure Portal:**
   - URL: https://portal.azure.com

2. **Login with your credentials:**
   - Username: `student_7pmnzenmmmm8k04w_005061913@vocareumvocareum.onmicrosoft.com`
   - Password: `X#ts$L%W4BUrdo$wOZWK$rkBrHTPo&`

3. **Open Cloud Shell:**
   - Click the **Cloud Shell icon (>_)** in the top-right corner of the portal
   - If prompted to choose a shell, select **PowerShell**
   - If this is your first time, you may need to create a storage account (just click "Create storage")

---

## Step 2: Upload Required Files

In Cloud Shell, click the **Upload/Download files** icon (folder with arrow) and upload these files:

### Required Scripts:
- ✅ `deploy-everything-for-screenshots.ps1`
- ✅ `create-custom-role.ps1`
- ✅ `deploy-keyvault.ps1`

### Required Policy Files:
- ✅ `policy-vm-size-restriction.json`
- ✅ `policy-web-farm-sku.json`
- ✅ `policy-require-tag-with-values.json`

**Tip:** You can upload all files at once by selecting them together.

---

## Step 3: Verify Files Uploaded

In Cloud Shell, run:

```powershell
# List files to verify upload
ls -la

# Should see all 6 files listed above
```

---

## Step 4: Run the Deployment Script

```powershell
# Run the deployment script
./deploy-everything-for-screenshots.ps1
```

The script will:
- ✅ Create all custom policy definitions
- ✅ Assign all policies to your subscription
- ✅ Assign PCI DSS v4 initiative
- ✅ Create all resource groups with locks
- ✅ Create the custom Key Vault role
- ✅ Deploy the Key Vault
- ✅ Create managed identity
- ✅ Create security groups
- ✅ Assign all RBAC roles

**Expected Duration:** 5-10 minutes

---

## Step 5: Monitor Deployment Progress

You'll see colored output showing progress:
- **Cyan:** Section headers
- **Yellow:** Actions in progress
- **Green:** Successful completions
- **Red:** Errors (if any)

The script is **idempotent** - if something fails, you can re-run it safely.

---

## Step 6: Review Deployment Summary

At the end, you'll see:
```
============================================================================
DEPLOYMENT COMPLETE!
============================================================================
```

Plus verification commands to check your deployment.

---

## Step 7: Verify Deployment

Run these commands in Cloud Shell to verify everything deployed:

```powershell
# Check policy assignments
Get-AzPolicyAssignment | Select-Object Name, DisplayName | Format-Table

# Check custom role
Get-AzRoleDefinition -Name 'VaultSecretCertificateManager'

# Check groups
Get-AzADGroup | Where-Object {$_.DisplayName -like '*KeyVault*' -or $_.DisplayName -like '*external*'}

# Check resource groups
Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -like 'rg-*'}

# Check key vault
Get-AzKeyVault | Where-Object {$_.VaultName -like 'kv-devshared-*'}
```

---

## Troubleshooting

### Issue: "File not found" error
**Solution:** Make sure you uploaded all 6 files and you're in the directory where they were uploaded. Try:
```powershell
cd ~
ls -la
```

### Issue: "Permission denied" error
**Solution:** Make the script executable:
```powershell
chmod +x deploy-everything-for-screenshots.ps1
./deploy-everything-for-screenshots.ps1
```

### Issue: Script says resource already exists
**Solution:** This is normal! The script is idempotent. It will skip existing resources and continue.

### Issue: Policy assignment fails
**Solution:** Wait a few seconds and re-run the script. Sometimes policy definitions need a moment to propagate.

---

## After Deployment Completes

✅ **Next Steps:**

1. **Create Budget & Action Group** - Follow `BUDGET-AND-ALERTS-SETUP.md`
2. **Capture Screenshots** - Follow `SCREENSHOT-CAPTURE-GUIDE.md`
3. **Use Checklist** - Track progress with `SCREENSHOT-CHECKLIST.md`

---

## Alternative: Manual Deployment

If you prefer to run commands manually instead of using the script, see `SCREENSHOT-CAPTURE-GUIDE.md` for individual PowerShell commands for each resource.

---

## Files Location in Cloud Shell

Files uploaded to Cloud Shell are stored in your home directory:
```
/home/<username>/
├── deploy-everything-for-screenshots.ps1
├── create-custom-role.ps1
├── deploy-keyvault.ps1
├── policy-vm-size-restriction.json
├── policy-web-farm-sku.json
└── policy-require-tag-with-values.json
```

---

## Quick Reference

**Portal URL:** https://portal.azure.com

**Login:**
- User: `student_7pmnzenmmmm8k04w_005061913@vocareumvocareum.onmicrosoft.com`
- Pass: `X#ts$L%W4BUrdo$wOZWK$rkBrHTPo&`

**Deploy Command:**
```powershell
./deploy-everything-for-screenshots.ps1
```

**Verify Command:**
```powershell
Get-AzPolicyAssignment | Select-Object Name, DisplayName | Format-Table
Get-AzResourceGroup | Select-Object ResourceGroupName, Location, Tags | Format-Table
```

---

**Good luck with your deployment!** 🚀

Once deployment completes, proceed to capture screenshots following the `SCREENSHOT-CAPTURE-GUIDE.md`.
