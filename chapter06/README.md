### Practical Oracle Cloud Infrastructure
© Michal Jakobczyk  
Code snippets to use with Chapter 6.  
Replace `<placeholders>` with values matching your environment.  

---
#### SECTION: Virtual Networking ➙ Public IPs

:wrench: **Task:** Create a reserved public IP address   
:computer: **Execute on:** Your machine

    oci network public-ip create --lifetime RESERVED --display-name another-ip --profile SANDBOX-ADMIN

:wrench: **Task:** List reserved public IP addresses   
:computer: **Execute on:** Your machine

    oci network public-ip list --lifetime RESERVED --scope REGION --query 'data[*].{IP:"ip-address",Name:"display-name",State:"lifecycle-state"}' --output table --all --profile SANDBOX-ADMIN

:wrench: **Task:** Create a reserved public IP address   
:computer: **Execute on:** Your machine

    RESERVED_IP_NAME="my-ip"
    QUERY="data[?\"display-name\" == '$RESERVED_IP_NAME'].id | [0]"
    RESERVED_IP_OCID=`oci network public-ip list --scope REGION --lifetime RESERVED --query "$QUERY" --all --profile SANDBOX-ADMIN | tr -d '"'`
    echo $RESERVED_IP_OCID
    oci network public-ip delete --public-ip-id $RESERVED_IP_OCID --force --profile SANDBOX-ADMIN
    
---
#### SECTION: Virtual Networking ➙ Private subnets, Basion and NAT
