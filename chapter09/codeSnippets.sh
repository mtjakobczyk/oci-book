# PRACTICAL ORACLE CLOUD Infrastructure
# CHAPTER 09 - Code Snippets

# SECTION: Serverless > Developer VM

## Provision a Dev Machine
### bash
cd ~/git/oci-book/chapter09/1-infrastructure
find . \( -name "*.tf" -o -name "*.yaml" \) | sort
source ~/tfvars.env.sh
terraform init
terraform apply

## Connect to the Dev Machine
### bash
DEV_MACHINE_IP=`terraform output dev_machine_public_ip`
ssh -i ~/.ssh/oci_id_rsa ubuntu@$DEV_MACHINE_IP
# (on cloud-based VM)
sudo cat /var/log/syslog | grep "DEV machine"


# SECTION: Serverless > Fn Project > Installation and configuration

## Install and start Fn Project
### bash (on cloud-based VM)
curl -LSs https://raw.githubusercontent.com/fnproject/cli/master/install | sh
fn version
fn start -d

## Inspect local installation
### bash (on cloud-based VM)
docker images
docker ps
docker logs fnserver


## Configure Fn Project for local development
### bash (on cloud-based VM)
fn list contexts
fn use context default
fn update context registry fndemouser
fn list contexts


# SECTION: Serverless > Fn Project > Your first function

## Initialize Python-based Fn project (Blank function)
### bash (on cloud-based VM)
fn init --runtime python blankfn
tree ~/blankfn/
cp ~/functions/blankfn.py ~/blankfn/func.py

## Create Fn application (Blank function)
### bash (on cloud-based VM)
fn create app blankapp
fn list apps

## Build Fn function (Blank function)
### bash (on cloud-based VM)
cd ~/blankfn
fn --verbose deploy --app blankapp --local

## Inspect Fn function (Blank function)
### bash (on cloud-based VM)
fn list functions blankapp
docker images | grep blank

## Test Fn function locally (Blank function)
### bash (on cloud-based VM)
fn invoke blankapp blankfn
watch docker ps


# SECTION: Serverless > Fn Project > UUID Generator function

## Initialize Fn project  (UUID Generator)
### bash (on cloud-based VM)
cd ~
fn init --runtime python uuidfn
cp ~/functions/uuidfn.py ~/uuidfn/func.py

## Create Fn application (UUID Generator)
### bash (on cloud-based VM)
fn create app uuidapp
fn list functions uuidapp

## Build Fn function (UUID Generator)
### bash (on cloud-based VM)
cd ~/uuidfn/
fn --verbose deploy --app uuidapp --local

## Test Fn function locally (UUID Generator)
### bash (on cloud-based VM)
fn invoke uuidapp uuidfn
echo -n '{ "client_name": "some_app"  }' | fn invoke uuidapp uuidfn --content-type application/json
fn inspect function uuidapp uuidfn
FN_INVOKE_ENDPOINT=`fn inspect function uuidapp uuidfn | jq -r '.annotations."fnproject.io/fn/invokeEndpoint"'`
curl -X "POST" -H "Content-Type: application/json" $FN_INVOKE_ENDPOINT


# SECTION: Serverless > Oracle Functions > OCI Networking and Policies

## Create FaaS and function developer policies
### bash
cd ~/git/oci-book/chapter09/3-functions/policies
cat ~/.oci/config | grep tenancy
TENANCY_OCID={put-here-your-tenancy-ocid}
oci iam policy create -c $TENANCY_OCID --name functions-policy --description "FaaS Policy" --statements "file://tenancy.functions.policy.json"
oci iam policy create --name sandbox-users-functions-policy --description "Functions-related policy for regular Sandbox users" --statements "file://sandbox-users.functions.policy.json" --profile SANDBOX-ADMIN

# SECTION: Serverless > Oracle Functions > Development Client

## Create context, OCI config
### bash (on cloud-based VM)
fn create context sandbox-user-fra-oci --provider oracle
# Edit the ~/.fn/contexts/sandbox-user-fra-oci.yaml file as described in the book
mkdir ~/.oci
touch ~/.oci/config
# Edit the ~/.oci/config file as described in the book

## Upload SANDBOX-USER key, config and connect to the Dev Machine
### bash
cd ~/git/oci-book/chapter09/1-infrastructure
DEV_MACHINE_IP=`terraform output dev_machine_public_ip`
scp -i ~/.ssh/oci_id_rsa ~/.apikeys/api.sandbox-user.pem ubuntu@$DEV_MACHINE_IP:/home/ubuntu

## Place API Key and config in proper folders
### bash (on cloud-based VM)
mkdir ~/.apikeys
mv ~/api.sandbox-user.pem ~/.apikeys/api.sandbox-user.pem
chmod go-rwx ~/.apikeys/api.sandbox-user.pem

## Set Oracle Functions context as current and test connectivity
### bash (on cloud-based VM)
fn use context sandbox-user-fra-oci
fn list apps

# SECTION: Serverless > Oracle Functions > Deploy function

## Create application in Oracle Functions
### bash
cd ~/git/oci-book/chapter09/1-infrastructure
terraform output functions_subnet_ocid
### bash (on cloud-based VM)
FN_SUBNET_ID={put-here-subnet-ocid}
fn create app uuidcloudapp --annotation oracle.com/oci/subnetIds="[\"$FN_SUBNET_ID\"]"

