### Practical Oracle Cloud Infrastructure
© Michal Jakobczyk  
Code snippets to use with Chapter 7.  
Replace `<placeholders>` with values matching your environment.  

---
#### SECTION: Autonomous Data Warehouse

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

:wrench: **Task:** List fact files     
:computer: **Execute on:** Your machine  
:file_folder: `oci-book/chapter07/3-facts`

    for fact in `ls facts.*.csv`; do echo $fact; oci os object put -bn roadadw-load --file $fact --profile SANDBOX-USER; done
    
:wrench: **Task:** Create ROADEVENTS_FACT table   
:cloud: **Execute on:** SQL Developer Web (as SANDBOX_USER)

    create table ROADEVENTS_FACT (
      time_dim_id     char(6) not null,
      road_dim_id     char(6) not null,
      event_dim_id    char(7) not null,
      occurrence      number(10) not null,
      injured         number(10) not null,
      killed          number(10) not null,
      constraint pk_roadevents_fact
        primary key (time_dim_id, road_dim_id, event_dim_id),
      constraint fk_road_dim 
        foreign key (road_dim_id) 
          references ROAD_DIM(segment_id),
      constraint fk_event_dim 
        foreign key (event_dim_id) 
          references EVENT_DIM(event_id),
      constraint fk_time_dim 
        foreign key (time_dim_id) 
          references TIME_DIM(day_id)
    );

:wrench: **Task:** Create indexes on ROADEVENTS_FACT table   
:cloud: **Execute on:** SQL Developer Web (as SANDBOX_USER)

    CREATE INDEX roadevents_fact_time_ix 
      ON roadevents_fact (time_dim_id);
    CREATE INDEX roadevents_fact_road_ix 
      ON roadevents_fact (road_dim_id);
    CREATE INDEX roadevents_fact_event_ix 
      ON roadevents_fact (event_dim_id);

:wrench: **Task:** Upload data to the ROADEVENTS_FACT table   
:cloud: **Execute on:** SQL Developer Web (as SANDBOX_USER)

    BEGIN
      DBMS_CLOUD.COPY_DATA(
        table_name => 'ROADEVENTS_FACT',
        credential_name => 'OCI_SANDBOX_USER',
        file_uri_list => 'https://objectstorage.<put-here-region-identifier>.oraclecloud.com/n/<put-here-object-storage-namespace>/b/roadadw-load/o/facts.*.csv',
        format => json_object('type' value 'CSV', 'skipheaders' value '1', 'blankasnull' value 'true')
      );
    END;

:wrench: **Task:** Count rows and select them in ROADEVENTS_FACT table   
:cloud: **Execute on:** SQL Developer Web (as SANDBOX_USER)

    select count(*) from ROADEVENTS_FACT;
    select * from ROADEVENTS_FACT;
    
---
#### SECTION: Database Monitoring

:wrench: **Task:** Display current AWR settings   
:cloud: **Execute on:** SQL Developer Web (as ADMIN)

    select 
      extract( hour from snap_interval) interval_hours,
      snap_interval,
      extract( day from retention) retention_days,
      retention
    from SYS.DBA_HIST_WR_CONTROL 
    where dbid=(select con_dbid from v$database);

:wrench: **Task:** Alter the retention time and the statistics collection interval     
:cloud: **Execute on:** SQL Developer Web (as ADMIN)

    BEGIN
      DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(
        retention => 20160,
        interval => 60
        );
    END;

---
#### SECTION: Data Analytics

:wrench: **Task:** Basic Star Query   
:cloud: **Execute on:** SQL Developer Web (as SANDBOX_USER)

    SELECT * FROM ROADEVENTS_FACT   F
    JOIN TIME_DIM  T ON T.DAY_ID = F.TIME_DIM_ID
    JOIN ROAD_DIM  R ON R.SEGMENT_ID = F.ROAD_DIM_ID
    JOIN EVENT_DIM E ON E.EVENT_ID = F.EVENT_DIM_ID

:wrench: **Task:** Grant materialized view to SANDBOX_USER    
:cloud: **Execute on:** SQL Developer Web (as ADMIN)

    GRANT CREATE MATERIALIZED VIEW TO SANDBOX_USER;
    
