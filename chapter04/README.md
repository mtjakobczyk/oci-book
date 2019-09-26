### Practical Oracle Cloud Infrastructure
© Michal Jakobczyk  
Code snippets to use with Chapter 4.  
Replace `<placeholders>` with values matching your environment.  

---
#### SECTION: Compartments

:wrench: **Task:** Display current compartment set in oci_cli_rc  
:computer: **Execute on:** Your machine

    oci iam compartment get --output table --query 'data.{Name:"name"}'
        
:wrench: **Task:** Create a subcompartment (a child to the current compartment set in oci_cli_rc)  
:computer: **Execute on:** Your machine

    EXP_COMPARTMENT_OCID=`oci iam compartment create --name Experiments --description "Sandbox area for experiments" --query "data.id" | tr -d '"'`
    echo $EXP_COMPARTMENT_OCID
    
:wrench: **Task:** Delete the subcompartment  
:computer: **Execute on:** Your machine

    oci iam compartment delete -c "$EXP_COMPARTMENT_OCID"

---
#### SECTION: Users

:wrench: **Task:** Create IAM user  
:computer: **Execute on:** Your machine

    TENANCY_OCID=`cat ~/.oci/config | grep tenancy | sed 's/tenancy=//'`
    oci iam user create --name sandbox-user --description "Sandbox user" --query "data.id" -c $TENANCY_OCID
    
:wrench: **Task:** List sandbox- users  
:computer: **Execute on:** Your machine

    oci iam user list -c $TENANCY_OCID --query "data [?starts_with(name,'sandbox')].name" --all
    
    
