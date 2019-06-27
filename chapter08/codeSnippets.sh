# PRACTICAL ORACLE CLOUD INFRASTRUCTURE
# CHAPTER 08 - Code Snippets

# SECTION: Containerize an application

## Optionally: provision a Dev Machine
### bash
cd ~/git
cd oci-book/chapter08/1-devmachine
find . \( -name "*.tf" -o -name "*.yaml" \) | sort
terraform init
terraform apply

## Optionally: connect to the Dev Machine
### bash
ssh -i ~/.ssh/oci_id_rsa opc@130.61.X.X
sudo cat /var/log/cloud-init.log | grep "DEV machine is running"

## Verify Docker runtime and objects
### bash (on cloud-based devmachine or your local developer machine)
docker images
docker ps
docker info

## Build images
### bash (on cloud-based devmachine or your local developer machine)
#### Clone code from GitHub
cd oci-book/chapter08/2-docker
cd uuid-service
ls -1
docker build -t uuid:1.0 .
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}"

## Launch containers
### bash (on cloud-based devmachine or your local developer machine)
docker run -d -p 5011:5000 -e "UUID_GENERATOR_NAME=uuid-1"  --name uuid-1 uuid:1.0
docker run -d -p 5012:5000 -e "UUID_GENERATOR_NAME=uuid-2"  --name uuid-2 uuid:1.0
docker run -d -p 5013:5000 -e "UUID_GENERATOR_NAME=uuid-3"  --name uuid-3 uuid:1.0
docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"

## Test containers
### bash (on cloud-based devmachine or your local developer machine)
curl 127.0.0.1:5011/identifiers
curl 127.0.0.1:5012/identifiers
curl 127.0.0.1:5013/identifiers


# SECTION: Docker Registry

# Create a policy
### bash
cd ~/git
cd oci-book/chapter08/2-docker
cd policies
ls -1
cat ~/.oci/config | grep tenancy
TENANCY_OCID={put-here-your-tenancy-ocid}
oci iam policy create -c $TENANCY_OCID --name tenancy-ocir-policy --description "OCIR Polices"  --statements "file://tenancy.ocir.policies.json"

# Generate token for a user
### bash
oci iam user list -c $TENANCY_OCID --query "data[?name=='sandbox-user'].{Name:name,OCID:id}" --all
IAM_USER_OCID={put-here-the-user-ocid}
oci iam auth-token create --user-id $IAM_USER_OCID --description Token-1 | grep token

## Push into new OCIR-based private repository
### bash (on cloud-based devmachine or your local developer machine)
OCI_PROJECT_CODE=sandbox
OCI_TENANCY={put-here-your-tenancy-name}
OCIR_REGION={put-here-your-ocir-region-code}
OCI_USER=sandbox-user
IMAGE_NAME=uuid
IMAGE_TAG=1.0

docker tag $IMAGE_NAME:$IMAGE_TAG $OCIR_REGION.ocir.io/$OCI_TENANCY/$OCI_PROJECT_CODE/$IMAGE_NAME:$IMAGE_TAG
docker login -u $OCI_TENANCY/$OCI_USER $OCIR_REGION.ocir.io
# provide the token on prompt
docker push $OCIR_REGION.ocir.io/$OCI_TENANCY/$OCI_PROJECT_CODE/$IMAGE_NAME:$IMAGE_TAG


# SECTION: Managed Cluster
##
## Effectively enable OKE
cat ~/.oci/config | grep tenancy
TENANCY_OCID={put-here-your-tenancy-ocid}
cd ~/git
cd oci-book/chapter08/3-kubernetes
cd policies
oci iam policy create -c $TENANCY_OCID --name tenancy-oke --description "OKE Policy"  --statements "file://tenancy.oke.policy.json"

## Preparing infrastructure and launching cluster
cd ~/git
cd oci-book/chapter08/3-kubernetes
cd infrastructure
find . | sort
source ~/tfvars.env.sh
terraform init
terraform apply -auto-approve

find . -name "*.tf" | sort

# SECTION: Connecting to K8s
##

# Fetch kubeconfig (on a machine with OCI CLI)
# bash
oci ce cluster list --name k8s-cluster --query "data[?name=='k8s-cluster'].{Name:name,OCID:id}" --profile SANDBOX-ADMIN
CLUSTER_OCID={put-here-your-cluster-ocid}
REGION={put-here-your-region}
mkdir ~/.kube
oci ce cluster create-kubeconfig --cluster-id $CLUSTER_OCID --file ~/.kube/config --region $REGION --profile SANDBOX-ADMIN
chmod 600 .kube/config
ls -l .kube | awk '{print $1, $9}'

# Optionally upload kube config to Dev VM
# bash
DEV_VM_PUBLIC_IP=130.61.X.X
scp -i ~/.ssh/oci_id_rsa ~/.kube/config opc@$DEV_VM_PUBLIC_IP:/home/opc/.kube
ssh -i ~/.ssh/oci_id_rsa opc@$DEV_VM_PUBLIC_IP
### bash (on cloud-based devmachine or your local developer machine)
chmod 600 .kube/config
ls -l .kube | awk '{print $1, $9}'

