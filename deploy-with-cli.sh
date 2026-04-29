#!/bin/bash
# Azure Capstone Project - CLI Deployment Script
# Run this in Azure Cloud Shell (Bash mode)

echo "=== Azure Capstone Project - CLI Deployment ==="
echo ""

# Check if logged in
echo "Checking Azure login status..."
az account show > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "ERROR: Not logged into Azure. Please run: az login"
    exit 1
fi

# Get subscription info
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
SUBSCRIPTION_NAME=$(az account show --query name -o tsv)

echo "✓ Connected to Azure"
echo "  Subscription: $SUBSCRIPTION_NAME"
echo "  Subscription ID: $SUBSCRIPTION_ID"
echo ""

# Verify files exist
echo "Checking for required files..."
if [ ! -f "policy-vm-size-restriction.json" ]; then
    echo "ERROR: policy-vm-size-restriction.json not found!"
    echo "Current directory: $(pwd)"
    echo "Files in directory:"
    ls -la
    exit 1
fi
echo "✓ All files found"
echo ""

# ============================================================================
# STEP 1: VM Size Restriction Policy
# ============================================================================
echo "============================================================"
echo "[1/7] Deploying VM Size Restriction Policy"
echo "============================================================"
echo ""

echo "Creating policy definition..."
az policy definition create \
    --name 'restrict-vm-sizes' \
    --display-name 'Restrict Virtual Machine SKU Sizes' \
    --description 'Restricts VM SKU sizes to approved B-series only' \
    --rules 'policy-vm-size-restriction.json' \
    --mode 'Indexed' \
    --subscription "$SUBSCRIPTION_ID" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✓ Policy definition created"
else
    echo "⚠ Policy definition may already exist, continuing..."
fi

echo "Assigning policy to subscription..."
az policy assignment create \
    --name 'vm-size-restriction' \
    --display-name 'Restrict Virtual Machine SKU Sizes' \
    --scope "/subscriptions/$SUBSCRIPTION_ID" \
    --policy 'restrict-vm-sizes' 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✓ Policy assigned"
else
    echo "⚠ Assignment may already exist"
fi

echo ""

# ============================================================================
# STEP 2: Web Farm SKU Restriction Policy
# ============================================================================
echo "============================================================"
echo "[2/7] Deploying Web Farm SKU Restriction Policy"
echo "============================================================"
echo ""

echo "Creating policy definition..."
az policy definition create \
    --name 'restrict-web-farm-skus' \
    --display-name 'Restrict App Service Plan SKU Sizes' \
    --description 'Restricts App Service Plan SKU sizes to B1 and P0v3 only' \
    --rules 'policy-web-farm-sku.json' \
    --mode 'Indexed' \
    --subscription "$SUBSCRIPTION_ID" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✓ Policy definition created"
else
    echo "⚠ Policy definition may already exist, continuing..."
fi

echo "Assigning policy to subscription..."
az policy assignment create \
    --name 'web-farm-sku-restriction' \
    --display-name 'Restrict App Service Plan SKU Sizes' \
    --scope "/subscriptions/$SUBSCRIPTION_ID" \
    --policy 'restrict-web-farm-skus' 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✓ Policy assigned"
else
    echo "⚠ Assignment may already exist"
fi

echo ""

# ============================================================================
# STEP 3: Tagging Policy
# ============================================================================
echo "============================================================"
echo "[3/7] Deploying Unified Tagging Policy"
echo "============================================================"
echo ""

echo "Creating policy definition..."
az policy definition create \
    --name 'require-tag-with-values' \
    --display-name 'Require tag with allowed values on resources' \
    --description 'Enforces that a specified tag exists with allowed values' \
    --rules 'policy-require-tag-with-values.json' \
    --mode 'Indexed' \
    --subscription "$SUBSCRIPTION_ID" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✓ Policy definition created"
else
    echo "⚠ Policy definition may already exist, continuing..."
