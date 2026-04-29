#!/bin/bash
# PASTE THIS ENTIRE SCRIPT INTO YOUR AZURE CLOUD SHELL
# You're already logged in there, so this will work immediately

set -e  # Exit on error

echo "=== Azure Capstone Deployment ==="
echo ""

# Get subscription ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
SUBSCRIPTION_NAME=$(az account show --query name -o tsv)

echo "Deploying to: $SUBSCRIPTION_NAME"
echo "Subscription ID: $SUBSCRIPTION_ID"
echo ""

cd ~  # Go to home directory where you uploaded files

# ============================================================================
echo "[1/7] Creating VM Size Restriction Policy..."
# ============================================================================

cat > /tmp/vm-policy.json << 'EOF'
{
  "if": {
    "allOf": [
      {
        "field": "type",
        "equals": "Microsoft.Compute/virtualMachines"
      },
      {
        "not": {
          "field": "Microsoft.Compute/virtualMachines/sku.name",
          "in": [
            "Standard_B1ls",
            "Standard_B1s",
            "Standard_B1ms",
            "Standard_B2s",
            "Standard_B2ms",
            "Standard_B2mts",
            "Standard_B4ms",
            "Standard_B8ms"
          ]
        }
      }
    ]
  },
  "then": {
    "effect": "deny"
  }
}
EOF

az policy definition create \
    --name 'restrict-vm-sizes' \
    --display-name 'Restrict Virtual Machine SKU Sizes' \
    --description 'Restricts VM SKU sizes to approved B-series only' \
    --rules /tmp/vm-policy.json \
    --mode 'Indexed' >/dev/null 2>&1 || echo "  (Policy definition may already exist)"

az policy assignment create \
    --name 'vm-size-restriction' \
    --display-name 'Restrict Virtual Machine SKU Sizes' \
    --scope "/subscriptions/$SUBSCRIPTION_ID" \
    --policy 'restrict-vm-sizes' >/dev/null 2>&1 || echo "  (Assignment may already exist)"

echo "✓ VM Size Policy deployed"

# ============================================================================
echo "[2/7] Creating Web Farm SKU Restriction Policy..."
# ============================================================================

cat > /tmp/web-policy.json << 'EOF'
{
  "if": {
    "allOf": [
      {
        "field": "type",
        "equals": "Microsoft.Web/serverfarms"
      },
      {
        "not": {
          "field": "Microsoft.Web/serverfarms/sku.name",
          "in": [
            "B1",
            "P0v3"
          ]
        }
      }
    ]
  },
  "then": {
    "effect": "deny"
  }
}
EOF

az policy definition create \
    --name 'restrict-web-farm-skus' \
    --display-name 'Restrict App Service Plan SKU Sizes' \
    --description 'Restricts App Service Plan SKU sizes to B1 and P0v3 only' \
    --rules /tmp/web-policy.json \
    --mode 'Indexed' >/dev/null 2>&1 || echo "  (Policy definition may already exist)"

az policy assignment create \
    --name 'web-farm-sku-restriction' \
    --display-name 'Restrict App Service Plan SKU Sizes' \
    --scope "/subscriptions/$SUBSCRIPTION_ID" \
    --policy 'restrict-web-farm-skus' >/dev/null 2>&1 || echo "  (Assignment may already exist)"

echo "✓ Web Farm SKU Policy deployed"

# ============================================================================
echo "[3/7] Creating Unified Tagging Policy..."
# ============================================================================

cat > /tmp/tag-policy.json << 'EOF'
{
  "if": {
    "anyOf": [
      {
        "field": "[concat('tags[', parameters('tagName'), ']')]",
        "exists": "false"
      },
      {
        "field": "[concat('tags[', parameters('tagName'), ']')]",
        "notIn": "[parameters('allowedTagValues')]"
      }
    ]
  },
  "then": {
    "effect": "deny"
  }
}
EOF

cat > /tmp/tag-params.json << 'EOF'
{
  "tagName": {
    "type": "String",
    "metadata": {
      "displayName": "Tag Name",
      "description": "Name of the tag to enforce"
    }
  },
  "allowedTagValues": {
    "type": "Array",
    "metadata": {
      "displayName": "Allowed Tag Values",
      "description": "List of allowed values for the tag"
    }
  }
}
EOF

az policy definition create \
    --name 'require-tag-with-values' \
    --display-name 'Require tag with allowed values on resources' \
    --description 'Enforces that a specified tag exists with allowed values' \
    --rules /tmp/tag-policy.json \
    --params /tmp/tag-params.json \
    --mode 'Indexed' >/dev/null 2>&1 || echo "  (Policy definition may already exist)"

echo "✓ Tagging Policy created"

