#!/bin/sh

oci_config_path=$1
sandbox_admin_tfvars_path=$2
sandbox_compartment_ocid=$3

TENANCY_OCID=`cat $oci_config_path | grep tenancy | sed 's/tenancy=//'`
REGION_IDENTIFIER=`cat $oci_config_path | grep region | sed 's/region=//'`
SBXADM_USER_OCID=`cat $oci_config_path | grep -A 4 "\[SANDBOX-ADMIN\]" | grep user | sed 's/user=//'`
SBXADM_PRIVATE_KEY_PATH=`cat $oci_config_path | grep -A 4 "\[SANDBOX-ADMIN\]" | grep key_file | sed 's/key_file=//'`
SBXADM_PRIVATE_KEY_PASS=`cat $oci_config_path | grep -A 4 "\[SANDBOX-ADMIN\]" | grep pass_phrase | sed 's/pass_phrase=//'`
SBXADM_FINGERPRINT=`cat $oci_config_path | grep -A 4 "\[SANDBOX-ADMIN\]" | grep fingerprint | sed 's/fingerprint=//'`

echo "# Terraform variables for the SANDBOX-ADMIN" > $sandbox_admin_tfvars_path
echo "tenancy_ocid = \"$TENANCY_OCID\"" >> $sandbox_admin_tfvars_path
echo "region = \"$REGION_IDENTIFIER\"" >> $sandbox_admin_tfvars_path
echo "user_ocid = \"$SBXADM_USER_OCID\"" >> $sandbox_admin_tfvars_path
echo "private_key_path = \"$SBXADM_PRIVATE_KEY_PATH\"" >> $sandbox_admin_tfvars_path
echo "private_key_password = \"$SBXADM_PRIVATE_KEY_PASS\"" >> $sandbox_admin_tfvars_path
echo "fingerprint = \"$SBXADM_FINGERPRINT\"" >> $sandbox_admin_tfvars_path
echo "compartment_ocid = \"$sandbox_compartment_ocid\"" >> $sandbox_admin_tfvars_path