## Login to OCIR
### bash (on cloud-based VM)
OCI_TENANCY={put-here-your-tenancy-name}
OCIR_REGION={put-here-your-ocir-region-code}
OCI_USER=sandbox-user
docker login -u $OCI_TENANCY/$OCI_USER $OCIR_REGION.ocir.io

## Deploy function manifest and push image to OCIR
### bash (on cloud-based VM)
cd ~/uuidfn
fn -v deploy --app uuidcloudapp --no-bump

## Inspect Oracle Function
### bash (on cloud-based VM)
fn list apps
fn inspect app uuidcloudapp

## Testing Oracle Function
### bash (on cloud-based VM)
fn invoke uuidcloudapp uuidfn
echo -n '{ "client_name": "some_app"  }' | fn invoke uuidcloudapp uuidfn --content-type application/json
fn invoke uuidcloudapp uuidfn
fn invoke uuidcloudapp uuidfn

## Listing Oracle Function endpoint
### bash (on cloud-based VM)
fn inspect function uuidcloudapp uuidfn | jq -r '.annotations."fnproject.io/fn/invokeEndpoint"'


# SECTION: Events > Functions and Object Storage > Preparing infrastructure

# Create Object Storage bucket for reports
### bash
oci os bucket create --name reports --profile SANDBOX-ADMIN

## IAM Policy statement for object storage
### bash
cd ~/git/oci-book/chapter09/4-events/policies
oci iam policy create --name sandbox-users-storage-reports-policy --statements file://sandbox-users.policies.storage-reports.json --description "Storage-related (reports) policy for regular Sandbox users" --profile SANDBOX-ADMIN

## Put a test file to the bucket
### bash
cd ~/git/oci-book/chapter09/4-events/reports
oci os object put -bn reports --file customer_attendance.20190922.raw.csv --profile SANDBOX-USER

## Create tag key inside the existing tag namespace
### bash
TAG_NAMESPACE_OCID=`oci iam tag-namespace list --query "data[?name=='test-projects'] | [0].id" --raw-output`
echo $TAG_NAMESPACE_OCID
oci iam tag create --tag-namespace-id $TAG_NAMESPACE_OCID --name reports --description "Reports project" --profile SANDBOX-ADMIN

# Dynamic Group for tagged functions
### bash
echo $TENANCY_OCID
MATCHING_RULE="ALL {resource.type = 'fnfunc', tag.test-projects.reports.value}"
oci iam dynamic-group create --name reporting-functions --description "Functions related to the reporting project" --matching-rule $MATCHING_RULE -c $TENANCY_OCID

## IAM Policy statement
### bash
cd ~/git/oci-book/chapter09/4-events/policies
oci iam policy create --name functions-storage-reports-policy --statements file://functions.policies.storage-reports.json --description "Storage-related (reports) policy for tagged functions" --profile SANDBOX-ADMIN


# SECTION: Events > Functions and Object Storage > Deploying function

## Create application in Oracle Functions
### bash (on cloud-based VM)
cd ~
fn init --runtime python reportingfn
cp ~/functions/reportingfn.py ~/reportingfn/func.py
fn create app reportingapp --annotation oracle.com/oci/subnetIds="[\"$FN_SUBNET_ID\"]"
cd reportingfn/
fn -v deploy --app reportingapp --no-bump

## Tag function with the defined tag key
### bash
FN_APP_OCID=`oci fn application list --query "data[?\"display-name\" == 'reportingapp'] | [0].id" --raw-output`
echo $FN_APP_OCID
FN_FUN_OCID=`oci fn function list --application-id $FN_APP_OCID --query "data[?\"display-name\" == 'reportingfn'] | [0].id" --raw-output`
echo $FN_FUN_OCID
oci fn function update --function-id $FN_FUN_OCID --defined-tags '{ "test-projects": {"reports": ""} }'

# SECTION: Events > Events as function triggers

# Trigger function using event mock
### bash (on cloud-based VM)
cat ~/event.mock.json | fn invoke reportingapp reportingfn --content-type application/json

# SECTION: Events > Oracle Events

## Let Oracle Events trigger Oracle Functions
### bash
cd ~/git/oci-book/chapter09/4-events/policies
oci iam policy create --name cloudevents-policy --statements file://cloudevents.policies.json --description "Functions-related policy for CloudEvents" --profile SANDBOX-ADMIN

## Create Oracle Events rule
### bash
cd ~/git/oci-book/chapter09/4-events/events
echo $FN_FUN_OCID
cat oracleevents.actions.template.json | sed -e "s/PUT_HERE_FUNCTION_ID/$FN_FUN_OCID/g" > oracleevents.actions.json
SERIALIZED_CONDITIONS=`cat oracleevents.conditions.json | sed 's/"/\\"/g' | sed 's/[[:space:]]//g' | tr -d '\n'`
oci events rule create --display-name new-reports --is-enabled true --condition $SERIALIZED_CONDITIONS --actions file://oracleevents.actions.json

## Put a two more test files to the bucket
### bash
cd ~/git/oci-book/chapter09/4-events/reports
oci os object put -bn reports --file customer_attendance.20190923.raw.csv --profile SANDBOX-USER
oci os object put -bn reports --file customer_attendance.20190924.raw.csv --profile SANDBOX-USER