# ============================================================================
echo "[4/7] Assigning Department Tag Policy..."
# ============================================================================

az policy assignment create \
    --name 'require-department-tag' \
    --display-name 'Require Department Tag' \
    --scope "/subscriptions/$SUBSCRIPTION_ID" \
    --policy 'require-tag-with-values' \
    --params '{"tagName":{"value":"Department"},"allowedTagValues":{"value":["Finance","Engineering"]}}' \
    >/dev/null 2>&1 || echo "  (Assignment may already exist)"

echo "✓ Department Tag Policy assigned (Finance, Engineering)"

# ============================================================================
echo "[5/7] Assigning Environment Tag Policy..."
# ============================================================================

az policy assignment create \
    --name 'require-environment-tag' \
    --display-name 'Require Environment Tag' \
    --scope "/subscriptions/$SUBSCRIPTION_ID" \
    --policy 'require-tag-with-values' \
    --params '{"tagName":{"value":"Environment"},"allowedTagValues":{"value":["Dev","Test","Prod"]}}' \
    >/dev/null 2>&1 || echo "  (Assignment may already exist)"

echo "✓ Environment Tag Policy assigned (Dev, Test, Prod)"

# ============================================================================
echo "[6/7] Assigning Built-in Location Policy..."
# ============================================================================

LOCATION_POLICY_ID=$(az policy definition list --query "[?displayName=='Allowed locations'].id" -o tsv | head -1)

if [ -n "$LOCATION_POLICY_ID" ]; then
    az policy assignment create \
        --name 'allowed-locations' \
        --display-name 'Restrict to East US 2 and Central US' \
        --scope "/subscriptions/$SUBSCRIPTION_ID" \
        --policy "$LOCATION_POLICY_ID" \
        --params '{"listOfAllowedLocations":{"value":["eastus2","centralus"]}}' \
        >/dev/null 2>&1 || echo "  (Assignment may already exist)"
    echo "✓ Location Policy assigned (East US 2, Central US)"
else
    echo "✗ Built-in location policy not found"
fi

# ============================================================================
echo "[7/7] Creating Custom Role..."
# ============================================================================

cat > /tmp/custom-role.json << EOF
{
  "Name": "VaultSecretCertificateManager",
  "IsCustom": true,
  "Description": "Allows users to manage Key Vault secrets and certificates",
  "Actions": [
    "Microsoft.KeyVault/vaults/read"
  ],
  "NotActions": [],
  "DataActions": [
    "Microsoft.KeyVault/vaults/secrets/getSecret/action",
    "Microsoft.KeyVault/vaults/secrets/setSecret/action",
    "Microsoft.KeyVault/vaults/secrets/delete",
    "Microsoft.KeyVault/vaults/secrets/backup/action",
    "Microsoft.KeyVault/vaults/secrets/restore/action",
    "Microsoft.KeyVault/vaults/secrets/readMetadata/action",
    "Microsoft.KeyVault/vaults/certificates/read",
    "Microsoft.KeyVault/vaults/certificates/write",
    "Microsoft.KeyVault/vaults/certificates/delete",
    "Microsoft.KeyVault/vaults/certificates/backup/action",
    "Microsoft.KeyVault/vaults/certificates/restore/action",
    "Microsoft.KeyVault/vaults/certificates/managecontacts/action",
    "Microsoft.KeyVault/vaults/certificates/manageissuers/action"
  ],
  "NotDataActions": [],
  "AssignableScopes": [
    "/subscriptions/$SUBSCRIPTION_ID"
  ]
}
EOF

az role definition create --role-definition /tmp/custom-role.json >/dev/null 2>&1 || echo "  (Role may already exist)"

echo "✓ Custom Role created (VaultSecretCertificateManager)"

# ============================================================================
echo ""
echo "=== Deployment Summary ==="
# ============================================================================

echo ""
echo "Policy Assignments:"
az policy assignment list --query "[?contains(name, 'restrict') || contains(name, 'require') || contains(name, 'allowed')].{Name:name, DisplayName:displayName}" -o table

echo ""
echo "Custom Policies:"
az policy definition list --query "[?policyType=='Custom'].{Name:name, DisplayName:displayName}" -o table

echo ""
echo "Custom Roles:"
az role definition list --custom-role-only true --query "[?roleName=='VaultSecretCertificateManager'].{Name:roleName, Description:description}" -o table

echo ""
echo "============================================================"
echo "✓✓✓ ALL POLICIES AND ROLE DEPLOYED! ✓✓✓"
echo "============================================================"
echo ""
echo "Next Steps:"
echo "1. Assign PCI DSS v4 initiative (Azure Portal > Policy > Definitions)"
echo "2. Capture 14 required screenshots (see SCREENSHOTS-REQUIRED.md)"
echo ""
