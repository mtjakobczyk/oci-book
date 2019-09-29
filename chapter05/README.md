### Practical Oracle Cloud Infrastructure
© Michal Jakobczyk  
Code snippets to use with Chapter 5.  
Replace `<placeholders>` with values matching your environment.  

---
#### SECTION: Buckets and objects

:wrench: **Task:** Get object storage namespace name   
:computer: **Execute on:** Your machine

    oci os ns get

---
#### SECTION: Working with objects ➙ Basics

:wrench: **Task:** Get object storage namespace name   
:computer: **Execute on:** Your machine

    oci os bucket create --name blueprints --profile SANDBOX-ADMIN
    
:wrench: **Task:** List buckets    
:computer: **Execute on:** Your machine

    oci os bucket list --query 'data[*].{Bucket:name}' --output table --profile SANDBOX-ADMIN
    
:wrench: **Task:** Create policy based on statements from sandbox-users.policies.storage.json  
:computer: **Execute on:** Your machine
    
    cd ~/git/oci-book/chapter05/1-policies
    oci iam policy create --name sandbox-users-storage-policy --statements file://sandbox-users.policies.storage.json --description "Storage-related policy for regular Sandbox users" --profile SANDBOX-ADMIN

:wrench: **Task:** Generate random binary file  
:computer: **Execute on:** Your machine

    mkdir ~/data
    cd ~/data
    SIZE=$((4096+(10+RANDOM % 20)*1024))
    head -c $SIZE /dev/urandom > 101.pdf
    ls -lh 101.pdf | awk '{ print $9 " (" $5 ")" }'
    
:wrench: **Task:** Put a file to a bucket  
:computer: **Execute on:** Your machine

    oci os object put -bn blueprints --file 101.pdf --profile SANDBOX-USER

:wrench: **Task:** Put a file to a bucket with namespace name  
:computer: **Execute on:** Your machine

    oci os object put -ns <put-here-object-storage-namespace-name> -bn blueprints --file 101.pdf --profile SANDBOX-USER
    
:wrench: **Task:** Get an object  
:computer: **Execute on:** Your machine

    oci os object get -bn blueprints --name 101.pdf --file 101-copy.pdf --profile SANDBOX-USER
    
:wrench: **Task:** Delete an object  
:computer: **Execute on:** Your machine

    oci os object delete -bn blueprints --name 101.pdf --profile SANDBOX-USER
    
---
#### SECTION: Working with objects ➙ Object Name Prefixes

:wrench: **Task:** Generate test files - group 1: warsaw/bemowo  
:computer: **Execute on:** Your machine

    cd ~/data
    mkdir -p warsaw/bemowo
    for i in 101 102 105 107 115; do SIZE=$((4096+(10+RANDOM % 20)*1024)); head -c $SIZE /dev/urandom > warsaw/bemowo/$i.pdf; done
    
:wrench: **Task:** Generate test files - group 2: warsaw/wola/a  
:computer: **Execute on:** Your machine

    mkdir -p warsaw/wola/a
    for i in 115 120 124 130; do SIZE=$((4096+(10+RANDOM % 20)*1024)); head -c $SIZE /dev/urandom > warsaw/wola/a/$i.pdf; done
    
:wrench: **Task:** Generate test files - group 1: warsaw/wola/b  
:computer: **Execute on:** Your machine

    mkdir -p warsaw/wola/b
    for i in 119 120 121; do SIZE=$((4096+(10+RANDOM % 20)*1024)); head -c $SIZE /dev/urandom > warsaw/wola/b/$i.pdf; done
    
    
:wrench: **Task:** List test files  
:computer: **Execute on:** Your machine

    find warsaw -type f -exec ls -lh {} + | awk '{ print $9 " (" $5 ")"}'
    
:wrench: **Task:** Bulk upload test files (group 1: warsaw/bemowo) prefixed with waw/bemowo/  
:computer: **Execute on:** Your machine

    oci os object bulk-upload -bn blueprints --src-dir warsaw/bemowo/ --object-prefix "waw/bemowo/" --include "*.pdf" --profile SANDBOX-USER
    
:wrench: **Task:** Bulk upload test files (group 2: warsaw/wola/a) prefixed with waw/wola/a  
:computer: **Execute on:** Your machine

    oci os object bulk-upload -bn blueprints --src-dir warsaw/wola/a --object-prefix "waw/wola/a/" --profile SANDBOX-USER
    
