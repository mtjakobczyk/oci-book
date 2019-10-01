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

    oci os bucket create --name roadadw-load --profile SANDBOX-ADMIN
    
:wrench: **Task:** Create IAM policy for the new Object Storage bucket     
:computer: **Execute on:** Your machine

    cd ~/git/oci-book/chapter07/1-setup/
    oci iam policy create --name sandbox-users-adw-storage-policy --statements file://sandbox-users.policies.adwstorage.json --description "ADW-Storage-related policy for regular Sandbox users" --profile SANDBOX-ADMIN

---
#### SECTION: Loading Data to ADW ➙ Star Schema ➙ Dimensions

:wrench: **Task:** List dimension files     
:computer: **Execute on:** Your machine

    cd ~/git/oci-book/chapter07/2-dimensions/
    ls -1 *_dim.csv

:wrench: **Task:** Upload dimension files to the bucket     
:computer: **Execute on:** Your machine

    oci os object put -bn roadadw-load --file time_dim.csv --profile SANDBOX-USER
    oci os object put -bn roadadw-load --file road_dim.csv --profile SANDBOX-USER
    oci os object put -bn roadadw-load --file event_dim.csv --profile SANDBOX-USER
    
:wrench: **Task:** Create EVENT_DIM table for the event dimension    
:cloud: **Execute on:** SQL Developer Web (as SANDBOX_USER)
    
    create table EVENT_DIM (
      event_id        char(7) not null,
      event_name      varchar2(50) not null,
      category_id     char(4) not null,
      category_name   varchar2(50) not null,
      class_id        char(1) not null,
      class_name      varchar2(50) not null,
      constraint pk_event_dim primary key (event_id)
    );

:wrench: **Task:** Upload dimension data to the EVENT_DIM table    
:cloud: **Execute on:** SQL Developer Web (as SANDBOX_USER)

    BEGIN
      DBMS_CLOUD.COPY_DATA(
        table_name => 'EVENT_DIM',
        credential_name => 'OCI_SANDBOX_USER',
        file_uri_list => 'https://objectstorage.<put-here-region-identifier>.oraclecloud.com/n/<put-here-object-storage-namespace>/b/roadadw-load/o/event_dim.csv',
        format => json_object('type' value 'CSV', 'skipheaders' value '1')
      );
    END;

:wrench: **Task:** View dimension data in the EVENT_DIM table    
:cloud: **Execute on:** SQL Developer Web (as SANDBOX_USER)

    select * from event_dim;
    
:wrench: **Task:** Create ROAD_DIM table for the road dimension    
:cloud: **Execute on:** SQL Developer Web (as SANDBOX_USER)
    
    create table ROAD_DIM (
      segment_id          char(6) not null,
      segment_name        varchar2(50) not null,
      segment_type        char(2) not null,
      segment_voivodeship varchar2(50) not null,
      segment_highway     varchar2(50),
      segment_expressway  varchar2(50),
      road_id             varchar2(10) not null,
      road_name           varchar2(10) not null,
      road_lenght         number(5),
      constraint pk_road_dim primary key (segment_id),
      constraint chk_segment_type
        check ( segment_type in ('A','S','GP','G'))
    );

:wrench: **Task:** Upload dimension data to the ROAD_DIM table    
:cloud: **Execute on:** SQL Developer Web (as SANDBOX_USER)

    BEGIN
      DBMS_CLOUD.COPY_DATA(
        table_name => 'ROAD_DIM',
        credential_name => 'OCI_SANDBOX_USER',
        file_uri_list => 'https://objectstorage.<put-here-region-identifier>.oraclecloud.com/n/<put-here-object-storage-namespace>/b/roadadw-load/o/road_dim.csv',
        format => json_object('type' value 'CSV', 'skipheaders' value '1', 'blankasnull' value 'true')
      );
    END;

:wrench: **Task:** View dimension data in the ROAD_DIM table    
:cloud: **Execute on:** SQL Developer Web (as SANDBOX_USER)

    select * from road_dim;

:wrench: **Task:** Create TIME_DIM table for the road dimension    
:cloud: **Execute on:** SQL Developer Web (as SANDBOX_USER)

    create table TIME_DIM (
      day_id          char(6) not null,
      day_date        DATE not null,
      day_name        varchar2(20) not null,
      month_id        char(4) not null,
      month_of_year   number(2) not null,
      month_name      varchar2(20) not null,
      year_id         char(2) not null,
      year_name       char(6) not null,
      constraint pk_time_dim primary key (day_id)
    );

:wrench: **Task:** Upload dimension data to the TIME_DIM table    
:cloud: **Execute on:** SQL Developer Web (as SANDBOX_USER)

    BEGIN
      DBMS_CLOUD.COPY_DATA(
        table_name => 'TIME_DIM',
        credential_name => 'OCI_SANDBOX_USER',
        file_uri_list => 'https://objectstorage.<put-here-region-identifier>.oraclecloud.com/n/<put-here-object-storage-namespace>/b/roadadw-load/o/time_dim.csv',
        format => json_object(
          'type' value 'CSV',
          'skipheaders' value '1',
          'blankasnull' value 'true',
          'dateformat' value 'YYYY-MM-DD')
      );
    END;

:wrench: **Task:** View dimension data in the TIME_DIM table    
:cloud: **Execute on:** SQL Developer Web (as SANDBOX_USER)

    select * from time_dim;
    
---
#### SECTION: Loading Data to ADW ➙ Star Schema ➙ Facts

:wrench: **Task:** List fact files     
:computer: **Execute on:** Your machine

    cd ~/git/oci-book/chapter07/3-facts/
    ls -1 *.csv
