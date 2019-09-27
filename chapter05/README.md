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
