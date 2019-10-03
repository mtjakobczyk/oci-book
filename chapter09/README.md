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
    
---
#### SECTION: Serverless ➙ Fn Project ➙ Installation and Configuration

:wrench: **Task:** Install and start Fn Project     
:cloud: **Execute on:** Cloud instance (dev-vm)

    curl -LSs https://raw.githubusercontent.com/fnproject/cli/master/install | sh
    fn version
    fn start -d

:wrench: **Task:** Inspect local installation     
:cloud: **Execute on:** Cloud instance (dev-vm)

    docker images
    docker ps
    docker logs fnserver
    
:wrench: **Task:** Configure Fn Project for local development     
:cloud: **Execute on:** Cloud instance (dev-vm)

    fn list contexts
    fn use context default
    fn update context registry localdev
    fn list contexts

---
#### SECTION: Serverless ➙ Fn Project ➙ Your first function

:wrench: **Task:** Initialize Python-based Fn project (Blank function)     
:cloud: **Execute on:** Cloud instance (dev-vm)

    fn init --runtime python blankfn
    tree ~/blankfn/
    cp ~/functions/blankfn.py ~/blankfn/func.py

:wrench: **Task:** Create Fn application (Blank function)     
:cloud: **Execute on:** Cloud instance (dev-vm)

    fn create app blankapp
    fn list apps

:wrench: **Task:** Build Fn function (Blank function)     
:cloud: **Execute on:** Cloud instance (dev-vm)  
:file_folder: `~/blankfn`

    cd ~/blankfn
    fn --verbose deploy --app blankapp --local

:wrench: **Task:** Inspect Fn function (Blank function)     
:cloud: **Execute on:** Cloud instance (dev-vm)

    fn list functions blankapp
    docker images | grep blank
    docker ps --format '{{.Names}} [{{.Image}}] {{.Status}}'

:wrench: **Task:** Test Fn function locally (Blank function)     
:cloud: **Execute on:** Cloud instance (dev-vm)

    fn invoke blankapp blankfn
    docker ps --format '{{.Names}} [{{.Image}}] {{.Status}}'
    fn invoke blankapp blankfn &
    fn invoke blankapp blankfn &

---
#### SECTION: Serverless ➙ Fn Project ➙ UUID function

:wrench: **Task:** Initialize Fn project  (UUID Generator)     
:cloud: **Execute on:** Cloud instance (dev-vm)

    cd ~
    fn init --runtime python uuidfn
    cp ~/functions/uuidfn.py ~/uuidfn/func.py

:wrench: **Task:** Create Fn application (UUID Generator)     
:cloud: **Execute on:** Cloud instance (dev-vm)

    fn create app uuidapp
    fn list apps

:wrench: **Task:** Build Fn function (UUID Generator)     
:cloud: **Execute on:** Cloud instance (dev-vm)
:file_folder: `~/uuidfn`

    cd ~/uuidfn/
    fn --verbose deploy --app uuidapp --local

:wrench: **Task:** Test Fn function locally (UUID Generator)     
:cloud: **Execute on:** Cloud instance (dev-vm)

    fn invoke uuidapp uuidfn
    echo -n '{ "client_name": "some_app"  }' | fn invoke uuidapp uuidfn --content-type application/json
    fn inspect function uuidapp uuidfn
    FN_INVOKE_ENDPOINT=`fn inspect function uuidapp uuidfn | jq -r '.annotations."fnproject.io/fn/invokeEndpoint"'`
    curl -X "POST" -H "Content-Type: application/json" $FN_INVOKE_ENDPOINT

---
#### SECTION: Serverless ➙ Oracle Functions ➙ OCI Networking and Policies

:wrench: **Task:** Create FaaS and function developer policies     
:computer: **Execute on:** Your machine  
:file_folder: `oci-book/chapter09/3-functions/policies`

    cd ~/git/oci-book/chapter09/3-functions/policies
    TENANCY_OCID=`cat ~/.oci/config | grep tenancy | sed 's/tenancy=//'`
    oci iam policy create -c $TENANCY_OCID --name functions-policy --description "FaaS Policy" --statements "file://tenancy.functions.policy.json"
    oci iam policy create --name sandbox-users-functions-policy --description "Functions-related policy for regular Sandbox users" --statements "file://sandbox-users.functions.policy.json" --profile SANDBOX-ADMIN

---
#### SECTION: Serverless ➙ Oracle Functions ➙ Development Client

:wrench: **Task:** Create context, OCI config     
:computer: **Execute on:** Your machine  
:file_folder: `oci-book/chapter09/3-functions/policies`

    fn create context sandbox-user-fra-oci --provider oracle
    vi ~/.fn/contexts/sandbox-user-fra-oci.yaml
