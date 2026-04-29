# YOU ARE CLICKING THE WRONG TAB!

## The Problem
You keep clicking "Check access" - that shows YOUR permissions.
You need "Role assignments" - that shows GROUP permissions.

## The Solution

When you open Access control (IAM), you see these tabs:

```
┌──────────────┬────────────────────┬────────┬───────────────────┐
│ Check access │ Role assignments  │ Roles  │ Deny assignments  │
└──────────────┴────────────────────┴────────┴───────────────────┘
     ❌ WRONG          ✅ CLICK HERE
```

## Step-by-Step for Screenshot 8 (Subscription Reader)

1. Portal → Subscriptions → Udacity-20
2. Left menu → Access control (IAM)
3. **CLICK THE SECOND TAB: "Role assignments"**
4. You'll see a table with columns: Name, Type, Role, Scope
5. Look for KeyVaultSecretAndCertificateAdmins with Reader role
6. Screenshot that!

## Step-by-Step for Screenshot 9 (Key Vault)

1. Portal → Key vaults → kv-devshared-20260428-ho
2. Left menu → Access control (IAM)
3. **CLICK THE SECOND TAB: "Role assignments"**
4. Look for KeyVaultSecretAndCertificateAdmins
5. You'll see TWO rows (Secrets Officer + Certificates Officer)
6. Screenshot both rows!

## Step-by-Step for Screenshot 10 (rg-external)

1. Portal → Resource groups → rg-external
2. Left menu → Access control (IAM)
3. **CLICK THE SECOND TAB: "Role assignments"**
4. Look for external-contributors with Contributor role
5. Screenshot that!

---

# THE TABS LOOK LIKE THIS:

When you're on Access control (IAM), you see:

- **Check access** ← Shows YOUR personal permissions (WRONG!)
- **Role assignments** ← Shows ALL role assignments including groups (CORRECT!)
- **Roles** ← List of available roles
- **Deny assignments** ← Denied permissions

YOU MUST CLICK "Role assignments" (the 2nd tab)!

