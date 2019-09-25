### Practical Oracle Cloud Infrastructure
© Michal Jakobczyk  
Code snippets to use with Chapter 3.  
Replace `<placeholders>` with values matching your environment.  

---
#### SECTION: Cloud Management Plane ➙ API Signing Key

:wrench: **Task:** Generate API Signing Key  
:computer: **Execute on:** Your machine

    mkdir ~/.apikeys
    cd ~/.apikeys
    openssl genrsa -out oci_api_pem -aes128 2048

---
