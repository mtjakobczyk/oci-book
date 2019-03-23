# SECTION: Buckets and objects

## Get object storage namespace name
### bash / OCI CLI
oci os ns get


# SECTION: Working with objects

## Create a bucket
### bash / OCI CLI
oci os bucket create --name blueprints --profile SANDBOX-ADMIN

## List buckets
### bash / OCI CLI
oci os bucket list --query 'data[*].{Bucket:name}' --output table --profile SANDBOX-ADMIN

## Create policy based on statements from sandbox-users.policies.json
### bash / OCI CLI
COMPARTMENT_ID=ocid1.compartment.oc1..aaaaa………gzwhsa
oci iam policy create --name sandbox-users-storage-policy --statements file://sandbox-users.policies.json --description "Storage-related policy for regular Sandbox users" -c $COMPARTMENT_ID --profile SANDBOX-ADMIN

## Generate random binary file
### bash
SIZE=$((4096+(10+RANDOM % 20)*1024))
head -c $SIZE /dev/urandom > 101.pdf
ls -l 101.pdf | awk '{ print $9 " (" $5 ")" }'

## Put a file to a bucket
### bash / OCI CLI
oci os object put -bn blueprints --file 101.pdf --profile SANDBOX-USER

## Put a file to a bucket with namespace name
### bash / OCI CLI
oci os object put -ns weq324dfwef -bn blueprints --file 101.pdf --profile SANDBOX-USER

## Get an object
### bash / OCI CLI
oci os object get -bn blueprints --name 101.pdf --file 101-copy.pdf --profile SANDBOX-USER

## Delete an object
### bash / OCI CLI
oci os object delete -bn blueprints --name 101.pdf --profile SANDBOX-USER


# SECTION: Object name prefixes

## Generate test files - group 1: warsaw/bemowo
### bash
mkdir -p warsaw/bemowo
for i in 101 102 105 107 115; do SIZE=$((4096+(10+RANDOM % 20)*1024)); head -c $SIZE /dev/urandom > warsaw/bemowo/$i.pdf; done

## Generate test files - group 2: warsaw/wola/a
### bash
mkdir -p warsaw/wola/a
for i in 115 120 124 130; do SIZE=$((4096+(10+RANDOM % 20)*1024)); head -c $SIZE /dev/urandom > warsaw/wola/a/$i.pdf; done

## Generate test files - group 3: warsaw/wola/b
### bash
mkdir -p warsaw/wola/b
for i in 119 120 121; do SIZE=$((4096+(10+RANDOM % 20)*1024)); head -c $SIZE /dev/urandom > warsaw/wola/b/$i.pdf; done

## List test files
### bash
find warsaw -type f -exec ls -lh {} + | awk '{ print $9 " (" $5 ")"}'

## Bulk upload test files (group 1: warsaw/bemowo) prefixed with waw/bemowo/
### bash / OCI CLI
oci os object bulk-upload -bn blueprints --src-dir warsaw/bemowo/ --object-prefix "waw/bemowo/" --include "*.pdf" --profile SANDBOX-USER

## Bulk upload test files (group 2: warsaw/wola/a) prefixed with waw/wola/a
### bash / OCI CLI
oci os object bulk-upload -bn blueprints --src-dir warsaw/wola/a --object-prefix "waw/wola/a/" --profile SANDBOX-USER

## Bulk upload test files (group 3: warsaw/wola/b) prefixed with waw/wola/b
### bash / OCI CLI
oci os object bulk-upload -bn blueprints --src-dir warsaw/wola/b --object-prefix "waw/wola/b/" --profile SANDBOX-USER

## List objects prefixed with with waw/wo
### bash / OCI CLI
oci os object list -bn blueprints --prefix "waw/wo" --query 'data[*].name' --profile SANDBOX-USER

## List objects prefixed with with waw/wola/b
### bash / OCI CLI
oci os object list -bn blueprints --prefix "waw/wola/b" --query 'data[*].name' --profile SANDBOX-USER

## List objects prefixed with with waw/wola/b/12
### bash / OCI CLI
oci os object list -bn blueprints --prefix "waw/wola/b/12" --query 'data[*].name' --profile SANDBOX-USER


# SECTION: Listing objects in pages

## List objects in pages
### bash / OCI CLI
oci os object list -bn blueprints  --limit 5 --query '{names:data[*].name, next:"next-start-with"}' --profile SANDBOX-USER
oci os object list -bn blueprints  --limit 5 --start "waw/wola/a/115.pdf" --query '{names:data[*].name, next:"next-start-with"}' --profile SANDBOX-USER
oci os object list -bn blueprints  --limit 5 --start "waw/wola/b/120.pdf" --query '{names:data[*].name, next:"next-start-with"}' --profile SANDBOX-USER


# SECTION: Object metadata

## Put an object with custom metadata
### bash / OCI CLI
head -c 4096 /dev/urandom > warsaw/wola/a/122.pdf
METADATA='{ "apartment-levels": "2" }'
oci os object put -bn blueprints --name "waw/wola/a/122.pdf" --file warsaw/wola/a/122.pdf --metadata "$METADATA" --profile SANDBOX-USER

## Head an object
### bash / OCI CLI
oci os object head -bn blueprints --name "waw/wola/a/122.pdf" --profile SANDBOX-USER


# SECTION: Concurrent updates

## Observe changing ETags
### bash / OCI CLI
head -c 8096 /dev/urandom > warsaw/bemowo/parking.pdf
oci os object put -bn blueprints --name waw/bemowo/parking.pdf --file warsaw/bemowo/parking.pdf --profile SANDBOX-USER
oci os object put -bn blueprints --name waw/bemowo/parking.pdf --file warsaw/bemowo/parking.pdf --profile SANDBOX-USER

