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
#### SECTION: Working with objects

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
    ls -l 101.pdf | awk '{ print $9 " (" $5 ")" }'
    
:wrench: **Task:** Put a file to a bucket  
:computer: **Execute on:** Your machine

    oci os object put -bn blueprints --file 101.pdf --profile SANDBOX-USER
