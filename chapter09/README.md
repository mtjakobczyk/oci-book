### Practical Oracle Cloud Infrastructure
https://www.apress.com/gp/book/9781484255056  
© Michał Tomasz Jakóbczyk   
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
#### SECTION: Serverless ➙ Oracle Functions ➙ Client Setup

:wrench: **Task:** Identify your tenancy namespace     
:computer: **Execute on:** Your machine   
    
    oci os ns get --query 'data' --raw-output

:wrench: **Task:** Reconnect to the Dev Machine     
:computer: **Execute on:** Your machine   
    
    ssh -i ~/.ssh/oci_id_rsa ubuntu@$DEV_MACHINE_IP

:wrench: **Task:** Create Fn context     
:cloud: **Execute on:** Cloud instance (dev-vm)  

    fn create context sandbox-user-fra-oci --provider oracle

:wrench: **Task:** Edit Fn context     
:cloud: **Execute on:** Cloud instance (dev-vm)  
:pencil: Edit the `~/.fn/contexts/sandbox-user-fra-oci.yaml` as described in the book

    vi ~/.fn/contexts/sandbox-user-fra-oci.yaml

:wrench: **Task:** Create .oci/config     
:cloud: **Execute on:** Cloud instance (dev-vm) 

    mkdir ~/.oci

:wrench: **Task:** Edit .oci/config  
:cloud: **Execute on:** Cloud instance (dev-vm)  
:pencil: Edit the `~/.oci/config` as described in the book

    vi ~/.oci/config

:wrench: **Task:** Upload SANDBOX-USER key, config and connect to the Dev Machine     
:computer: **Execute on:** Your machine

    scp -i ~/.ssh/oci_id_rsa ~/.apikeys/api.sandbox-user.pem ubuntu@$DEV_MACHINE_IP:/home/ubuntu
    ssh -i ~/.ssh/oci_id_rsa ubuntu@$DEV_MACHINE_IP

:wrench: **Task:** Place API Key and config in proper folders   
:cloud: **Execute on:** Cloud instance (dev-vm) 

    mkdir ~/.apikeys
    mv ~/api.sandbox-user.pem ~/.apikeys/api.sandbox-user.pem
    chmod go-rwx ~/.apikeys/api.sandbox-user.pem

:wrench: **Task:** Set Oracle Functions context as current and test connectivity   
:cloud: **Execute on:** Cloud instance (dev-vm) 

    fn use context sandbox-user-fra-oci
    fn list apps

---
#### SECTION: Serverless ➙ Oracle Functions ➙ Deploying UUID function

:wrench: **Task:** Read the subnet OCID   
:computer: **Execute on:** Your machine  
:file_folder: `oci-book/chapter09/1-infrastructure`

    cd ~/git/oci-book/chapter09/1-infrastructure
    terraform output functions_subnet_ocid

:wrench: **Task:** Create application in Oracle Functions   
:cloud: **Execute on:** Cloud instance (dev-vm) 

    FN_SUBNET_ID=<put-here-subnet-ocid>
    fn create app uuidcloudapp --annotation oracle.com/oci/subnetIds="[\"$FN_SUBNET_ID\"]"

:wrench: **Task:** Login to OCIR   
:cloud: **Execute on:** Cloud instance (dev-vm) 

    OCI_TENANCY_NAMESPACE=<put-here-your-tenancy-namespace>
    OCIR_REGION=<put-here-your-ocir-region-code>
    OCI_USER=sandbox-user
    docker login -u $OCI_TENANCY_NAMESPACE/$OCI_USER $OCIR_REGION.ocir.io
    
:wrench: **Task:** Deploy function manifest and push image to OCIR   
:cloud: **Execute on:** Cloud instance (dev-vm)  
:file_folder: `~/uuidfn/`

    cd ~/uuidfn
    fn -v deploy --app uuidcloudapp --no-bump

:wrench: **Task:** Inspect Oracle Function   
:cloud: **Execute on:** Cloud instance (dev-vm)

    fn list apps
    fn inspect app uuidcloudapp
    
:wrench: **Task:** Testing Oracle Function   
:cloud: **Execute on:** Cloud instance (dev-vm)

    fn invoke uuidcloudapp uuidfn
    echo -n '{ "client_name": "some_app"  }' | fn invoke uuidcloudapp uuidfn --content-type application/json
    fn invoke uuidcloudapp uuidfn
    fn invoke uuidcloudapp uuidfn
   
