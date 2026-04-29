# Quick CLI Commands - Copy and Paste These

Since you're already in Azure Cloud Shell, here are the exact commands to run:

## First, check what files you have:
```bash
ls -la
```

You should see:
- policy-vm-size-restriction.json
- policy-web-farm-sku.json
- policy-require-tag-with-values.json
- create-custom-role.ps1
- deploy-with-cli.sh

## Option 1: Run the bash script (EASIEST)
```bash
chmod +x deploy-with-cli.sh
./deploy-with-cli.sh
```

## Option 2: Run commands manually

If the script doesn't work, copy and paste these commands one by one:

### Get your subscription ID:
```bash
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "Subscription ID: $SUBSCRIPTION_ID"
```

### 1. VM Size Policy:
```bash
# Create definition
az policy definition create \
    --name 'restrict-vm-sizes' \
    --display-name 'Restrict Virtual Machine SKU Sizes' \
    --rules 'policy-vm-size-restriction.json' \
    --mode 'Indexed'

# Assign policy
az policy assignment create \
    --name 'vm-size-restriction' \
    --display-name 'Restrict Virtual Machine SKU Sizes' \
    --scope "/subscriptions/$SUBSCRIPTION_ID" \
    --policy 'restrict-vm-sizes'
```

### 2. Web Farm SKU Policy:
```bash
# Create definition
az policy definition create \
    --name 'restrict-web-farm-skus' \
    --display-name 'Restrict App Service Plan SKU Sizes' \
    --rules 'policy-web-farm-sku.json' \
    --mode 'Indexed'

# Assign policy
az policy assignment create \
    --name 'web-farm-sku-restriction' \
    --display-name 'Restrict App Service Plan SKU Sizes' \
    --scope "/subscriptions/$SUBSCRIPTION_ID" \
    --policy 'restrict-web-farm-skus'
```

### 3. Tagging Policy:
```bash
# Create definition
az policy definition create \
    --name 'require-tag-with-values' \
    --display-name 'Require tag with allowed values on resources' \
    --rules 'policy-require-tag-with-values.json' \
    --mode 'Indexed'

# Assign for Department tag
az policy assignment create \
    --name 'require-department-tag' \
    --display-name 'Require Department Tag' \
    --scope "/subscriptions/$SUBSCRIPTION_ID" \
    --policy 'require-tag-with-values' \
    --params '{"tagName":{"value":"Department"},"allowedTagValues":{"value":["Finance","Engineering"]}}'

# Assign for Environment tag
az policy assignment create \
    --name 'require-environment-tag' \
    --display-name 'Require Environment Tag' \
    --scope "/subscriptions/$SUBSCRIPTION_ID" \
    --policy 'require-tag-with-values' \
    --params '{"tagName":{"value":"Environment"},"allowedTagValues":{"value":["Dev","Test","Prod"]}}'
```

### 4. Location Policy (Built-in):
```bash
# Find the built-in policy
LOCATION_POLICY_ID=$(az policy definition list --query "[?displayName=='Allowed locations'].id" -o tsv)
echo "Policy ID: $LOCATION_POLICY_ID"

# Assign it
az policy assignment create \
    --name 'allowed-locations' \
    --display-name 'Restrict to East US 2 and Central US' \
    --scope "/subscriptions/$SUBSCRIPTION_ID" \
    --policy "$LOCATION_POLICY_ID" \
    --params '{"listOfAllowedLocations":{"value":["eastus2","centralus"]}}'
```

### 5. Verify deployments:
```bash
# List all policy assignments
az policy assignment list --query "[].{Name:name, DisplayName:displayName}" -o table

# List custom policies
az policy definition list --query "[?policyType=='Custom'].{Name:name, DisplayName:displayName}" -o table
```

### 6. Create Custom Role (switch to PowerShell):
```bash
# Switch to PowerShell mode in Cloud Shell
pwsh

# Then run:
./create-custom-role.ps1
```

## Troubleshooting

### If you get "files not found":
```bash
# Check current directory
pwd

# List files
ls -la

# If files are missing, you need to upload them again
```

### If policy already exists:
```bash
# Delete and recreate
az policy assignment delete --name 'vm-size-restriction'
az policy definition delete --name 'restrict-vm-sizes'

# Then run the create commands again
```

### To delete everything and start over:
```bash
# Delete all assignments
az policy assignment delete --name 'vm-size-restriction'
az policy assignment delete --name 'web-farm-sku-restriction'
az policy assignment delete --name 'require-department-tag'
az policy assignment delete --name 'require-environment-tag'
az policy assignment delete --name 'allowed-locations'

# Delete custom definitions
az policy definition delete --name 'restrict-vm-sizes'
az policy definition delete --name 'restrict-web-farm-skus'
az policy definition delete --name 'require-tag-with-values'
```
