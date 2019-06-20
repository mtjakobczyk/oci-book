# PRACTICAL ORACLE CLOUD Infrastructure
# CHAPTER 06 - Code Snippets

# SECTION: Public IPs

## Create a reserved public IP address
### bash
oci network public-ip create --lifetime RESERVED --display-name another-ip --profile SANDBOX-ADMIN

## List reserved public IP addresses
### bash
oci network public-ip list --lifetime RESERVED --scope REGION --query 'data[*].{IP:"ip-address",Name:"display-name",State:"lifecycle-state"}' --output table --all --profile SANDBOX-ADMIN

## Delete a reseverd public IP address by name
### bash
RESERVED_IP_NAME="my-ip"
QUERY="data[?\"display-name\" == '$RESERVED_IP_NAME'].id | [0]"
RESERVED_IP_OCID=`oci network public-ip list --scope REGION --lifetime RESERVED --query "$QUERY" --all --profile SANDBOX-ADMIN | tr -d '"'`
echo $RESERVED_IP_OCID
oci network public-ip delete --public-ip-id $RESERVED_IP_OCID --force --profile SANDBOX-ADMIN


# SECTION: Private subnets, Basion and NAT

## Provision bastion and worker instances
### bash
cd ~/git
cd oci-book/chapter06/1-bastion-nat/infrastructure/
find . -name "*.tf"
terraform init
terraform apply -auto-approve

## Connect to the worker over bastion and test the connectivity
### bash (only on Windows Subsystem for Linux)
eval `ssh-agent -s`
### bash
ssh-add ~/.ssh/oci_id_rsa
ssh -J opc@130.61.X.X opc@10.0.1.130
### bash (on worker-vm)
ping -c 3 8.8.8.8
exit

## Update infrastructure code to immediately block any outbount traffic to Internet
##### Set block_traffic=true for natgw resource defined in 1-bastion-nat/infrastructure/vcn.tf
### bash
terraform apply -auto-approve

## Connect to the worker over bastion again and test the connectivity
### bash
ssh -J opc@130.61.X.X opc@10.0.1.130
### bash (on worker-vm)
ping -c 3 8.8.8.8
exit

## Destroy bastion and worker instances
### bash
terraform destroy -auto-approve


# SECTION: Instance Pools and Autoscale

## Provision instance pool infrastructure
### bash
cd ~/git
cd oci-book/chapter06/2-instance-pool-autoscale/infrastructure
find . \( -name "*.tf" -o -name "*.yaml" \)
terraform init
terraform apply -auto-approve

## Connect to one of the pooled instances
### bash
ssh -J opc@130.61.X.X opc@10.1.2.2
### bash (on one of the pooled instances)
ps -axf -o %cpu,pid,command
nohup stress-ng -c 0 -l 80 &
ps -axf -o %cpu,pid,command
exit

## Destroy infrastructure
### bash
terraform destroy -auto-approve


# SECTION: Scaling instance vertically up

## Provision compute instance
### bash
cd ~/git
cd oci-book/chapter06/3-instance-scale-up/infrastructure
find . \( -name "*.tf" -o -name "*.yaml" \)
terraform init
terraform apply -auto-approve

## Access the instance and note down the time marker
### bash
ssh -i .ssh/oci_id_rsa opc@130.61.X.X
# bash (on vm-1-ocpu)
cat datemarker
exit

## Alter instance to preserve boot volume
##### Uncomment the indicated lines in 3-instance-scale-up/infrastructure/compute.tf
### bash
terraform plan
terraform apply -auto-approve

## Detach boot volume
### bash
BOOTVOLUME_OCID=`terraform output "3 - VM bootvolume OCID"`
echo $BOOTVOLUME_OCID
BOOTVOLUME_AD=`oci bv boot-volume get --boot-volume-id $BOOTVOLUME_OCID --query 'data."availability-domain"' --profile SANDBOX-ADMIN | sed 's/["]//g'`
echo $BOOTVOLUME_AD
BOOTVOLUME_ATTACHMENT_OCID=`oci compute boot-volume-attachment list --availability-domain $BOOTVOLUME_AD --boot-volume-id $BOOTVOLUME_OCID --query 'data[0].id' --profile SANDBOX-ADMIN | sed 's/["]//g'`
echo $BOOTVOLUME_ATTACHMENT_OCID
oci compute boot-volume-attachment detach --boot-volume-attachment-id $BOOTVOLUME_ATTACHMENT_OCID --wait-for-state DETACHED --force --profile SANDBOX-ADMIN

## Alter instance to preserve boot volume
##### Comment the entire 3-instance-scale-up/infrastructure/compute.tf
##### Uncomment the entire 3-instance-scale-up/infrastructure/compute-ocpu2.tf
### bash
echo $BOOTVOLUME_OCID
export TF_VAR_vm_2_ocpu_bootvolume_ocid=$BOOTVOLUME_OCID
echo $TF_VAR_vm_2_ocpu_bootvolume_ocid
terraform plan
terraform apply -auto-approve

## Access the instance and verify if the original time marker survived
### bash
ssh -i .ssh/oci_id_rsa opc@130.61.X.X
# bash (on vm-2-ocpu)
cat datemarker
exit

## Change the display name of the boot volume
### bash
oci bv boot-volume update --boot-volume-id $BOOTVOLUME_OCID --display-name vm-bv --profile SANDBOX-ADMIN

## Destroy infrastructure
### bash
terraform destroy -auto-approve
