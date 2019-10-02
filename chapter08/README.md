### Practical Oracle Cloud Infrastructure
© Michal Jakobczyk  
Code snippets to use with Chapter 8.  
Replace `<placeholders>` with values matching your environment.  

---
#### SECTION: Containers ➙ Containerize an application ➙ Development instance in the cloud

:wrench: **Task:** Provision compute instance for container development     
:computer: **Execute on:** Your machine  
:dart: **Context:** Shell with TF_VAR_* environment variables set as in ~/tfvars.env.sh  
:file_folder: `oci-book/chapter08/1-devmachine`

    source ~/tfvars.env.sh
    cd ~/git
    cd oci-book/chapter08/1-devmachine
    find . \( -name "*.tf" -o -name "*.yaml" \) | sort
    terraform init
    terraform apply
    DEV_VM_PUBLIC_IP=`terraform output dev_machine_public_ip`

:wrench: **Task:** Connect to the compute instance   
:computer: **Execute on:** Your machine  

    ssh -i ~/.ssh/oci_id_rsa opc@$DEV_VM_PUBLIC_IP
    
:wrench: **Task:** Wait for cloud-init and exit  
:cloud: **Execute on:** Compute instance (dev-vm)
 
    sudo cat /var/log/cloud-init.log | grep "DEV machine is running"
    exit
    
:wrench: **Task:** Reconnect to the compute instance   
:computer: **Execute on:** Your machine  

    ssh -i ~/.ssh/oci_id_rsa opc@$DEV_VM_PUBLIC_IP
    
:wrench: **Task:** Verify Docker runtime and objects  
:cloud: **Execute on:** Compute instance (dev-vm)
    
    docker images
    docker ps
    docker info
    
---
#### SECTION: Containers ➙ Containerize an application ➙ Docker images
    
:wrench: **Task:** Clone the code repository  
:cloud: **Execute on:** Compute instance (dev-vm)  

    git clone https://github.com/mtjakobczyk/oci-book
    cd oci-book/chapter08/2-docker/uuid-service
    ls -1
    
:wrench: **Task:** Build the uuid container image  
:cloud: **Execute on:** Compute instance (dev-vm) 
    
    docker build -t uuid:1.0 .
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}"
    
---
#### SECTION: Containers ➙ Containerize an application ➙ Running containers

:wrench: **Task:** Launch containers  
:cloud: **Execute on:** Compute instance (dev-vm) 

    docker run -d -p 5011:5000 -e "UUID_GENERATOR_NAME=uuid-1"  --name uuid-1 uuid:1.0
    docker run -d -p 5012:5000 -e "UUID_GENERATOR_NAME=uuid-2"  --name uuid-2 uuid:1.0
    docker run -d -p 5013:5000 -e "UUID_GENERATOR_NAME=uuid-3"  --name uuid-3 uuid:1.0
    docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"
    
:wrench: **Task:** Test containers  
:cloud: **Execute on:** Compute instance (dev-vm) 
    
    curl 127.0.0.1:5011/identifiers
    curl 127.0.0.1:5012/identifiers
    curl 127.0.0.1:5013/identifiers
    exit
