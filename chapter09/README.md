### Practical Oracle Cloud Infrastructure
© Michal Jakobczyk  
Code snippets to use with Chapter 9.  
Replace `<placeholders>` with values matching your environment.  

---
#### SECTION: Serverless ➙ Developer VM

:wrench: **Task:** Provision a Dev Machine     
:computer: **Execute on:** Your machine  
:dart: **Context:** Shell with TF_VAR_* environment variables set as in ~/tfvars.env.sh  
:file_folder: `oci-book/chapter09/1-infrastructure`

    cd ~/git
    cd oci-book/chapter09/1-infrastructure
    find . \( -name "*.tf" -o -name "*.yaml" \) | sort
    source ~/tfvars.env.sh
    terraform init
    terraform apply
    DEV_MACHINE_IP=`terraform output dev_machine_public_ip`

:wrench: **Task:** Connect to the Dev Machine     
:computer: **Execute on:** Your machine   
    
    ssh -i ~/.ssh/oci_id_rsa ubuntu@$DEV_MACHINE_IP

:wrench: **Task:** Wait for cloud-init to complete     
:cloud: **Execute on:** Cloud instance (dev-vm)

    sudo cat /var/log/syslog | grep "DEV machine"
    exit
    
:wrench: **Task:** Reconnect to the Dev Machine     
:computer: **Execute on:** Your machine   
    
    ssh -i ~/.ssh/oci_id_rsa ubuntu@$DEV_MACHINE_IP
    
:wrench: **Task:** Verify Docker is running     
:cloud: **Execute on:** Cloud instance (dev-vm)

    docker images
    docker info
    
    
    