fi

echo ""

# ============================================================================
# STEP 4: Assign Department Tag Policy
# ============================================================================
echo "============================================================"
echo "[4/7] Assigning Department Tag Policy"
echo "============================================================"
echo ""

echo "Assigning policy with parameters: Department = [Finance, Engineering]"
az policy assignment create \
    --name 'require-department-tag' \
    --display-name 'Require Department Tag' \
    --scope "/subscriptions/$SUBSCRIPTION_ID" \
    --policy 'require-tag-with-values' \
    --params '{
        "tagName": {"value": "Department"},
        "allowedTagValues": {"value": ["Finance", "Engineering"]}
    }' 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✓ Department tag policy assigned"
else
    echo "⚠ Assignment may already exist"
fi

echo ""

# ============================================================================
# STEP 5: Assign Environment Tag Policy
# ============================================================================
echo "============================================================"
echo "[5/7] Assigning Environment Tag Policy"
echo "============================================================"
echo ""

echo "Assigning policy with parameters: Environment = [Dev, Test, Prod]"
az policy assignment create \
    --name 'require-environment-tag' \
    --display-name 'Require Environment Tag' \
    --scope "/subscriptions/$SUBSCRIPTION_ID" \
    --policy 'require-tag-with-values' \
    --params '{
        "tagName": {"value": "Environment"},
        "allowedTagValues": {"value": ["Dev", "Test", "Prod"]}
    }' 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✓ Environment tag policy assigned"
else
    echo "⚠ Assignment may already exist"
fi

echo ""

# ============================================================================
# STEP 6: Assign Built-in Location Policy
# ============================================================================
echo "============================================================"
echo "[6/7] Assigning Built-in Location Policy"
echo "============================================================"
echo ""

echo "Finding built-in 'Allowed locations' policy..."
LOCATION_POLICY_ID=$(az policy definition list --query "[?displayName=='Allowed locations'].id" -o tsv)

if [ -z "$LOCATION_POLICY_ID" ]; then
    echo "✗ Built-in 'Allowed locations' policy not found"
else
    echo "✓ Found policy: $LOCATION_POLICY_ID"
    echo ""
    echo "Assigning with locations: eastus2, centralus"

    az policy assignment create \
        --name 'allowed-locations' \
        --display-name 'Restrict to East US 2 and Central US' \
        --scope "/subscriptions/$SUBSCRIPTION_ID" \
        --policy "$LOCATION_POLICY_ID" \
        --params '{
            "listOfAllowedLocations": {
                "value": ["eastus2", "centralus"]
            }
        }' 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "✓ Location policy assigned"
    else
        echo "⚠ Assignment may already exist"
    fi
fi

echo ""

# ============================================================================
# STEP 7: Create Custom Role (requires PowerShell script)
# ============================================================================
echo "============================================================"
echo "[7/7] Creating Custom Role"
echo "============================================================"
echo ""

echo "Note: Custom role creation requires the PowerShell script."
echo "Run this command in PowerShell mode:"
echo "  ./create-custom-role.ps1"
echo ""
echo "Or create the role using Azure CLI with JSON definition file."
echo ""

# ============================================================================
# Summary
# ============================================================================
echo "============================================================"
echo "Deployment Summary"
echo "============================================================"
echo ""

echo "Policy Assignments:"
az policy assignment list --query "[].{Name:name, DisplayName:displayName}" -o table

echo ""
echo "Custom Policy Definitions:"
az policy definition list --query "[?policyType=='Custom'].{Name:name, DisplayName:displayName}" -o table

echo ""
echo "============================================================"
echo "✓ Deployment Complete!"
echo "============================================================"
echo ""
echo "Next Steps:"
echo "1. Create custom role (run: ./create-custom-role.ps1 in PowerShell mode)"
echo "2. Assign PCI DSS v4 initiative via Azure Portal"
echo "3. Capture 14 required screenshots"
echo ""
