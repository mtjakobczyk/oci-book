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