:wrench: **Task:** Bulk upload test files (group 3: warsaw/wola/b) prefixed with waw/wola/b  
:computer: **Execute on:** Your machine

    oci os object bulk-upload -bn blueprints --src-dir warsaw/wola/b --object-prefix "waw/wola/b/" --profile SANDBOX-USER
    
:wrench: **Task:** List objects prefixed with with waw/wo  
:computer: **Execute on:** Your machine

    oci os object list -bn blueprints --prefix "waw/wo" --query 'data[*].name' --profile SANDBOX-USER
    
:wrench: **Task:** List objects prefixed with with waw/wola/b  
:computer: **Execute on:** Your machine

    oci os object list -bn blueprints --prefix "waw/wola/b" --query 'data[*].name' --profile SANDBOX-USER
    
:wrench: **Task:** List objects prefixed with with waw/wola/b/12  
:computer: **Execute on:** Your machine

    oci os object list -bn blueprints --prefix "waw/wola/b/12" --query 'data[*].name' --profile SANDBOX-USER
    
---
#### SECTION: Working with objects ➙ Listing objects in pages

:wrench: **Task:** List objects in pages  
:computer: **Execute on:** Your machine

    oci os object list -bn blueprints  --limit 5 --query '{names:data[*].name, next:"next-start-with"}' --profile SANDBOX-USER
    oci os object list -bn blueprints  --limit 5 --start "waw/wola/a/115.pdf" --query '{names:data[*].name, next:"next-start-with"}' --profile SANDBOX-USER
    oci os object list -bn blueprints  --limit 5 --start "waw/wola/b/120.pdf" --query '{names:data[*].name, next:"next-start-with"}' --profile SANDBOX-USER
    
---
#### SECTION: Working with objects ➙ Object metadata

:wrench: **Task:** Put an object with custom metadata  
:computer: **Execute on:** Your machine

    head -c 4096 /dev/urandom > warsaw/wola/a/122.pdf
    METADATA='{ "apartment-levels": "2" }'
    oci os object put -bn blueprints --name "waw/wola/a/122.pdf" --file warsaw/wola/a/122.pdf --metadata "$METADATA" --profile SANDBOX-USER
    
:wrench: **Task:** Head an object  
:computer: **Execute on:** Your machine

    oci os object head -bn blueprints --name "waw/wola/a/122.pdf" --profile SANDBOX-USER
    
---
#### SECTION: Working with objects ➙ Concurrent updates

:wrench: **Task:** Observe changing ETags  
:computer: **Execute on:** Your machine

    head -c 8096 /dev/urandom > warsaw/bemowo/parking.pdf
    oci os object put -bn blueprints --name waw/bemowo/parking.pdf --file warsaw/bemowo/parking.pdf --profile SANDBOX-USER
    oci os object put -bn blueprints --name waw/bemowo/parking.pdf --file warsaw/bemowo/parking.pdf --profile SANDBOX-USER
    
:wrench: **Task:** Demonstrate ETag-based optimistic concurrency 1/2  
:computer: **Execute on:** Your machine

    ETAG=`oci os object head -bn blueprints --name waw/bemowo/parking.pdf --query 'etag' --profile SANDBOX-USER --raw-output`
    oci os object get -bn blueprints --name waw/bemowo/parking.pdf --file local.parking.pdf --profile SANDBOX-USER
    ls -l local.parking.pdf | awk '{ print $9 " (" $5 ")" }'
    head -c 2048 /dev/urandom >> local.parking.pdf
    ls -l local.parking.pdf | awk '{ print $9 " (" $5 ")" }'
    oci os object put -bn blueprints --name waw/bemowo/parking.pdf --file local.parking.pdf --if-match "$ETAG" --profile SANDBOX-USER

:wrench: **Task:** Demonstrate ETag-based optimistic concurrency 2/2  
:computer: **Execute on:** Your machine

    head -c 1024 /dev/urandom >> local.parking.pdf
    ls -l local.parking.pdf | awk '{ print $9 " (" $5 ")" }'
    oci os object put -bn blueprints --name waw/bemowo/parking.pdf --file local.parking.pdf --if-match "$ETAG" --profile SANDBOX-USER

---
#### SECTION: Programming Object Storage ➙ Multi-part uploads

:wrench: **Task:** Generate a large file with random binary contents  
:computer: **Execute on:** Your machine

    cd ~/data
    SIZE=$((25*1024*1024))
    head -c $SIZE /dev/urandom > warsaw/bemowo/visualizations.pdf
    ls -lh warsaw/bemowo/visualizations.pdf | awk '{ print $9 " (" $5 ")" }'
    
