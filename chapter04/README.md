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
    
:wrench: **Task:** Generate one-time password for the sandbox-user  
:computer: **Execute on:** Your machine

    USER_OCID=<put-here-sandbox-user-ocid>
    oci iam user ui-password create-or-reset --user-id "$USER_OCID" --query "data.password"

:wrench: **Task:** Generate API Signing Keys for both sandbox-* users  
:computer: **Execute on:** Your machine

    cd ~/.apikeys
    openssl genrsa -out api.sandbox-user.pem -aes128 2048
    chmod go-r api.sandbox-user.pem
    openssl rsa -pubout -in api.sandbox-user.pem -out api.sandbox-user.pem.pub
    openssl genrsa -out api.sandbox-admin.pem -aes128 2048
    chmod go-r api.sandbox-admin.pem
    openssl rsa -pubout -in api.sandbox-admin.pem -out api.sandbox-admin.pem.pub
    ls -l | awk '{print $1, $9}'
    
:wrench: **Task:** Query for user OCID by name  
:computer: **Execute on:** Your machine

    SANDBOX_ADMIN_OCID=`oci iam user list -c $TENANCY_OCID --query "data[?name=='sandbox-admin'] | [0].id" --all --raw-output`
    
:wrench: **Task:** Upload API Signing key (public part) for the sandbox-admin user  
:computer: **Execute on:** Your machine

    oci iam user api-key upload --user-id $SANDBOX_ADMIN_OCID --key-file ~/.apikeys/api.sandbox-admin.pem.pub --query "data.fingerprint"

:wrench: **Task:** Edit the config file and add the SANDBOX-ADMIN profile for the sandbox-admin  
:computer: **Execute on:** Your machine

    vi ~/.oci/config # use vi or any other editor you prefer

:wrench: **Task:** Test current sandbox-admin access  
:computer: **Execute on:** Your machine

    oci iam user list -c $TENANCY_OCID --query "data [?starts_with(name,'sandbox')].name" --all --profile SANDBOX-ADMIN
    
:warning: **Warning:** Remember to upload the API Signing Key for the sandbox-user and add the SANDBOX-USER profile to the config

---
#### SECTION: Groups and Policies  
