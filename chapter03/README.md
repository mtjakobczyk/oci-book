### Practical Oracle Cloud Infrastructure
https://www.apress.com/gp/book/9781484255056  
© Michał Tomasz Jakóbczyk  
Code snippets to use with Chapter 3.  
Replace `<placeholders>` with values matching your environment.  

---
#### SECTION: Cloud Management Plane ➙ API Signing Key

:wrench: **Task:** Generate API Signing Key  
:computer: **Execute on:** Your machine

    mkdir ~/.apikeys
    cd ~/.apikeys
    openssl genrsa -out oci_api_pem -aes128 2048
    chmod go-rwx oci_api_pem
    ls -l | grep pem | awk '{ print $1" "$9 }'
    openssl rsa -pubout -in oci_api_pem -out oci_api_pem.pub
    ls -l | grep pem | awk '{ print $1" "$9 }'
 
:wrench: **Task:** Display the public key (API Signing Key)  
:computer: **Execute on:** Your machine
    
    cat oci_api_pem.pub

---
#### SECTION: SDK ➙ Installation

:wrench: **Task:** Check the version of Python  
:computer: **Execute on:** Your machine
    
    python3 --version
    
:wrench: **Task:** Create a virtual environment (venv)  
:computer: **Execute on:** Your machine
    
    cd ~
    python3 -m venv ocidev
    ls -1 ocidev/bin/
    
:wrench: **Task:** Activate the new virtual environment (venv)  
:computer: **Execute on:** Your machine
    
    source ~/ocidev/bin/activate
    
:wrench: **Task:** Update the venv and install OCI SDK  
:computer: **Execute on:** Your machine  
:dart: **Context:** Shell with the activated venv

    pip install --upgrade pip
    pip --version
    pip freeze
    pip install oci
    pip freeze
    deactivate

---
#### SECTION: SDK ➙ Configuration

:wrench: **Task:** Prepare OCI SDK/CLI configuration file  
:computer: **Execute on:** Your machine  
    
    mkdir ~/.oci
    cp ~/git/oci-book/chapter03/1-sdk/config.template ~/.oci/config
    chmod go-rwx ~/.oci/config
    ls ~/.oci
    vi ~/.oci/config # use vi or any other editor you prefer
    
:wrench: **Task:** Activate the venv and run Python interpreter  
:computer: **Execute on:** Your machine
    
    source ~/ocidev/bin/activate
    python3
    
:wrench: **Task:** Use OCI SDK for Python for the first time  
:computer: **Execute on:** Your machine  
:dart: **Context:** Python interpreter run within the activated venv

    import oci
    config = oci.config.from_file("~/.oci/config","DEFAULT")
    compute = oci.core.ComputeClient(config)
    quit()
    
:wrench: **Task:** Deactivate the venv  
:computer: **Execute on:** Your machine  
:dart: **Context:** Shell with the activated venv (continued)
    
    deactivate

---
#### SECTION: SDK ➙ Using the SDK

:wrench: **Task:** Activate the venv and run Python interpreter  
:computer: **Execute on:** Your machine
    
    source ~/ocidev/bin/activate
    python3
    
:wrench: **Task:** Use OCI SDK for Python to list all ADs in the current region  
:computer: **Execute on:** Your machine  
:dart: **Context:** Python interpreter run within the activated venv

    import oci
    config = oci.config.from_file("~/.oci/config","DEFAULT")
    identity = oci.identity.IdentityClient(config)
    ads_list = identity.list_availability_domains(config['tenancy']).data
    for ad in ads_list:
      print(ad.name)

:wrench: **Task:** Use OCI SDK for Python to create a new VCN  
:computer: **Execute on:** Your machine  
:dart: **Context:** Python interpreter run within the activated venv (continued)

    cid = "<put-here-sandbox-compartment-ocid>"
    kwargs = { "cidr_block": "10.5.0.0/16", "display_name": "sdk-vcn", "compartment_id": cid }
    create_vcn_details = oci.core.models.CreateVcnDetails(**kwargs)
    print(create_vcn_details)
    vcn = oci.core.VirtualNetworkClient(config)
    response = vcn.create_vcn(create_vcn_details)
    response.data
    
:wrench: **Task:** Use OCI SDK for Python to delete the VCN  
:computer: **Execute on:** Your machine  
:dart: **Context:** Python interpreter run within the activated venv (continued)

    response.data.id
    vcn.delete_vcn(response.data.id)
    quit()
    