# Verify connectivity
# bash (on cloud-based devmachine or your local developer machine)
kubectl get nodes -o wide
kubectl get namespaces
kubectl get pods -n kube-system

# Check Kubernetes API permissions
# bash (on cloud-based devmachine or your local developer machine)
kubectl auth can-i create namespace --all-namespaces
kubectl auth can-i '*' '*' --namespace=default
kubectl auth can-i '*' '*' --all-namespaces

# SECTION: Sandbox namespace
##

# Create Kubernetes Namespace
# bash (on cloud-based devmachine or your local developer machine)
cd oci-book/chapter08/3-kubernetes/platform
kubectl create -f dev-sandbox-namespace.yaml
namespace/dev-sandbox created
kubectl get namespaces
kubectl describe namespace dev-sandbox
exit

# SECTION: Connecting as developer
##

## sandbox-users
# bash
cat ~/.oci/config | grep tenancy
TENANCY_OCID={put-here-your-tenancy-ocid}
cd ~/git
cd oci-book/chapter08/3-kubernetes
cd policies
oci iam policy create --name sandbox-users-containers-policy --description "Containers-related policy for regular Sandbox users"  --statements "file://sandbox-users.containers.policy.json" --profile SANDBOX-ADMIN

# sandbox-user downloads his own kube config using OCI CLI
# bash
oci ce cluster list --name k8s-cluster --query "data[?name=='k8s-cluster'].{Name:name,OCID:id}" --profile SANDBOX-USER
CLUSTER_OCID={put-here-your-cluster-ocid}
REGION={put-here-your-region}
oci ce cluster create-kubeconfig --cluster-id $CLUSTER_OCID --file ~/.kube/sandbox-user-config --region $REGION --profile SANDBOX-USER
chmod 600 ~/.kube/sandbox-user-config
ls -l ~/.kube | awk '{print $1, $9}'
# Optionally upload kube config to Dev VM
DEV_VM_PUBLIC_IP=130.61.X.X
scp -i ~/.ssh/oci_id_rsa ~/.kube/sandbox-user-config opc@$DEV_VM_PUBLIC_IP:/home/opc/.kube
ssh -i ~/.ssh/oci_id_rsa opc@$DEV_VM_PUBLIC_IP
### bash (on cloud-based devmachine or your local developer machine)
ls -l ~/.kube | grep config | awk '{print $1, $9}'

# Try listing all objects in dev-sandbox
# bash (on cloud-based devmachine or your local developer machine)
kubectl --kubeconfig ~/.kube/sandbox-user-config get pods -n dev-sandbox # Fail :)

# Bind the predefined edit clusterrole for dev-namespace to the sandbox-user User
# https://kubernetes.io/docs/reference/access-authn-authz/rbac/#default-roles-and-role-bindings
SANDBOX_USER_OCID={put-here-your-sandbox-user-ocid}
kubectl create rolebinding sandbox-users-binding --clusterrole=edit --namespace=dev-sandbox --user=$SANDBOX_USER_OCID
kubectl --kubeconfig ~/.kube/sandbox-user-config get all -n dev-sandbox # Success :)

# SECTION: Deployment, Service, Pods
##

# Set .kube/config using environment variable
# bash (on cloud-based devmachine or your local developer machine)
export KUBECONFIG=~/.kube/sandbox-user-config

# Create a secret within a namespace to access OCIR private repository
# bash (on cloud-based devmachine or your local developer machine)
OCI_TENANCY={put-here-your-tenancy-name}
OCIR_REGION={put-here-your-ocir-region-code}
OCI_USER=sandbox-user
OCI_USER_TOKEN={put-here-sandbox-user-auth-token}
kubectl create secret \
  docker-registry sandbox-user-secret --docker-server=$OCIR_REGION.ocir.io \
  --docker-username="$OCI_TENANCY/$OCI_USER" \
  --docker-password="$OCI_USER_TOKEN" -n dev-sandbox

# Create a Pod
# bash (on cloud-based devmachine or your local developer machine)
cd oci-book/chapter08/3-kubernetes/platform
kubectl create -f uuid-pod.yaml -n dev-sandbox
kubectl get pods -n dev-sandbox

# Delete the Pod
# bash (on cloud-based devmachine or your local developer machine)
kubectl  delete pod uuid-pod -n dev-sandbox

# Create a deployment
# bash (on cloud-based devmachine or your local developer machine)
kubectl create -f uuid-deployment.yaml -n dev-sandbox
kubectl get pods -n dev-sandbox  -o wide
kubectl get replicasets -n dev-sandbox
kubectl get services -n dev-sandbox
exit

# Test the API and observe the generator field
# bash
LB_PUBLIC_IP=132.145.X.X
for i in {1..10}; do curl $LB_PUBLIC_IP:80/identifiers; done

# Cleanup
# bash
DEV_VM_PUBLIC_IP=130.61.X.X
ssh -i ~/.ssh/oci_id_rsa opc@$DEV_VM_PUBLIC_IP
### bash (on cloud-based devmachine or your local developer machine)
export KUBECONFIG=~/.kube/sandbox-user-config
kubectl delete all --all -n dev-sandbox
exit
