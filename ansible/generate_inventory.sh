#!/bin/bash
     PUBLIC_IPS=$(echo $TF_PUBLIC_IPS | jq -r '.[]' | paste -sd "," -)
     PRIVATE_IPS=$(echo $TF_PRIVATE_IPS | jq -r '.[]' | paste -sd "," -)
     BASTION_IP=$(echo $TF_PUBLIC_IPS | jq -r '.[0]') # Use first public instance as bastion
     cat ansible/inventory.tmpl | sed "s/\${public_ips}/$PUBLIC_IPS/" | sed "s/\${private_ips}/$PRIVATE_IPS/" | sed "s/\${bastion_ip}/$BASTION_IP/" > ansible/inventory.yml
