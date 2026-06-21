# Azure Capstone Project - Manage Access, Policies, & Budgets

This project demonstrates the implementation of Azure governance, identity management, access control, and cost management best practices.

## Project Components

### 1. Policy Files (3 JSON files)
- `policy-vm-size-restriction.json` - Restricts VM SKU sizes to approved types
- `policy-web-farm-sku.json` - Restricts App Service Plan SKUs
- `policy-require-tag-with-values.json` - Enforces tagging with specific allowed values (parameterized)

### 2. PowerShell Scripts (3 files)
- `create-custom-role.ps1` - Creates VaultSecretCertificateManager custom role with DataActions
- `deploy-keyvault.ps1` - Deploys Azure Key Vault with proper tagging
- `audit-script.ps1` - Comprehensive Azure environment audit and enumeration script

### 3. Screenshots (24 files)
- **Policy Assignments (5):** Screenshots 01-05
- **PCI Compliance Initiative (1):** Screenshot 06
- **Groups and Role Assignments (5):** Screenshots 07-11
- **Budget and Alerts (3):** Screenshots 12-14
- **Resource Group Lock (1):** Screenshot 15 (`screenshot-15-rg-shared-vault-lock.png`)
- **Resource Groups (2):** Screenshot 16 (`screenshot-16-rg-electronicsunlimited-web.png`) & 17 (`screenshot-17-rg-qwer.png`) showing tags
- **Managed Identity (2):** Screenshot 18 (`screenshot-18-managed-identity-deploy-eu-web-dev.png`) showing identity & tags, & 19 (`screenshot-19-mi-contributor-role-assignment.png`) showing Contributor role assignment
- **Advisor Recommendations (5):** Screenshots 20-24 showing Advisor recommendations for Cost, Security, Reliability, Performance, and Operational Excellence

## Key Features

### Organizational Hierarchy
- Custom Azure policies for governance
- Tag enforcement via parameterized policy (Department, Environment)
- PCI DSS v4 compliance initiative assigned
- Resource group locks implemented (Delete lock on `rg-shared-vault`)

### Identity & Access Management
- Custom RBAC role with data plane permissions
- Security groups with appropriate scopes
- Managed Identity `deploy-eu-web-dev` with Contributor role on `rg-electronicsunlimited-web`
- Role assignments at subscription, resource group, and resource levels

### Cost Management
- Budget with $250 monthly limit
- Action groups for notifications
- Alert rules at 80% and 100% thresholds

## Implementation Highlights

All policies and scripts are idempotent and follow Azure best practices. The custom role includes both management plane Actions and data plane DataActions for comprehensive Key Vault secret and certificate management.

## Deployment

Scripts are designed to run in Azure Cloud Shell (PowerShell). All resources are tagged with:
- `Environment: Dev`
- `Department: Engineering`
