#!/bin/bash
echo "TF_PUBLIC_IPS: $TF_PUBLIC_IPS" > /tmp/inventory_debug.log
echo "TF_PRIVATE_IPS: $TF_PRIVATE_IPS" >> /tmp/inventory_debug.log
PUBLIC_IPS=$(echo $TF_PUBLIC_IPS | jq -r '.[]' | paste -sd "," -)
PRIVATE_IPS=$(echo $TF_PRIVATE_IPS | jq -r '.[]' | paste -sd "," -)
BASTION_IP=$(echo $TF_PUBLIC_IPS | jq -r '.[0]') # Use first public instance as bastion
echo "PUBLIC_IPS: $PUBLIC_IPS" >> /tmp/inventory_debug.log
echo "PRIVATE_IPS: $PRIVATE_IPS" >> /tmp/inventory_debug.log
echo "BASTION_IP: $BASTION_IP" >> /tmp/inventory_debug.log
cat ansible/inventory.tmpl | sed "s/\${public_ips}/$PUBLIC_IPS/" | sed "s/\${private_ips}/$PRIVATE_IPS/" | sed "s/\${bastion_ip}/$BASTION_IP/" > ansible/inventory.yml
echo "Inventory generated at ansible/inventory.yml" >> /tmp/inventory_debug.log
