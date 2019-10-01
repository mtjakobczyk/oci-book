### Practical Oracle Cloud Infrastructure
© Michal Jakobczyk  
Code snippets to use with Chapter 7.  
Replace `<placeholders>` with values matching your environment.  

---
#### SECTION: Autonomous Data Warehouse ➙ x

:wrench: **Task:** Provision Autonomous Data Warehouse instance     
:computer: **Execute on:** Your machine

    ADW_ADMIN_PASS=<put-here-new-admin-password>
    oci db autonomous-database create \
       --db-name ROADDW \
       --display-name road-adw \
       --db-workload DW \
       --license-model LICENSE_INCLUDED \
       --cpu-core-count 1 \
       --data-storage-size-in-tbs 1 \
       --admin-password $ADW_ADMIN_PASS \
       --wait-for-state AVAILABLE \
       --profile SANDBOX-ADMIN

---
#### SECTION: SQL Developer Web

:wrench: **Task:** Display current time     
:cloud: **Execute on:** SQL Developer Web (as ADMIN)
    
    SELECT CURRENT_TIMESTAMP FROM dual;
    
:wrench: **Task:** Create SANDBOX_USER database user     
:cloud: **Execute on:** SQL Developer Web (as ADMIN)
    
    CREATE USER SANDBOX_USER IDENTIFIED BY "<put-here-a-new-password>";
    GRANT dwrole TO SANDBOX_USER;
    ALTER USER SANDBOX_USER QUOTA 500M ON DATA;

:wrench: **Task:** Allow SANDBOX_USER database user access SQL Developer Web     
:cloud: **Execute on:** SQL Developer Web (as ADMIN)

    BEGIN
     ords_admin.enable_schema(
      p_enabled => TRUE,
      p_schema => 'SANDBOX_USER',
      p_url_mapping_type => 'BASE_PATH',
      p_url_mapping_pattern => 'sandbox',
      p_auto_rest_auth => TRUE
     );
     commit;
    END;

---
#### SECTION: Loading Data to ADW ➙ Database Credential

:wrench: **Task:** Generate Auth Token for sandbox-user     
:computer: **Execute on:** Your machine

    TENANCY_OCID=`cat ~/.oci/config | grep tenancy | sed 's/tenancy=//'`
    IAM_USER_OCID=`oci iam user list -c $TENANCY_OCID --query "data[?name=='sandbox-user'] | [0].id" --raw-output --all`
    echo $IAM_USER_OCID
    oci iam auth-token create --user-id $IAM_USER_OCID --description token-adw --query 'data.token' --raw-output

:wrench: **Task:** Create a new Credential for the SANDBOX_USER    
:cloud: **Execute on:** SQL Developer Web (as SANDBOX_USER)

    BEGIN
      DBMS_CLOUD.CREATE_CREDENTIAL(
        credential_name => 'OCI_SANDBOX_USER',
        username => 'sandbox-user',
        password => '<put-here-auth-token>'
      );
    END;

:wrench: **Task:** List all Credentials in a given schema    
:cloud: **Execute on:** SQL Developer Web (as SANDBOX_USER)

    SELECT * FROM all_credentials;

:wrench: **Task:** Create a new Object Storage bucket     
:computer: **Execute on:** Your machine

    oci os bucket create --name roadadw-sources --profile SANDBOX-ADMIN
    
:wrench: **Task:** Create IAM policy for the new Object Storage bucket     
:computer: **Execute on:** Your machine

    cd ~/git/oci-book/chapter07/1-setup/
    oci iam policy create --name sandbox-users-adw-storage-policy --statements file://sandbox-users.policies.adwstorage.json --description "ADW-Storage-related policy for regular Sandbox users" --profile SANDBOX-ADMIN

---
#### SECTION: Loading Data to ADW ➙ Star Schema
