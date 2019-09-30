### Practical Oracle Cloud Infrastructure
© Michal Jakobczyk  
Code snippets to use with Chapter 6.  
Replace `<placeholders>` with values matching your environment.  

---
#### SECTION: Virtual Networking ➙ Public IPs

:wrench: **Task:** Create a reserved public IP address   
:computer: **Execute on:** Your machine

    oci network public-ip create --lifetime RESERVED --display-name another-ip --profile SANDBOX-ADMIN

:wrench: **Task:** List reserved public IP addresses   
:computer: **Execute on:** Your machine

    oci network public-ip list --lifetime RESERVED --scope REGION --query 'data[*].{IP:"ip-address",Name:"display-name",State:"lifecycle-state"}' --output table --all --profile SANDBOX-ADMIN

:wrench: **Task:** Create a reserved public IP address   
:computer: **Execute on:** Your machine

    RESERVED_IP_NAME="my-ip"
    QUERY="data[?\"display-name\" == '$RESERVED_IP_NAME'].id | [0]"
    RESERVED_IP_OCID=`oci network public-ip list --scope REGION --lifetime RESERVED --query "$QUERY" --all --profile SANDBOX-ADMIN | tr -d '"'`
    echo $RESERVED_IP_OCID
    oci network public-ip delete --public-ip-id $RESERVED_IP_OCID --force --profile SANDBOX-ADMIN
    
---
#### SECTION: Virtual Networking ➙ Private subnets, Basion and NAT

:wrench: **Task:** Provision bastion and worker instances   
:computer: **Execute on:** Your machine  
:dart: **Context:** Shell with TF_VAR_* environment variables set as in ~/tfvars.env.sh

    source ~/tfvars.env.sh
    cd ~/git/oci-book/chapter06/1-bastion-nat/infrastructure/
    find . -name "*.tf"
    terraform init
    terraform apply -auto-approve
    BASTION_PUBLIC_IP=`terraform output bastion_public_ip`
    
:wrench: **Task:** Connect to the worker over bastion   
:computer: **Execute on:** Your machine  

    eval `ssh-agent -s` # [Windows Subsystem for Linux] or [GitBash on Windows] ONLY
    ssh-add ~/.ssh/oci_id_rsa
    ssh -J opc@$BASTION_PUBLIC_IP opc@10.0.1.130
    
:wrench: **Task:** Test internet connectivity from an instance in private Subnet  
:cloud: **Execute on:** Compute instance (worker-vm)
 
    ping -c 3 8.8.8.8
    exit

:wrench: **Task:** Destroy bastion and worker instances   
:computer: **Execute on:** Your machine  
:dart: **Context:** Shell with TF_VAR_* environment variables set as in ~/tfvars.env.sh

    cd ~/git/oci-book/chapter06/1-bastion-nat/infrastructure/
    terraform destroy -auto-approve
    
---
#### SECTION: Scaling Instances ➙ Instance Pools and Autoscale

:wrench: **Task:** Provision instance pool infrastructure   
:computer: **Execute on:** Your machine  
:dart: **Context:** Shell with TF_VAR_* environment variables set as in ~/tfvars.env.sh

    source ~/tfvars.env.sh
    cd ~/git/oci-book/chapter06/2-instance-pool-autoscale/infrastructure
    find . \( -name "*.tf" -o -name "*.yaml" \)
    terraform init
    terraform apply -auto-approve
    BASTION_PUBLIC_IP=`terraform output bastion_public_ip`
    
:wrench: **Task:** Connect to one of the pooled instances over bastion   
:computer: **Execute on:** Your machine  

    eval `ssh-agent -s` # [Windows Subsystem for Linux] or [GitBash on Windows] ONLY
    ssh-add ~/.ssh/oci_id_rsa
    ssh -J opc@$BASTION_PUBLIC_IP opc@10.1.2.2
    
:wrench: **Task:** Increase the load  
:cloud: **Execute on:** Compute instance (workers-pool instance)
 
    ps -axf -o %cpu,pid,command
    nohup stress-ng -c 0 -l 80 &
    ps -axf -o %cpu,pid,command
    exit
    
:wrench: **Task:** Destroy bastion and workers instances pool   
:computer: **Execute on:** Your machine  
:dart: **Context:** Shell with TF_VAR_* environment variables set as in ~/tfvars.env.sh

    cd ~/git/oci-book/chapter06/2-instance-pool-autoscale/infrastructure
    terraform destroy -auto-approve

---
#### SECTION: Scaling Instances ➙ Scaling instance vertically up