:wrench: **Task:** Listing Oracle Function endpoint   
:cloud: **Execute on:** Cloud instance (dev-vm)

    fn inspect function uuidcloudapp uuidfn | jq -r '.annotations."fnproject.io/fn/invokeEndpoint"'
    
---
#### SECTION: Events ➙ Functions and Object Storage ➙ Preparing Infrastructure

:wrench: **Task:** Create Object Storage bucket for reports   
:computer: **Execute on:** Your machine  

    oci os bucket create --name reports --profile SANDBOX-ADMIN

:wrench: **Task:** IAM Policy statement for object storage   
:computer: **Execute on:** Your machine  
:file_folder: `oci-book/chapter09/4-events/policies`

    cd ~/git/oci-book/chapter09/4-events/policies
    oci iam policy create --name sandbox-users-storage-reports-policy --statements file://sandbox-users.policies.storage-reports.json --description "Storage-related (reports) policy for regular Sandbox users" --profile SANDBOX-ADMIN

:wrench: **Task:** Put a test file to the bucket   
:computer: **Execute on:** Your machine  
:file_folder: `oci-book/chapter09/4-events/reports`

    cd ~/git/oci-book/chapter09/4-events/reports
    oci os object put -bn reports --file customer_attendance.20190922.raw.csv --profile SANDBOX-USER

:wrench: **Task:** Create tag key inside the existing tag namespace   
:computer: **Execute on:** Your machine 

    TAG_NAMESPACE_OCID=`oci iam tag-namespace list --query "data[?name=='test-projects'] | [0].id" --raw-output`
    echo $TAG_NAMESPACE_OCID
    oci iam tag create --tag-namespace-id $TAG_NAMESPACE_OCID --name reports --description "Reports project" --profile SANDBOX-ADMIN

:wrench: **Task:** Dynamic Group for tagged functions   
:computer: **Execute on:** Your machine 

    echo $TENANCY_OCID
    MATCHING_RULE="ALL {resource.type = 'fnfunc', tag.test-projects.reports.value}"
    oci iam dynamic-group create --name reporting-functions --description "Functions related to the reporting project" --matching-rule "$MATCHING_RULE" -c $TENANCY_OCID

:wrench: **Task:** Dynamic Group for tagged functions   
:computer: **Execute on:** Your machine  
:file_folder: `oci-book/chapter09/4-events/policies`

    cd ~/git/oci-book/chapter09/4-events/policies
    oci iam policy create --name functions-storage-reports-policy --statements file://functions.policies.storage-reports.json --description "Storage-related (reports) policy for tagged functions" --profile SANDBOX-ADMIN

---
#### SECTION: Events ➙ Functions and Object Storage ➙ Deploying function

:wrench: **Task:** Initialize application in Oracle Functions   
:cloud: **Execute on:** Cloud instance (dev-vm)

    cd ~
    fn init --runtime python reportingfn
    cp ~/functions/reportingfn.py ~/reportingfn/func.py
    echo -ne "\noci" >> ~/reportingfn/requirements.txt

:wrench: **Task:** Login to OCIR   
:cloud: **Execute on:** Cloud instance (dev-vm) 

    OCI_TENANCY_NAMESPACE=<put-here-your-tenancy-namespace>
    OCIR_REGION=<put-here-your-ocir-region-code>
    OCI_USER=sandbox-user
    docker login -u $OCI_TENANCY_NAMESPACE/$OCI_USER $OCIR_REGION.ocir.io
    
:wrench: **Task:** Create application in Oracle Functions   
:cloud: **Execute on:** Cloud instance (dev-vm)

    FN_SUBNET_ID=<put-here-subnet-ocid>
    fn create app reportingapp --annotation oracle.com/oci/subnetIds="[\"$FN_SUBNET_ID\"]"

:wrench: **Task:** Deploy application to Oracle Functions   
:cloud: **Execute on:** Cloud instance (dev-vm)  
:file_folder: `~/reportingfn/`
    
    cd ~/reportingfn/
    fn -v deploy --app reportingapp

