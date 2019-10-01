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
