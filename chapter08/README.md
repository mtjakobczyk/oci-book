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
:file_folder: `oci-book/chapter08/2-docker/uuid-service`
    
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

---
#### SECTION: Containers ➙ Container Registry

:wrench: **Task:** Create a policy     
:computer: **Execute on:** Your machine   
:file_folder: `oci-book/chapter08/2-docker/policies`

    cd ~/git
    cd oci-book/chapter08/2-docker/policies
    ls -1
    TENANCY_OCID=`cat ~/.oci/config | grep tenancy | sed 's/tenancy=//'`
    oci iam policy create -c $TENANCY_OCID --name tenancy-ocir-policy --description "OCIR Polices"  --statements "file://tenancy.ocir.policies.json"

:wrench: **Task:** Generate an Auth Token     
:computer: **Execute on:** Your machine  

    IAM_USER_OCID=`oci iam user list -c $TENANCY_OCID --query "data[?name=='sandbox-user'] | [0].id" --raw-output`
    oci iam auth-token create --user-id $IAM_USER_OCID --description token-ocir --query 'data.token' --raw-output
    
:wrench: **Task:** Connect to the compute instance   
:computer: **Execute on:** Your machine  

    ssh -i ~/.ssh/oci_id_rsa opc@$DEV_VM_PUBLIC_IP
    
:wrench: **Task:** Tag the image  
:cloud: **Execute on:** Compute instance (dev-vm) 

    OCI_PROJECT_CODE=sandbox
    OCI_TENANCY=<put-here-your-tenancy-name>
    OCIR_REGION=<put-here-your-ocir-region-code>
    OCI_USER=sandbox-user
    IMAGE_NAME=uuid
    IMAGE_TAG=1.0
    docker tag $IMAGE_NAME:$IMAGE_TAG $OCIR_REGION.ocir.io/$OCI_TENANCY/$OCI_PROJECT_CODE/$IMAGE_NAME:$IMAGE_TAG
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}"
    
:wrench: **Task:** Push the image to OCIR  
:cloud: **Execute on:** Compute instance (dev-vm) 

    docker login -u $OCI_TENANCY/$OCI_USER $OCIR_REGION.ocir.io
    docker push $OCIR_REGION.ocir.io/$OCI_TENANCY/$OCI_PROJECT_CODE/$IMAGE_NAME:$IMAGE_TAG
    exit
    
---
#### SECTION: Container Orchestration ➙ Managed Cluster 
    
:wrench: **Task:** Create a policy     
:computer: **Execute on:** Your machine   
:file_folder: `oci-book/chapter08/3-kubernetes/policies`

    cd ~/git
    cd oci-book/chapter08/3-kubernetes/policies
    TENANCY_OCID=`cat ~/.oci/config | grep tenancy | sed 's/tenancy=//'`
    oci iam policy create -c $TENANCY_OCID --name tenancy-oke --description "OKE Policy"  --statements "file://tenancy.oke.policy.json"
    
:wrench: **Task:** Prepare the infrastructure and launch OKE cluster     
:computer: **Execute on:** Your machine   
:dart: **Context:** Shell with TF_VAR_* environment variables set as in ~/tfvars.env.sh  
:file_folder: `oci-book/chapter08/3-kubernetes/infrastructure`

    cd ~/git/oci-book/chapter08/3-kubernetes/infrastructure
    find . | sort
    source ~/tfvars.env.sh
    terraform init
    terraform apply -auto-approve
    find . -name "*.tf" | sort
    
---
#### SECTION: Container Orchestration ➙ Connecting as superuser

:wrench: **Task:** Create Kubeconfig for the SANDBOX_ADMIN     
:computer: **Execute on:** Your machine   

    REGION=<put-here-your-region-identifier>
    CLUSTER_OCID=`oci ce cluster list --name k8s-cluster --query "data[?name=='k8s-cluster'] | [0].id" --raw-output --profile SANDBOX-ADMIN`
    mkdir ~/.kube
    oci ce cluster create-kubeconfig --cluster-id $CLUSTER_OCID --file ~/.kube/config --region $REGION --profile SANDBOX-ADMIN
    chmod 600 .kube/config
    ls -l .kube | awk '{print $1, $9}'
    
:wrench: **Task:** Copy the Kubeconfig and connect to the dev-vm    
:computer: **Execute on:** Your machine 
    
    scp -i ~/.ssh/oci_id_rsa ~/.kube/config opc@$DEV_VM_PUBLIC_IP:/home/opc/.kube
    ssh -i ~/.ssh/oci_id_rsa opc@$DEV_VM_PUBLIC_IP
    
