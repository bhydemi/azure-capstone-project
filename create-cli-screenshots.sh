#!/bin/bash

echo "=========================================="
echo "SCREENSHOT 8: Reader Role on Subscription"
echo "=========================================="
echo ""
echo "Group: KeyVaultSecretAndCertificateAdmins"
echo "Resource: Udacity-20 Subscription"
echo "Role Assignment:"
echo ""
az role assignment list \
  --assignee a8e89258-dc65-40e1-b18f-e69099c06f21 \
  --scope "/subscriptions/74988724-a6c9-45f7-8bae-f10139eec21f" \
  --query "[].{Role:roleDefinitionName, AssignedTo:'KeyVaultSecretAndCertificateAdmins', Scope:scope}" \
  --output table

echo ""
echo ""
echo "=========================================="
echo "SCREENSHOT 9: Key Vault Roles"
echo "=========================================="
echo ""
echo "Group: KeyVaultSecretAndCertificateAdmins"
echo "Resource: kv-devshared-20260428-ho"
echo "Role Assignments:"
echo ""
az role assignment list \
  --assignee a8e89258-dc65-40e1-b18f-e69099c06f21 \
  --scope "/subscriptions/74988724-a6c9-45f7-8bae-f10139eec21f/resourceGroups/rg-shared-vault/providers/Microsoft.KeyVault/vaults/kv-devshared-20260428-ho" \
  --query "[].{Role:roleDefinitionName, AssignedTo:'KeyVaultSecretAndCertificateAdmins', Resource:'kv-devshared-20260428-ho'}" \
  --output table

echo ""
echo ""
echo "=========================================="
echo "SCREENSHOT 10: Contributor on rg-external"
echo "=========================================="
echo ""
echo "Group: external-contributors"
echo "Resource: rg-external"
echo "Role Assignment:"
echo ""
az role assignment list \
  --assignee 8f1a4385-95a7-4e93-a1a4-bea9ef8927cc \
  --resource-group rg-external \
  --query "[].{Role:roleDefinitionName, AssignedTo:'external-contributors', Scope:scope}" \
  --output table

echo ""
echo "=========================================="
echo "All role assignments verified via Azure CLI"
echo "=========================================="

