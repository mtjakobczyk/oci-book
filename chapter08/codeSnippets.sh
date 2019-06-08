# PRACTICAL ORACLE CLOUD Infrastructure
# CHAPTER 08 - Code Snippets

# SECTION: Containerize an application

##
### bash / OCI CLI

cd uuidservice

## Build images
### bash
docker build -t uuid:1.0 .
docker images

## Open ports in operating system firewall
### bash
sudo firewall-cmd --zone=public --permanent --add-port=5010-5019/tcp
sudo firewall-cmd --reload
sudo firewall-cmd --zone=public --list-ports

## Launch containers
### bash
docker run -d -p 5011:5000 -e "UUID_GENERATOR_NAME=uuid-1"  --name uuid-1 uuid:1.0
docker run -d -p 5012:5000 -e "UUID_GENERATOR_NAME=uuid-2"  --name uuid-2 uuid:1.0
docker run -d -p 5013:5000 -e "UUID_GENERATOR_NAME=uuid-3"  --name uuid-3 uuid:1.0
docker ps

## Test containers
### bash
curl 127.0.0.1:5011/identifiers
curl 127.0.0.1:5012/identifiers
curl 127.0.0.1:5013/identifiers

# SECTION: Docker Registry
##
# Policy must be created by superuser and placed in root compartment (because OCIR is cross-compartment)
cat /Users/mjk/.oci/config | grep tenancy
TENANCY_OCID={put-here-your-tenancy-ocid}
cd 2-docker/policies
oci iam policy create -c $TENANCY_OCID --name sandbox-ocir --description "OCIR Sandbox"  --statements "file://sandbox-users.policies.json"

# Generate token for a user
oci iam user list -c $TENANCY_OCID --query "data[?name=='sandbox-user'].{Name:name,OCID:id}" --all
IAM_USER_OCID=ocid1.user.oc1..aaaaaaaatimmpj37aonepsmxasb5kx7ifnvqyoktim4cvsdhwumohcdzqpxa
oci iam auth-token create --user-id $IAM_USER_OCID --description Token-1 | grep token

## Push into new OCIR-based private repository
OCI_USER_TOKEN={put-here-your-token}
OCI_PROJECT_CODE=sandbox
OCI_TENANCY={put-here-your-tenancy-name}
OCIR_REGION={put-here-your-ocir-region-code}
OCI_USER=sandbox-user
IMAGE_NAME=uuid
IMAGE_TAG=:1.0

docker tag $IMAGE_NAME:$IMAGE_TAG $OCIR_REGION.ocir.io/$OCI_TENANCY/$OCI_PROJECT_CODE/$IMAGE_NAME:$IMAGE_TAG
docker login -u $OCI_TENANCY/$OCI_USER $OCIR_REGION.ocir.io
### You will be prompted for the auth token here
docker push $OCIR_REGION.ocir.io/$OCI_TENANCY/$OCI_PROJECT_CODE/$IMAGE_NAME:$IMAGE_TAG


# SECTION: Managed Cluster
##
## Effectively enable OKE
cat /Users/mjk/.oci/config | grep tenancy
TENANCY_OCID={put-here-your-tenancy-ocid}
cd 3-kubernetes/policies
oci iam policy create -c $TENANCY_OCID --name tenancy-oke --description "OKE for Tenancy"  --statements "file://oke-tenancy.policies.json"

## Preparing infrastructure and launching cluster
cd 3-kubernetes/infrastructure
terraform init
terraform apply

# SECTION: Connecting to K8s
##
# kubectl is already installed on dev vm
# Dev VM is in an other VCN that is not connected to the Kube VCN
# https://kubernetes.io/docs/tasks/tools/install-kubectl/

# Fetch kubeconfig (on a machine with OCI CLI)
oci ce cluster list --name k8s-cluster --query "data[?name=='k8s-cluster'].{Name:name,OCID:id}"
CLUSTER_OCID={put-here-your-cluster-ocid}
REGION=eu-frankfurt-1
mkdir ~/.kube
oci ce cluster create-kubeconfig --cluster-id $CLUSTER_OCID --file ~/.kube/config --region $REGION
# token decoded (base64) shows the OCID of api-user IAM user > verify with chapter 4 whether api-user was created

# Optionally upload kube config to Dev VM
scp -i ~/.ssh/oci_id_rsa ~/.kube/config opc@$DEV_VM_PUBLIC_IP:/home/opc/.kube

# Verify connectivity
kubectl get nodes -o wide
kubectl get namespaces
kubectl get pods -n kube-system

# SECTION: Preparing Kubernetes Namespace and RBAC
##
# Create dev-sandbox namespace
cd 3-kubernetes/platform
kubectl create -f dev-sandbox-namespace.yaml
kubectl get namespaces

# sandbox-user downloads his own kube config using OCI CLI
CLUSTER_OCID={put-here-your-cluster-ocid}
REGION=eu-frankfurt-1
oci ce cluster create-kubeconfig --cluster-id $CLUSTER_OCID --file ~/.kube/sandbox-user-config --region $REGION --profile SANDBOX-USER
# token decoded (base64) shows the OCID of sandbox-user IAM user
# Optionally upload kube config to Dev VM
scp -i ~/.ssh/oci_id_rsa ~/.kube/sandbox-user-config opc@$DEV_VM_PUBLIC_IP:/home/opc/.kube

kubectl --kubeconfig ~/.kube/sandbox-user-config get services -n dev-sandbox # Fail :)

# Bind the predefined edit clusterrole for dev-namespace to the sandbox-user User
# https://kubernetes.io/docs/reference/access-authn-authz/rbac/#default-roles-and-role-bindings
SANDBOX_USER_OCID={put-here-your-sandbox-user-ocid}
kubectl create rolebinding sandbox-users-binding --clusterrole=edit --namespace=dev-sandbox --user=$SANDBOX_USER_OCID
kubectl --kubeconfig ~/.kube/sandbox-user-config get services -n dev-sandbox # Success :)

# SECTION: Deployment, Service, Pods
##