:wrench: **Task:** Deactivate the venv  
:computer: **Execute on:** Your machine   
:dart: **Context:** Shell with the activated venv (continued)
    
    deactivate

---
#### SECTION: CLI ➙ Installation

:wrench: **Task:** Install OCI CLI  
:computer: **Execute on:** Your machine
    
    bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"
    source ~/.bashrc # On MacOS you may need to source .bash_profile instead
    oci --version
    
:wrench: **Task:** Verify OCI CLI installation  
:computer: **Execute on:** Your machine
    
    head -n 1 `which oci`
    cd ~/lib/oracle-cli/
    source bin/activate
    
:wrench: **Task:** Verify OCI CLI installation (continued)  
:computer: **Execute on:** Your machine   
:dart: **Context:** Python interpreter run within the activated OCI CLI venv
    
    pip freeze | grep oci
    deactivate
    
---
#### SECTION: CLI ➙ Configuration

:wrench: **Task:** Install OCI CLI  
:computer: **Execute on:** Your machine  
:warning: **Warning:** SKIP THIS TASK IF YOU'VE ALREADY CONFIGURED THE ~/.oci/config FILE

    oci setup config
    
:wrench: **Task:** Use OCI CLI to list available Ubuntu images  
:computer: **Execute on:** Your machine

    TENANCY_OCID=`cat ~/.oci/config | grep tenancy | sed 's/tenancy=//'`
    oci compute image list --compartment-id "$TENANCY_OCID" --operating-system "Canonical Ubuntu" --output table --query "data [*].{Image:\"display-name\"}"
    
:wrench: **Task:** Prepare the supplementary OCI CLI reusable configurtion file (oci_cli_rc)  
:computer: **Execute on:** Your machine

    cp ~/git/oci-book/chapter03/2-cli/oci_cli_rc.template ~/.oci/oci_cli_rc
    vi ~/.oci/oci_cli_rc # use vi or any other editor you prefer
    
:wrench: **Task:** Use OCI CLI to list available Ubuntu images (using oci_cli_rc)  
:computer: **Execute on:** Your machine

    oci compute image list --operating-system "Canonical Ubuntu" --output table --query query://list_ubuntu_1804

---
#### SECTION: CLI ➙ Using the CLI

:wrench: **Task:** Use OCI CLI to display the name of the compartment set by the active profile in oci_cli_rc  
:computer: **Execute on:** Your machine

    oci iam compartment get --output table --query "data.{CompartmentName:\"name\"}"

:wrench: **Task:** Use OCI CLI to create a new VCN  
:computer: **Execute on:** Your machine

    VCN_OCID=`oci network vcn create --cidr-block 192.168.3.0/24 --display-name cli-vcn --query "data.id" | tr -d '"'`
    echo $VCN_OCID
    
:wrench: **Task:** Use OCI CLI to create a new Internet Gateway for the VCN  
:computer: **Execute on:** Your machine

    IGW_OCID=`oci network internet-gateway create --vcn-id $VCN_OCID --display-name cli-igw --is-enabled true --query "data.id" | tr -d '"'`
    echo $IGW_OCID
    
    
:wrench: **Task:** Use OCI CLI to create a new Route Table for the VCN  
:computer: **Execute on:** Your machine

    ROUTE_RULES="[{\"cidrBlock\":\"0.0.0.0/0\", \"networkEntityId\":\"$IGW_OCID\"}]"
    RT_OCID=`oci network route-table create --vcn-id $VCN_OCID --display-name cli-rt --route-rules "$ROUTE_RULES" --query "data.id" | tr -d '"'`
    echo $RT_OCID

:wrench: **Task:** Use OCI CLI to create a new AD-specific subnet inside the VCN  
:computer: **Execute on:** Your machine

    AD1=`oci iam availability-domain list --query data[0].name | tr -d '"'`
    echo $AD1
    SUBNET_OCID=`oci network subnet create --vcn-id $VCN_OCID --display-name cli-vcn --cidr-block "192.168.3.0/30" --prohibit-public-ip-on-vnic false --availability-domain $AD1 --route-table-id $RT_OCID --query data.id | tr -d '"'`
    echo $SUBNET_OCID
    
