# PRACTICAL ORACLE CLOUD Infrastructure
# CHAPTER 09 - Code Snippets

# SECTION: Serverless > Developer VM

## Provision a Dev Machine
### bash
cd ~/git
cd oci-book/chapter09/1-devmachine
find . \( -name "*.tf" -o -name "*.yaml" \) | sort
source ~/tfvars.env.sh
terraform init
terraform apply

## Connect to the Dev Machine
### bash
DEV_MACHINE_IP=`terraform output dev_machine_public_ip`
ssh -i ~/.ssh/oci_id_rsa ubuntu@$DEV_MACHINE_IP
sudo cat /var/log/syslog | grep "DEV machine"


# SECTION: Serverless > Fn Project > Installation and configuration

## Install and start Fn Project
### bash
curl -LSs https://raw.githubusercontent.com/fnproject/cli/master/install | sh
fn version
fn start &

## Inspect local installation
### bash
docker images
docker ps
tree -a ~/.fn

## Configure Fn Project for local development
### bash
fn list contexts
fn use context default
fn update context registry fndemouser
fn list contexts


# SECTION: Serverless > Fn Project > Your first function

## Initialize Python-based Fn project (Blank function)
### bash
fn init --runtime python blankfn
tree ~/blankfn/
cp ~/functions/blankfn.py ~/blankfn/func.py

## Create Fn application (Blank function)
### bash
fn create app blankapp
fn list apps

## Build Fn function (Blank function)
### bash
cd ~/blankfn
fn --verbose deploy --app blankapp --local

## Inspect Fn function (Blank function)
### bash
fn list functions blankapp
docker images | grep blank

## Test Fn function locally (Blank function)
### bash
fn invoke blankapp blankfn
watch docker ps


# SECTION: Serverless > Fn Project > UUID Generator function

## Initialize Fn project  (UUID Generator)
### bash
cd ~
fn init --runtime python uuidfn
cp ~/functions/uuidfn.py ~/uuidfn/func.py

## Create Fn application (UUID Generator)
### bash
fn create app uuidapp
fn list functions uuidapp

## Build Fn function (UUID Generator)
### bash
cd ~/uuidfn/
fn --verbose deploy --app uuidapp --local

## Test Fn function locally (UUID Generator)
### bash
fn invoke uuidapp uuidfn
echo -n '{ "client_name": "Mike"  }' | fn invoke uuidapp uuidfn --content-type application/json
fn inspect function uuidapp uuidfn
FN_INVOKE_ENDPOINT=<put-here-fn-invoke-endpoint>
curl -X "POST" -H "Content-Type: application/json" "$FN_INVOKE_ENDPOINT"


# SECTION: Serverless > Oracle Functions