## Demonstrate ETag-based optimistic concurrency 1/2
### bash / OCI CLI
oci os object head -bn blueprints --name waw/bemowo/parking.pdf --query 'etag' --profile SANDBOX-USER
oci os object get -bn blueprints --name waw/bemowo/parking.pdf --file local.parking.pdf --profile SANDBOX-USER
ls -l local.parking.pdf | awk '{ print $9 " (" $5 ")" }'
head -c 2048 /dev/urandom >> local.parking.pdf
ls -l local.parking.pdf | awk '{ print $9 " (" $5 ")" }'
oci os object put -bn blueprints --name waw/bemowo/parking.pdf --file local.parking.pdf --if-match "6836145f-2b37-4538-885d-bd7f242d5a34" --profile SANDBOX-USER

## Demonstrate ETag-based optimistic concurrency 2/2
### bash / OCI CLI
head -c 1024 /dev/urandom >> local.parking.pdf
ls -l local.parking.pdf | awk '{ print $9 " (" $5 ")" }'
oci os object put -bn blueprints --name waw/bemowo/parking.pdf --file local.parking.pdf --if-match "6836145f-2b37-4538-885d-bd7f242d5a34" --profile SANDBOX-USER


# SECTION: Multi-part uploads

## Generate a large file with random binary contents
### bash / OCI CLI
SIZE=$((25*1024*1024))
head -c $SIZE /dev/urandom > warsaw/bemowo/visualizations.pdf
ls -lh warsaw/bemowo/visualizations.pdf | awk '{ print $9 " (" $5 ")" }'

## Prepare a new virtual environment and install OCI SDK
### bash / OCI CLI
python3 -m venv oci-multipart
source oci-multipart/bin/activate
pip install --upgrade pip
pip install oci
pip freeze | grep oci

## Test multi-part file upload using SDK
### bash / custom Python script
source ocidev/bin/activate
curl https://raw.githubusercontent.com/mtjakobczyk/oci-book/master/chapter05/2-multipart-upload/multipart.py -o multipart.py
chmod u+x multipart.py
FILE="$HOME/warsaw/bemowo/visualizations.pdf"
CONFIG="$HOME/.oci/config"
./multipart.py "$FILE" 10 "waw/bemowo/visualizations.pdf" "blueprints" "$CONFIG" SANDBOX-USER

# List the parts
### bash
ls -lh warsaw/bemowo/vi* | awk '{ print $9 " (" $5 ")" }'

## Verify the uploaded file is the same as the original file
### bash / OCI CLI
oci os object get -bn blueprints --name "waw/bemowo/visualizations.pdf" --file visualizations.downloaded.pdf --profile SANDBOX-USER
ls -lh visualizations.downloaded.pdf | awk '{ print $9 " (" $5 ")" }'
diff visualizations.downloaded.pdf warsaw/bemowo/visualizations.pdf


# SECTION: Tagging resources

## Create tag namespace
### bash / OCI CLI
oci iam tag-namespace create --name "test-projects" --description "Test tag namespace: projects" --profile SANDBOX-ADMIN

## Create tag key
### bash / OCI CLI
TAG_NAMESPACE_OCID=ocid1.tagnamespace.oc1..aa………6qu2eq
oci iam tag create --tag-namespace-id $TAG_NAMESPACE_OCID --name realestate --description "Real-estate project" --profile SANDBOX-ADMIN

## Find tag namespace OCID by name and list all tag keys within the namespace
### bash / OCI CLI
oci iam tag-namespace list --all --query "data[?name=='test-projects'].id" --profile SANDBOX-ADMIN
oci iam tag list --tag-namespace-id ocid1.tagnamespace.oc1..aa………6qu2eq --all --profile SANDBOX-ADMIN


# SECTION: Dynamic Groups

## Creating a dynamic group
### bash / OCI CLI
TENANCY_OCID=ocid1.tenancy.oc1..aa………3yymfa
MATCHING_RULE="tag.test-projects.realestate.value"
oci iam dynamic-group create --name realestate-instances --description "Instances related to the real-estate project" --matching-rule $MATCHING_RULE -c $TENANCY_OCID

## Updating existing policy
### bash / OCI CLI
COMPARTMENT_ID=ocid1.compartment.oc1..aaaaa………gzwhsa
oci iam policy list --all -c $COMPARTMENT_ID --query "data[?name=='sandbox-users-storage-policy'].{OCID:id}" --profile SANDBOX-ADMIN
POLICY_ID=ocid1.policy.oc1..aa………tiueya
oci iam policy update --policy-id $POLICY_ID --statements file://1-policies/sandbox-users.policies.2.json -c $COMPARTMENT_ID --profile SANDBOX-ADMIN


# SECTION: Accessing storage from instances

## Provisioning infrastructure
### bash / Terraform
cd oci-book/chapter05/3-instance-principals/infrastructure
find . \( -name "*.tf" -o -name "*.yaml" \)
env | grep TF_VAR_
terraform init
terraform apply -auto-approve

## Provisioning infrastructure
### bash / Terraform
ssh -i ~/.ssh/oci_id_rsa opc@130.61.XX.XXX
sudo systemctl status reportissuer

## Printing object content
### bash / OCI CLI
oci os object get -bn blueprints --name "waw/bemowo/summary.txt" --file - --profile SANDBOX-USER

## Infrastructure cleanup
### bash / Terraform
terraform destroy -auto-approve


# SECTION: Public access

## Creating a pre-authenticated request
### bash / OCI CLI
oci os preauth-request create -bn blueprints --name waw-bemowo-105-par2356 --access-type ObjectRead --time-expires 2019-03-23T10:15:00.000Z -on waw/bemowo/105.pdf --profile SANDBOX-ADMIN