:wrench: **Task:** Use OCI CLI to provision a new compute instance  
:computer: **Execute on:** Your machine

    IMAGE_OCID=`oci compute image list --shape "VM.Standard2.1" --operating-system "CentOS" --operating-system-version 7 --sort-by TIMECREATED --query data[0].id | tr -d '"'`
    echo $IMAGE_OCID
    VM_OCID=`oci compute instance launch --display-name cli-vm --availability-domain "$AD1" --subnet-id "$SUBNET_OCID" --private-ip 192.168.3.2 --image-id "$IMAGE_OCID" --shape VM.Standard2.1 --ssh-authorized-keys-file ~/oci_id_rsa.pub --wait-for-state RUNNING --query data.id | tr -d '"'`
    echo $VM_OCID

:wrench: **Task:** Use OCI CLI to list the public IP of a compute instance  
:computer: **Execute on:** Your machine

    oci compute instance list-vnics --instance-id "$VM_OCID" --query data[0].\"public-ip\" --raw-output
    
:wrench: **Task:** Use OCI CLI to terminate the instance and delete the VCN  
:computer: **Execute on:** Your machine

    oci compute instance terminate --instance-id $VM_OCID --wait-for-state TERMINATED
    oci network subnet delete --subnet-id $SUBNET_OCID --wait-for-state TERMINATED
    oci network route-table delete --rt-id $RT_OCID --wait-for-state TERMINATED
    oci network internet-gateway delete --ig-id $IGW_OCID --wait-for-state TERMINATED
    oci network vcn delete --vcn-id $VCN_OCID

---
#### SECTION: Terraform ➙ Installation

:wrench: **Task:** Install newest Terraform 0.12.x  
:computer: **Execute on:** Your machine

    cd ~
    wget https://releases.hashicorp.com/terraform/0.12.9/terraform_0.12.9_linux_amd64.zip
    sudo unzip terraform_0.12.9_linux_amd64.zip -d /usr/local/bin
    terraform -v

---
#### SECTION: Terraform ➙ Configuration

:wrench: **Task:** Explore the simplest Terraform OCI project  
:computer: **Execute on:** Your machine

    cd git/oci-book/chapter03/3-terraform/1-provider-only
    find . -name "*.tf"
    
:wrench: **Task:** Prepare configuration for Terraform  
:computer: **Execute on:** Your machine

    cp ~/git/oci-book/chapter03/3-terraform/tfvars.env.template.sh ~/tfvars.env.sh
    vi ~/tfvars.env.sh # use vi or any other editor you prefer
    chmod go-rwx ~/tfvars.env.sh
    
:wrench: **Task:**  Load new TF-specific environment variables for each session  
:computer: **Execute on:** Your machine

    echo "source ~/tfvars.env.sh" | tee -a .profile
    source ~/tfvars.env.sh
    
:wrench: **Task:**  Initialize Terraform project (1-provider-only)  
:computer: **Execute on:** Your machine  
:dart: **Context:** Shell with TF_VAR_* environment variables set as in ~/tfvars.env.sh

    source ~/tfvars.env.sh
    cd git/oci-book/chapter03/3-terraform/1-provider-only
    terraform init

:wrench: **Task:**  Inspect the size of OCI provider for Terraform binary   
:computer: **Execute on:** Your machine

    du -sh .terraform
    
---
#### SECTION: Terraform ➙ Using Terraform

:wrench: **Task:**  Initialize Terraform project (2-simple-infrastructure)   
:computer: **Execute on:** Your machine  
:dart: **Context:** Shell with TF_VAR_* environment variables set as in ~/tfvars.env.sh

    env | grep TF_VAR_
    cd ~/git/oci-book/chapter03/3-terraform/2-simple-infrastructure
    terraform init
    terraform apply
    
:wrench: **Task:**  Test application running on VM build with Terraform project (2-simple-infrastructure)  
:computer: **Execute on:** Your machine 
    
    VM_PUBLIC_IP=`terraform output web_instance_public_ip`
    echo $VM_PUBLIC_IP
    curl $VM_PUBLIC_IP
    
:wrench: **Task:**  Terminate Terraform project (2-simple-infrastructure)  
:computer: **Execute on:** Your machine  
:dart: **Context:** Shell with TF_VAR_* environment variables set as in ~/tfvars.env.sh

    terraform destroy --auto-approve
