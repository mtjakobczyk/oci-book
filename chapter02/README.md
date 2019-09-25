### Practical Oracle Cloud Infrastructure
© Michal Jakobczyk  
Code snippets to use with Chapter 2.  
Replace `<placeholders>` with values matching your environment.  

---
#### SECTION: Provisioning the Infrastructure

:wrench: **Task:** Generate keypair  
:computer: **Execute on:** Your machine

    ssh-keygen -t rsa -b 2048 -C michal@vm -f ~/id_rsa

---
#### SECTION: Testing the Application
:wrench: **Task:** Connect to the compute instance (uuid-1)  
:computer: **Execute on:** Your machine

    UUID1_INSTANCE=<uuid1_public_ip>
    ssh -i ~/id_rsa opc@$UUID1_INSTANCE

**Task:** Verify cloud-init has completed  
:computer: **Execute on:** Cloud Instance (UUID1_INSTANCE)

    sudo cat /var/log/cloud-init.log | grep "node is running"

:wrench: **Task:** Verify uuidservice service is running  
:computer: **Execute on:** Cloud Instance (UUID1_INSTANCE)

    sudo systemctl status uuidservice.service
    ss -nltp
    sudo firewall-cmd --list-ports
    exit

:wrench: **Task:** Test the API  
:computer: **Execute on:** Your machine

    curl -is $UUID1_INSTANCE:5000/identifiers

---
#### SECTION: Scaling out

:wrench: **Task:** Test the API on both instances  
:computer: **Execute on:** Your machine

    UUID2_INSTANCE=<uuid2_public_ip>
    curl $UUID1_INSTANCE:5000/identifiers
    curl $UUID2_INSTANCE:5000/identifiers

:wrench: **Task:** Test the load balancer listener  
:computer: **Execute on:** Your machine

    LB_INSTANCE=<load_balancer_public_ip>
    curl $LB_INSTANCE:80/identifiers
    curl $LB_INSTANCE:80/identifiers
    curl $LB_INSTANCE:80/identifiers
    curl $LB_INSTANCE:80/identifiers
