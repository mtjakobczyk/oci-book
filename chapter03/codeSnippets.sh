# PRACTICAL ORACLE CLOUD Infrastructure
# CHAPTER 03 - Code Snippets

# SECTION: API Signing Key

## Generate keypair
### bash / OCI CLI
mkdir .apikeys
cd .apikeys
openssl genrsa -out oci_api_pem -aes128 2048
chmod go-rwx oci_api_pem
ls -l | grep pem | awk '{ print $1" "$9 }'
openssl rsa -pubout -in oci_api_pem -out oci_api_pem.pub
ls -l | grep pem | awk '{ print $1" "$9 }'
cat oci_api_pem.pub

# SECTION: SDK

## Create a virtual environment (Python 3)
### bash
cd ~
python3 --version
python3 -m venv ocidev
ls -1 ocidev/bin/

## Activate a virtual environment and install SDK
### bash
source ~/ocidev/bin/activate
pip install --upgrade pip
pip --version
pip freeze
pip install oci
pip freeze
deactivate

## Activate a virtual environment and install SDK
### bash
mkdir ~/.oci
touch ~/.oci/config
chmod go-rwx ~/.oci/config
ls ~/.oci

### Prepare SDK configuration in .oci directory based on 1-sdk/config file

## Test SDK configuration import
### bash
source ~/ocidev/bin/activate
python3
### python
import oci
config = oci.config.from_file("~/.oci/config","DEFAULT")
compute = oci.core.ComputeClient(config)
quit()
### bash
deactivate

## List availability domains in home region using SDK
### bash
source ocidev/bin/activate
python3
### python
import oci
config = oci.config.from_file("~/.oci/config","DEFAULT")
identity = oci.identity.IdentityClient(config)
ads_list = identity.list_availability_domains(config['tenancy']).data
for ad in ads_list:
  print(ad.name)


## Create a new VCN using SDK
### python (continued in the same virtual environment)
cid = "put-here-compartment-ocid"
kwargs = { "cidr_block": "10.5.0.0/16", "display_name": "sdk-vcn", "compartment_id": cid }
create_vcn_details = oci.core.models.CreateVcnDetails(**kwargs)
print(create_vcn_details)
vcn = oci.core.VirtualNetworkClient(config)
response = vcn.create_vcn(create_vcn_details)
response.data

## Delete an existing VCN using SDK
### python (continued in the same virtual environment)
response.data.id
vcn.delete_vcn(response.data.id)
quit()
# bash
deactivate


# SECTION: CLI

## Install OCI CLI
### bash
bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"

## Explore OCI CLI virtual environment
### bash
oci --version
head -n 1 `which oci`
cd ~/lib/oracle-cli/
source bin/activate
pip freeze | grep oci
deactivate

## Use CLI to query for Oracle-provided Ubuntu image names
### bash
cat ~/.oci/config | grep tenancy
tenancy_ocid=put-here-tenancy-ocid
oci compute image list --compartment-id $tenancy_ocid --operating-system "Canonical Ubuntu" --output table --query "data [*].{Image:\"display-name\"}"

## Use predefined CLI queries to list specific versions of Oracle-provided Ubuntu image names
### bash
touch ~/.oci/oci_cli_rc
##### Edit oci_cli_rc configuration file based on 2-sdk/oci_cli_rc file
oci compute image list --operating-system "Canonical Ubuntu" --output table --query query://list_ubuntu_1804

## Check current default compartment for CLI commands
### bash
oci iam compartment get --output table --query "data.{CompartmentName:\"name\"}"

## Create VCN, Internet Gateway, Routing Table, Subnet and Compute Instance using CLI
### bash
vcn_ocid=`oci network vcn create --cidr-block 192.168.3.0/24 --display-name cli-vcn --query "data.id" | tr -d '"'`
echo $vcn_ocid
igw_ocid=`oci network internet-gateway create --vcn-id $vcn_ocid --display-name cli-igw --is-enabled true --query "data.id" | tr -d '"'`
echo $igw_ocid
route_rules="[{\"cidrBlock\":\"0.0.0.0/0\", \"networkEntityId\":\"$igw_ocid\"}]"
rt_ocid=`oci network route-table create --vcn-id $vcn_ocid --display-name cli-rt --route-rules "$route_rules" --query "data.id" | tr -d '"'`
echo $rt_ocid
ad1=`oci iam availability-domain list --query data[0].name | tr -d '"'`
echo $ad1
subnet_ocid=`oci network subnet create --vcn-id $vcn_ocid --display-name cli-vcn --cidr-block "192.168.3.0/30" --prohibit-public-ip-on-vnic false --availability-domain $ad1 --route-table-id $rt_ocid --query data.id | tr -d '"'`
echo $subnet_ocid
image_ocid=`oci compute image list --operating-system "CentOS" --operating-system-version 7 --sort-by TIMECREATED --query data[0].id | tr -d '"'`
echo $image_ocid
vm_ocid=`oci compute instance launch --display-name cli-vm --availability-domain "$ad1" --subnet-id "$subnet_ocid" --private-ip 192.168.3.2 --image-id "$image_ocid" --shape VM.Standard2.1 --ssh-authorized-keys-file ~/.ssh/oci_id_rsa.pub --wait-for-state RUNNING --query data.id | tr -d '"'`
echo $vm_ocid

## Listing the public IP of the compute instance using CLI
### bash
oci compute instance list-vnics --instance-id "$vm_ocid" --query data[*].\"public-ip\"

## Terminating Compute Instance, Subnet, Internet Gateway, Routing Table and VCN using CLI
### bash
oci compute instance terminate --instance-id $vm_ocid --wait-for-state TERMINATED
oci network subnet delete --subnet-id $subnet_ocid --wait-for-state TERMINATED
oci network route-table delete --rt-id $rt_ocid --wait-for-state TERMINATED
oci network internet-gateway delete --ig-id $igw_ocid --wait-for-state TERMINATED
oci network vcn delete --vcn-id $vcn_ocid



# SECTION: Terraform

## Install Terraform
### bash
wget https://releases.hashicorp.com/terraform/0.12.2/terraform_0.12.2_linux_amd64.zip
sudo unzip terraform_0.12.2_linux_amd64.zip -d /usr/local/bin
terraform -v

## Prepare project directory
### bash
mkdir myfirsttf
touch myfirsttf/provider.tf
##### Edit provider.tf configuration file based on 3-terraform/1-provider-only/provider.tf
touch myfirsttf/vars.tf
##### Edit vars.tf configuration file based on 3-terraform/1-provider-only/vars.tf

## Prepare configuration for Terraform
### bash
touch ~/tfvars.env.sh
##### Edit tfvars.env.sh configuration file based on 3-terraform/tfvars.env.sh
echo "source ~/tfvars.env.sh" | tee -a .profile

## Initialize Terraform infrastructure project
### bash
source ~/tfvars.env.sh
cd ~/myfirsttf
terraform init

## Inspect the size of provider plugin
### bash
du -sh ~/myfirsttf/.terraform/