:wrench: **Task:** Prepare a new virtual environment and install OCI SDK  
:computer: **Execute on:** Your machine

    cd
    python3 -m venv oci-multipart
    source oci-multipart/bin/activate
    pip install --upgrade pip
    pip install oci
    pip freeze | grep oci
    
:wrench: **Task:** Test multi-part file upload using SDK  
:computer: **Execute on:** Your machine  
:dart: **Context:** Shell with the activated venv (oci-multipart)

    cd ~/git/oci-book/chapter05/2-multipart-upload
    chmod u+x multipart.py
    FILE="$HOME/data/warsaw/bemowo/visualizations.pdf"
    CONFIG="$HOME/.oci/config"
    ./multipart.py "$FILE" 10 "waw/bemowo/visualizations.pdf" "blueprints" "$CONFIG" SANDBOX-USER
    deactivate
    
:wrench: **Task:** List the parts  
:computer: **Execute on:** Your machine

    ls -lh ~/data/warsaw/bemowo/visual* | awk '{ print $9 " (" $5 ")" }'
   
:wrench: **Task:** Verify the uploaded file is the same as the original file  
:computer: **Execute on:** Your machine

    cd ~/data
    oci os object get -bn blueprints --name "waw/bemowo/visualizations.pdf" --file visualizations.downloaded.pdf --profile SANDBOX-USER
    ls -lh visualizations.downloaded.pdf | awk '{ print $9 " (" $5 ")" }'
    diff visualizations.downloaded.pdf warsaw/bemowo/visualizations.pdf

---
#### SECTION: Programming Object Storage ➙ Tagging resources

:wrench: **Task:** Create a tag namespace  
:computer: **Execute on:** Your machine

    oci iam tag-namespace create --name "test-projects" --description "Test tag namespace: projects" --profile SANDBOX-ADMIN
    
:wrench: **Task:** Create a tag key  
:computer: **Execute on:** Your machine

    TAG_NAMESPACE_OCID=`oci iam tag-namespace list --query "data[?name=='test-projects'] | [0].id" --raw-output`
    oci iam tag create --tag-namespace-id $TAG_NAMESPACE_OCID --name realestate --description "Real-estate project" --profile SANDBOX-ADMIN
    
:wrench: **Task:** List all tag keys within the namespace  
:computer: **Execute on:** Your machine

    oci iam tag list --tag-namespace-id $TAG_NAMESPACE_OCID --all --profile SANDBOX-ADMIN
    
---
#### SECTION: Programming Object Storage ➙ Dynamic Groups

:wrench: **Task:** Creating a dynamic group  
:computer: **Execute on:** Your machine

    TENANCY_OCID=`cat ~/.oci/config | grep tenancy | sed 's/tenancy=//'`
    MATCHING_RULE="tag.test-projects.realestate.value"
    oci iam dynamic-group create --name realestate-instances --description "Instances related to the real-estate project" --matching-rule $MATCHING_RULE -c $TENANCY_OCID

:wrench: **Task:** Updating existing policy  
:computer: **Execute on:** Your machine

    cd ~/git/oci-book/chapter05/1-policies
    POLICY_ID=`oci iam policy list --all --query "data[?name=='sandbox-users-storage-policy'] | [0].id" --raw-output --profile SANDBOX-ADMIN`
    oci iam policy update --policy-id $POLICY_ID --statements file://sandbox-users.policies.storage.2.json --version-date "" --profile SANDBOX-ADMIN

---
#### SECTION: Programming Object Storage ➙ Accessing storage from instances

:wrench: **Task:** Provisioning infrastructure  
:computer: **Execute on:** Your machine  
:dart: **Context:** Shell with TF_VAR_* environment variables set as in ~/tfvars.env.sh

    source ~/tfvars.env.sh
    cd ~/git/oci-book/chapter05/3-instance-principals/infrastructure
    find . \( -name "*.tf" -o -name "*.yaml" \)
    terraform init
    terraform apply -auto-approve
    APP_VM_PUBLIC_IP=`terraform output app_instance_public_ip`
    
:wrench: **Task:** Connect to the instance  
:computer: **Execute on:** Your machine

    ssh -i ~/.ssh/oci_id_rsa opc@$APP_VM_PUBLIC_IP
    
:wrench: **Task:** Observe the status of thereportissuer  
:computer: **Execute on:** Compute instance :cloud:
 
    sudo systemctl status reportissuer
    exit
