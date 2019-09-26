### Practical Oracle Cloud Infrastructure
© Michal Jakobczyk  
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
#### SECTION: SDK ➙ Installation

:wrench: **Task:** Prepare OCI SDK/CLI configuration file  
:computer: **Execute on:** Your machine  
    
    mkdir ~/.oci
    touch ~/.oci/config
    chmod go-rwx ~/.oci/config
    ls ~/.oci
    vi ~/.oci/config
    
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
