#!/bin/bash
# One-command deployment - copies everything inline

SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "Deploying to subscription: $SUBSCRIPTION_ID"
echo ""

# 1. VM Size Policy
echo "[1/5] VM Size Policy..."
az policy definition create --name 'restrict-vm-sizes' --display-name 'Restrict Virtual Machine SKU Sizes' --rules 'policy-vm-size-restriction.json' --mode 'Indexed' 2>&1 | grep -v "already exists" || true
az policy assignment create --name 'vm-size-restriction' --display-name 'Restrict Virtual Machine SKU Sizes' --scope "/subscriptions/$SUBSCRIPTION_ID" --policy 'restrict-vm-sizes' 2>&1 | grep -v "already exists" || true
echo "✓ Done"

# 2. Web Farm Policy
echo "[2/5] Web Farm SKU Policy..."
az policy definition create --name 'restrict-web-farm-skus' --display-name 'Restrict App Service Plan SKU Sizes' --rules 'policy-web-farm-sku.json' --mode 'Indexed' 2>&1 | grep -v "already exists" || true
az policy assignment create --name 'web-farm-sku-restriction' --display-name 'Restrict App Service Plan SKU Sizes' --scope "/subscriptions/$SUBSCRIPTION_ID" --policy 'restrict-web-farm-skus' 2>&1 | grep -v "already exists" || true
echo "✓ Done"

# 3. Tagging Policy
echo "[3/5] Tagging Policy..."
az policy definition create --name 'require-tag-with-values' --display-name 'Require tag with allowed values on resources' --rules 'policy-require-tag-with-values.json' --mode 'Indexed' 2>&1 | grep -v "already exists" || true
az policy assignment create --name 'require-department-tag' --display-name 'Require Department Tag' --scope "/subscriptions/$SUBSCRIPTION_ID" --policy 'require-tag-with-values' --params '{"tagName":{"value":"Department"},"allowedTagValues":{"value":["Finance","Engineering"]}}' 2>&1 | grep -v "already exists" || true
az policy assignment create --name 'require-environment-tag' --display-name 'Require Environment Tag' --scope "/subscriptions/$SUBSCRIPTION_ID" --policy 'require-tag-with-values' --params '{"tagName":{"value":"Environment"},"allowedTagValues":{"value":["Dev","Test","Prod"]}}' 2>&1 | grep -v "already exists" || true
echo "✓ Done"

# 4. Location Policy
echo "[4/5] Location Policy..."
LOCATION_POLICY_ID=$(az policy definition list --query "[?displayName=='Allowed locations'].id" -o tsv | head -1)
az policy assignment create --name 'allowed-locations' --display-name 'Restrict to East US 2 and Central US' --scope "/subscriptions/$SUBSCRIPTION_ID" --policy "$LOCATION_POLICY_ID" --params '{"listOfAllowedLocations":{"value":["eastus2","centralus"]}}' 2>&1 | grep -v "already exists" || true
echo "✓ Done"

# 5. Summary
echo "[5/5] Summary..."
echo ""
az policy assignment list --query "[].{Name:name, DisplayName:displayName}" -o table

echo ""
echo "✓ All policies deployed!"
echo "Next: Switch to PowerShell and run ./create-custom-role.ps1"