:wrench: **Task:** Verify privileges given to the SANDBOX_USER    
:cloud: **Execute on:** SQL Developer Web (as ADMIN)
    
    SELECT * FROM DBA_ROLE_PRIVS where grantee='SANDBOX_USER';
    SELECT * FROM DBA_SYS_PRIVS where grantee='SANDBOX_USER';

:wrench: **Task:** Create materialized view    
:cloud: **Execute on:** SQL Developer Web (as SANDBOX_USER)

    CREATE MATERIALIZED VIEW ROADEVENTS_STAR AS
    SELECT * FROM ROADEVENTS_FACT   F
    JOIN TIME_DIM  T ON T.DAY_ID = F.TIME_DIM_ID
    JOIN ROAD_DIM  R ON R.SEGMENT_ID = F.ROAD_DIM_ID
    JOIN EVENT_DIM E ON E.EVENT_ID = F.EVENT_DIM_ID

:wrench: **Task:** Aggregate query over Star schema    
:cloud: **Execute on:** SQL Developer Web (as SANDBOX_USER)

    SELECT 
      year_name, class_name, 
      SUM(occurrence) total_occurrence, 
      SUM(injured) sum_injured, 
      SUM(killed) sum_killed
    FROM ROADEVENTS_STAR 
    GROUP BY year_name, class_name 
    ORDER BY year_name, class_name;

:wrench: **Task:** Slice operation over Star schema    
:cloud: **Execute on:** SQL Developer Web (as SANDBOX_USER)

    SELECT 
      SUM(occurrence) total_occurrence, 
      SUM(injured) sum_injured, 
      SUM(killed) sum_killed
    FROM ROADEVENTS_STAR 
    WHERE day_date=TO_DATE('20170812','YYYYMMDD');

:wrench: **Task:** Drill-down operation over Star schema    
:cloud: **Execute on:** SQL Developer Web (as SANDBOX_USER)

    SELECT class_name, category_name, event_name,
      SUM(occurrence) total_occurrence, 
      SUM(injured) sum_injured, 
      SUM(killed) sum_killed
    FROM ROADEVENTS_STAR 
    WHERE day_date=TO_DATE('20170812','YYYYMMDD')
    GROUP BY class_name, category_name, event_name
    ORDER BY class_name, category_name, event_name;

:wrench: **Task:** Dicing operation over Star schema    
:cloud: **Execute on:** SQL Developer Web (as SANDBOX_USER)

    SELECT event_name, segment_voivodeship,
      SUM(occurrence) occurrence_in_201708
    FROM ROADEVENTS_STAR 
    WHERE 
      month_of_year=8 and year_name='CY2017' and
      category_name='traffic rules' and 
      segment_voivodeship 
        in ('Masovian','Subcarpathian','Lesser Poland')
    GROUP BY event_name, segment_voivodeship
    ORDER BY event_name, segment_voivodeship;

:wrench: **Task:** Pivot operation over Star schema    
:cloud: **Execute on:** SQL Developer Web (as SANDBOX_USER)

    SELECT
        *
    FROM
    (
      SELECT
        event_name,
        segment_voivodeship,
        SUM(occurrence) occurrence_in_201708
      FROM
        ROADEVENTS_STAR
      WHERE
        month_of_year = 8 AND year_name = 'CY2017'
        AND category_name = 'traffic rules'
        AND segment_voivodeship 
            IN ( 'Masovian', 'Subcarpathian', 'Lesser Poland' )
      GROUP BY event_name, segment_voivodeship
      ORDER BY event_name, segment_voivodeship
    ) PIVOT (
        SUM ( occurrence_in_201708 )
        FOR ( segment_voivodeship )
        IN (
          'Masovian' as masovian,
          'Subcarpathian' as subcarpathian,
          'Lesser Poland' as lesser_poland
        )
    )

---
#### SECTION: Cleanup

:wrench: **Task:** Terminate ADW and delete object storage bucket     
:computer: **Execute on:** Your machine

    ADW_OCID=`oci db autonomous-database list --query "data[?\"display-name\"=='road-adw'] | [0].id" --raw-output`
    echo $ADW_OCID
    oci db autonomous-database delete --autonomous-database-id "$ADW_OCID" --wait-for-state TERMINATED
    oci os object bulk-delete -bn roadadw-load
    oci os bucket delete -bn roadadw-load
    
