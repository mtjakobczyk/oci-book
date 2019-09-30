### Practical Oracle Cloud Infrastructure
© Michal Jakobczyk  
Code snippets to use with Chapter 6.  
Replace `<placeholders>` with values matching your environment.  

---
#### SECTION: Virtual Networking Public IPs

:wrench: **Task:** Create a reserved public IP address   
:computer: **Execute on:** Your machine

    oci network public-ip create --lifetime RESERVED --display-name another-ip --profile SANDBOX-ADMIN
