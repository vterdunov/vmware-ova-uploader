#!/bin/sh

# Default values
VSPHERE_ADDRESS_DEFAULT='vi-devops-vc1.lab.vi.local'
VSPHERE_DC_DEFAULT='DC1'
VSPHERE_DATASTORE_DEFAULT='DEVOPS_PROD/devops_prd01'
VSPHERE_NETWORK_DEFAULT='dv-net-26'
VSPHERE_TEMPLATE_PATH_DEFAULT='vagrant'
VSPHERE_COMPUTER_PATH_DEFAULT='devops-R610' # path to the cluster to deploy into
VSPHERE_VM_FOLDER_PATH_DEFAULT='vagrant'

read -p "Enter vSphere address [${VSPHERE_ADDRESS_DEFAULT}]: " VSPHERE_ADDRESS
read -p 'Enter vSphere username: ' VSPHERE_USERNAME
read -p 'Enter vSphere password: ' VSPHERE_PASSWORD
read -p "Enter OVA's URL sddress: " OVA_URL
read -p 'Enter VM name: ' MACHINE_NAME
VSPHERE_TEMPLATE_NAME="$MACHINE_NAME"
read -p "Enter Template name [${VSPHERE_TEMPLATE_NAME}]: " VSPHERE_TEMPLATE_NAME
read -p "Enter vSphere datacenter name [${VSPHERE_DC_DEFAULT}]: " VSPHERE_DC
read -p "Enter vSphere datastore name [${VSPHERE_DATASTORE_DEFAULT}]: " VSPHERE_DATASTORE
read -p "Enter vSphere network name [${VSPHERE_NETWORK_DEFAULT}]: " VSPHERE_NETWORK
read -p "Enter vSphere template path [${VSPHERE_TEMPLATE_PATH_DEFAULT}]: " VSPHERE_TEMPLATE_PATH
read -p "Enter vSphere computer path [${VSPHERE_COMPUTER_PATH_DEFAULT}]: " VSPHERE_COMPUTER_PATH
read -p "Enter vSphere VM's folder path [${VSPHERE_VM_FOLDER_PATH_DEFAULT}]: " VSPHERE_VM_FOLDER_PATH

[ -n "$VSPHERE_USERNAME" ] || { echo 'vSphere username not found.'; exit 1; }
[ -n "$VSPHERE_PASSWORD" ] || { echo 'vSphere password not found.'; exit 1; }
[ -n "$OVA_URL" ]          || { echo 'OVA URL not setted.'; exit 1; }
[ -n "$MACHINE_NAME" ]     || { echo 'VM name not setted.'; exit 1; }

VSPHERE_ADDRESS="${VSPHERE_ADDRESS:-$VSPHERE_ADDRESS_DEFAULT}"
VSPHERE_TEMPLATE_NAME="${VSPHERE_TEMPLATE_NAME:-$VSPHERE_TEMPLATE_NAME_DEFAULT}"
VSPHERE_DC="${VSPHERE_DC:-$VSPHERE_DC_DEFAULT}"
VSPHERE_DATASTORE="${VSPHERE_DATASTORE:-$VSPHERE_DATASTORE_DEFAULT}"
VSPHERE_NETWORK="${VSPHERE_NETWORK:-$VSPHERE_NETWORK_DEFAULT}"
VSPHERE_TEMPLATE_PATH="${VSPHERE_TEMPLATE_PATH:-$VSPHERE_TEMPLATE_PATH_DEFAULT}"
VSPHERE_COMPUTER_PATH="${VSPHERE_COMPUTER_PATH:-$VSPHERE_COMPUTER_PATH_DEFAULT}"
VSPHERE_VM_FOLDER_PATH="${VSPHERE_VM_FOLDER_PATH:-$VSPHERE_VM_FOLDER_PATH_DEFAULT}"

echo
echo 'Params:'
echo "vSphere address: ${VSPHERE_ADDRESS}"
echo "vSphere username: ${VSPHERE_USERNAME}"
echo "vSphere password: HIDDEN"
echo "OVA's URL: ${OVA_URL}"
echo "VM name: ${MACHINE_NAME}"
echo '---------'
echo "vSphere datacenter: ${VSPHERE_DC}"
echo "vSphere datastore: ${VSPHERE_DATASTORE}"
echo "vSphere network: ${VSPHERE_NETWORK}"
echo "vSphere template path: ${VSPHERE_TEMPLATE_PATH}"
echo "vSphere computer path: ${VSPHERE_COMPUTER_PATH}"
echo "vSphere VM's folder path: ${VSPHERE_VM_FOLDER_PATH}"
echo
echo

rm -rf /tmp/files
mkdir -p /tmp/files
echo 'Downloading OVA...'
wget -c "$OVA_URL" -O /tmp/files/to_deploy.ova
echo 'Unpacking OVA...'
tar xf /tmp/files/to_deploy.ova -C /tmp/files/

OVF_FILE=$(find /tmp/files -name '*.ovf' | head -n 1)

echo 'Deploing VM'
ruby /usr/share/deployer/cached_ovf_deploy.rb \
  --host="$VSPHERE_ADDRESS" \
  --user="$VSPHERE_USERNAME" \
  --password="$VSPHERE_PASSWORD" \
  --datacenter="$VSPHERE_DC" \
  --datastore="$VSPHERE_DATASTORE" \
  --network="$VSPHERE_NETWORK" \
  --computer-path="$VSPHERE_COMPUTER_PATH" \
  --template-path="$VSPHERE_TEMPLATE_PATH" \
  --vm-folder-path="$VSPHERE_VM_FOLDER_PATH" \
  --template-name="$VSPHERE_TEMPLATE_NAME" \
  --insecure \
  --no-ssl \
  "$MACHINE_NAME" \
  "$OVF_FILE"
