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
:computer: **Additionally:** Make sure the venv is activated in your Shell

    pip install --upgrade pip
    pip --version
    pip freeze
    pip install oci
    pip freeze
    deactivate