:wrench: **Task:** Explore OKE instance  
:cloud: **Execute on:** Compute instance (dev-vm)   
:dart: **Context:** `.kube/config` present  

    chmod 600 .kube/config
    ls -l .kube | awk '{print $1, $9}'
    kubectl get nodes -o wide
    kubectl get namespaces
    kubectl get pods -n kube-system
    
:wrench: **Task:** Check Kubernetes API permissions  
:cloud: **Execute on:** Compute instance (dev-vm)  
:dart: **Context:** `.kube/config` present

    kubectl auth can-i create namespace --all-namespaces
    kubectl auth can-i '*' '*' --namespace=default
    kubectl auth can-i '*' '*' --all-namespaces
    
---
#### SECTION: Container Orchestration ➙ Sandbox Namespace

:wrench: **Task:** Create Kubernetes Namespace  
:cloud: **Execute on:** Compute instance (dev-vm)  
:dart: **Context:** `.kube/config` present  
:file_folder: `oci-book/chapter08/3-kubernetes/platform`

    cd oci-book/chapter08/3-kubernetes/platform
    kubectl create -f dev-sandbox-namespace.yaml
    kubectl get namespaces
    kubectl describe namespace dev-sandbox
    exit
    
---
#### SECTION: Container Orchestration ➙ Connecting as developer

:wrench: **Task:** Create a policy     
:computer: **Execute on:** Your machine   
:file_folder: `oci-book/chapter08/3-kubernetes/policies`

    cd ~/git
    cd oci-book/chapter08/3-kubernetes/policies
    TENANCY_OCID=`cat ~/.oci/config | grep tenancy | sed 's/tenancy=//'`
    oci iam policy create --name sandbox-users-containers-policy --description "Containers-related policy for regular Sandbox users"  --statements "file://sandbox-users.containers.policy.json" --profile SANDBOX-ADMIN
    
:wrench: **Task:** Create Kubeconfig for the SANDBOX_USER     
:computer: **Execute on:** Your machine   

    REGION=<put-here-your-region-identifier>
    CLUSTER_OCID=`oci ce cluster list --name k8s-cluster --query "data[?name=='k8s-cluster'] | [0].id" --raw-output --profile SANDBOX-ADMIN`
    oci ce cluster create-kubeconfig --cluster-id $CLUSTER_OCID --file ~/.kube/sandbox-user-config --region $REGION --profile SANDBOX-USER
    chmod 600 ~/.kube/sandbox-user-config
    ls -l ~/.kube | awk '{print $1, $9}'
    
:wrench: **Task:** Copy the Kubeconfig and connect to the dev-vm    
:computer: **Execute on:** Your machine 
    
    scp -i ~/.ssh/oci_id_rsa ~/.kube/sandbox-user-config opc@$DEV_VM_PUBLIC_IP:/home/opc/.kube
    ssh -i ~/.ssh/oci_id_rsa opc@$DEV_VM_PUBLIC_IP 
    
:wrench: **Task:** Try listing all pods in dev-sandbox namespace as SANDBOX_USER     
:cloud: **Execute on:** Compute instance (dev-vm)  
:dart: **Context:** `.kube/sandbox-user-config` present (SANDBOX_USER)

    ls -l ~/.kube | grep config | awk '{print $1, $9}'
    kubectl --kubeconfig ~/.kube/sandbox-user-config get pods -n dev-sandbox
    
:wrench: **Task:** Bind the predefined edit clusterrole for dev-namespace to the SANDBOX_USER     
:cloud: **Execute on:** Compute instance (dev-vm)  
:dart: **Context:** `.kube/config` present (SANDBOX_ADMIN)

    SANDBOX_USER_OCID=<put-here-your-sandbox-user-ocid>
    kubectl create rolebinding sandbox-users-binding --clusterrole=edit --namespace=dev-sandbox --user=$SANDBOX_USER_OCID

:wrench: **Task:** Try listing all pods in dev-sandbox namespace as SANDBOX_USER     
:cloud: **Execute on:** Compute instance (dev-vm)  
:dart: **Context:** `.kube/sandbox-user-config` present (SANDBOX_USER)

    kubectl --kubeconfig ~/.kube/sandbox-user-config get all -n dev-sandbox
    
---
#### SECTION: Container Orchestration ➙ Pods
