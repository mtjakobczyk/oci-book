### Practical Oracle Cloud Infrastructure
© Michal Jakobczyk  
Code snippets to use with Chapter 9.  
Replace `<placeholders>` with values matching your environment.  

---
#### SECTION: Serverless ➙ Developer VM

:wrench: **Task:** Provision a Dev Machine     
:computer: **Execute on:** Your machine  
:dart: **Context:** Shell with TF_VAR_* environment variables set as in ~/tfvars.env.sh  
:file_folder: `oci-book/chapter09/1-infrastructure`

    cd ~/git
    cd oci-book/chapter09/1-infrastructure
    find . \( -name "*.tf" -o -name "*.yaml" \) | sort
    source ~/tfvars.env.sh
    terraform init
    terraform apply
