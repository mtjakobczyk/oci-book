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
python3 --version
python3 -m venv ocidev
ls -1 ocidev/bin/

## Activate a virtual environment and install SDK
### bash
source ocidev/bin/activate
pip install –-upgrade pip
pip –version
pip freeze
pip install oci
pip freeze

## Activate a virtual environment and install SDK
### bash
mkdir ~/.oci
touch ~/.oci/config
chmod go-rwx ~/.oci/config
ls ~/.oci

## Test SDK configuration import
### bash
source ocidev/bin/activate
python3
### python
import oci
config = oci.config.from_file(“~/.oci/config”,“DEFAULT”)
compute = oci.core.ComputeClient(config)


## List availability domains in home region using SDK
### bash
source ocidev/bin/activate
python3
### python
import oci
config = oci.config.from_file(“~/.oci/config”,“DEFAULT”)
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
