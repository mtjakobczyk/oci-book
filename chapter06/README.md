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

:wrench: **Task:** Provision compute instance   
:computer: **Execute on:** Your machine  
:dart: **Context:** Shell with TF_VAR_* environment variables set as in ~/tfvars.env.sh  
:file_folder: `oci-book/chapter06/3-instance-scale-up/infrastructure`

    source ~/tfvars.env.sh
    cd ~/git
    cd oci-book/chapter06/3-instance-scale-up/infrastructure
    find . \( -name "*.tf" -o -name "*.yaml" \)
    terraform init
    terraform apply -auto-approve
    INSTANCE_PUBLIC_IP=`terraform output vm_public_ip`

:wrench: **Task:** Connect to the worker over bastion   
:computer: **Execute on:** Your machine  

    ssh -i ~/.ssh/oci_id_rsa opc@$INSTANCE_PUBLIC_IP
    
:wrench: **Task:** Note down the boot time marker  
:cloud: **Execute on:** Compute instance (vm-1-OCPU)
 
    cat datemarker
    exit
    
:wrench: **Task:** Alter the instance to preserve its boot volume on instance termination   
:computer: **Execute on:** Your machine  
:dart: **Context:** Shell with TF_VAR_* environment variables set as in ~/tfvars.env.sh  
:file_folder: `oci-book/chapter06/3-instance-scale-up/infrastructure`

    sed -i 's/\/\*//; s/\*\///' compute.tf
    terraform plan
    terraform apply -auto-approve

:wrench: **Task:** Detach boot volume   
:computer: **Execute on:** Your machine  
:file_folder: `oci-book/chapter06/3-instance-scale-up/infrastructure`

    BOOTVOLUME_OCID=`terraform output "vm_bootvolume_ocid"`
    echo $BOOTVOLUME_OCID
    BOOTVOLUME_AD=`oci bv boot-volume get --boot-volume-id $BOOTVOLUME_OCID --query 'data."availability-domain"' --profile SANDBOX-ADMIN | sed 's/["]//g'`
    echo $BOOTVOLUME_AD
    BOOTVOLUME_ATTACHMENT_OCID=`oci compute boot-volume-attachment list --availability-domain $BOOTVOLUME_AD --boot-volume-id $BOOTVOLUME_OCID --query 'data[0].id' --profile SANDBOX-ADMIN | sed 's/["]//g'`
    echo $BOOTVOLUME_ATTACHMENT_OCID
    oci compute boot-volume-attachment detach --boot-volume-attachment-id $BOOTVOLUME_ATTACHMENT_OCID --wait-for-state DETACHED --force --profile SANDBOX-ADMIN

:wrench: **Task:** Alter infrastructure code to use more powerful instance with the existing boot volume attached    
:computer: **Execute on:** Your machine  
:file_folder: `oci-book/chapter06/3-instance-scale-up/infrastructure`

    rm compute.tf
    sed -i 's/\/\*//; s/\*\///' compute-ocpu2.tf
    
:wrench: **Task:** Provision more powerful instance with the existing boot volume attached    
:computer: **Execute on:** Your machine  
:dart: **Context:** Shell with TF_VAR_* environment variables set as in ~/tfvars.env.sh  
:file_folder: `oci-book/chapter06/3-instance-scale-up/infrastructure`

    echo $BOOTVOLUME_OCID
    export TF_VAR_vm_2_ocpu_bootvolume_ocid=$BOOTVOLUME_OCID
    echo $TF_VAR_vm_2_ocpu_bootvolume_ocid
    terraform plan
    terraform apply -auto-approve
    NEW_INSTANCE_PUBLIC_IP=`terraform output new_vm_public_ip`
    
:wrench: **Task:** Connect to the worker over bastion   
:computer: **Execute on:** Your machine  

    ssh -i ~/.ssh/oci_id_rsa opc@$NEW_INSTANCE_PUBLIC_IP
    
:wrench: **Task:** Note down the boot time marker  
:cloud: **Execute on:** Compute instance (vm-2-OCPU)
 
    cat datemarker
    exit
    
:wrench: **Task:** Change the display name of the boot volume   
:computer: **Execute on:** Your machine  

    oci bv boot-volume update --boot-volume-id $BOOTVOLUME_OCID --display-name vm-bv --profile SANDBOX-ADMIN