:wrench: **Task:** Tag function with the defined tag key   
:computer: **Execute on:** Your machine

    FN_APP_OCID=`oci fn application list --query "data[?\"display-name\" == 'reportingapp'] | [0].id" --raw-output`
    echo $FN_APP_OCID
    FN_FUN_OCID=`oci fn function list --application-id $FN_APP_OCID --query "data[?\"display-name\" == 'reportingfn'] | [0].id" --raw-output`
    echo $FN_FUN_OCID
    oci fn function update --function-id $FN_FUN_OCID --defined-tags '{ "test-projects": {"reports": ""} }'

---
#### SECTION: Events ➙ Events as function triggers

:wrench: **Task:** Trigger function using event mock   
:cloud: **Execute on:** Cloud instance (dev-vm) 

    cat ~/event.mock.json | fn invoke reportingapp reportingfn --content-type application/json

---
#### SECTION: Events ➙ Oracle Events

:wrench: **Task:** Let Oracle Events trigger Oracle Functions   
:computer: **Execute on:** Your machine  
:file_folder: `oci-book/chapter09/4-events/policies`

    cd ~/git/oci-book/chapter09/4-events/policies
    oci iam policy create --name cloudevents-policy --statements file://cloudevents.policies.json --description "Functions-related policy for CloudEvents" --profile SANDBOX-ADMIN

:warning: Make sure you enable emitting events on the `reports` bucket as described in the book

:wrench: **Task:** Create Oracle Events rule   
:computer: **Execute on:** Your machine  
:file_folder: `oci-book/chapter09/4-events/policies` 

    cd ~/git/oci-book/chapter09/4-events/events
    echo $FN_FUN_OCID
    cat oracleevents.actions.template.json | sed -e "s/PUT_HERE_FUNCTION_ID/$FN_FUN_OCID/g" > oracleevents.actions.json
    SERIALIZED_CONDITIONS=`cat oracleevents.conditions.json | sed 's/"/\\"/g' | sed 's/[[:space:]]//g' | tr -d '\n'`
    oci events rule create --display-name new-reports --is-enabled true --condition $SERIALIZED_CONDITIONS --actions file://oracleevents.actions.json
    
:wrench: **Task:** Put a two more test files to the bucket   
:computer: **Execute on:** Your machine  
:file_folder: `oci-book/chapter09/4-events/reports`

    cd ~/git/oci-book/chapter09/4-events/reports
    oci os object put -bn reports --file customer_attendance.20190923.raw.csv --profile SANDBOX-USER
    oci os object put -bn reports --file customer_attendance.20190924.raw.csv --profile SANDBOX-USER
    
---
#### SECTION: Cleanup

:wrench: **Task:** Delete the reports bucket and its contents     
:computer: **Execute on:** Your machine  

    oci os object bulk-delete -bn reports
    oci os bucket delete -bn reports
    
:wrench: **Task:** Delete functions from Oracle Functions  
:computer: **Execute on:** Your machine  

    FN_APP_OCID=`oci fn application list --query "data[?\"display-name\" == 'reportingapp'] | [0].id" --raw-output`
    FN_FUN_OCID=`oci fn function list --application-id $FN_APP_OCID --query "data[?\"display-name\" == 'reportingfn'] | [0].id" --raw-output`
    oci fn function delete --function-id $FN_FUN_OCID
    oci fn application delete --application-id $FN_APP_OCID
    FN_APP_OCID=`oci fn application list --query "data[?\"display-name\" == 'uuidcloudapp'] | [0].id" --raw-output`
    FN_FUN_OCID=`oci fn function list --application-id $FN_APP_OCID --query "data[?\"display-name\" == 'uuidfn'] | [0].id" --raw-output`
    oci fn function delete --function-id $FN_FUN_OCID
    oci fn application delete --application-id $FN_APP_OCID

:wrench: **Task:** Delete Oracle Events rule  
:computer: **Execute on:** Your machine  

    EVENTRULE_OCID=`oci events rule list --query "data[?\"display-name\" == 'new-reports'] | [0].id" --raw-output`
    oci events rule delete --rule-id $EVENTRULE_OCID
    Are you sure you want to delete this resource? [y/N]: y

:wrench: **Task:** dev-vm cleanup     
:computer: **Execute on:** Your machine  
:dart: **Context:** Shell with `TF_VAR_*` environment variables set as in `~/tfvars.env.sh`  
:file_folder: `oci-book/chapter09/1-infrastructure`

    source ~/tfvars.env.sh
    cd ~/git
    cd oci-book/chapter09/1-infrastructure
    terraform destroy -auto-approve
