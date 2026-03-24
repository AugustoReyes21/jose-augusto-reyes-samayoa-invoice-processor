#!/bin/sh
set -eu

RESOURCE_GROUP="${RESOURCE_GROUP:-rg-jose-augusto-reyes-samayoa}"
LOCATION="${LOCATION:-eastus}"
VM_NAME="${VM_NAME:-vm-jose-augusto-reyes-samayoa}"
ADMIN_USER="${ADMIN_USER:-azureuser}"
SSH_PUBLIC_KEY="${AZURE_SSH_PUBLIC_KEY:-$HOME/.ssh/azure_jose_augusto_reyes_samayoa.pub}"

if [ ! -f "${SSH_PUBLIC_KEY}" ]; then
  echo "Missing SSH public key: ${SSH_PUBLIC_KEY}" >&2
  exit 1
fi

az group create --name "${RESOURCE_GROUP}" --location "${LOCATION}"

az vm create \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${VM_NAME}" \
  --image Ubuntu2204 \
  --size Standard_B1s \
  --admin-username "${ADMIN_USER}" \
  --authentication-type ssh \
  --ssh-key-values "${SSH_PUBLIC_KEY}" \
  --public-ip-sku Standard

az vm open-port --resource-group "${RESOURCE_GROUP}" --name "${VM_NAME}" --port 22
az vm open-port --resource-group "${RESOURCE_GROUP}" --name "${VM_NAME}" --port 80
az vm open-port --resource-group "${RESOURCE_GROUP}" --name "${VM_NAME}" --port 443

az vm list-ip-addresses \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${VM_NAME}" \
  --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" \
  --output tsv
