# PRACTICAL ORACLE CLOUD Infrastructure
# CHAPTER 04 - Code Snippets


# SECTION: Compartments

## Get current compartment name
### bash / OCI CLI
oci iam compartment get --output table --query 'data.{Name:"name"}'

## Get compartment name by OCID
### bash / OCI CLI
oci iam compartment get -c "ocid1.compartment.oc1..aa………bpfl6q" --output table --query 'data.{Name:"name"}'

## Create compartment
### bash / OCI CLI
oci iam compartment create --name Experiments --description "Sandbox area for experiments"

## Delete compartment
### bash / OCI CLI
oci iam compartment delete -c ocid1.compartment.oc1..aa………qhslia


# SECTION: Users

## Create a user and output its newly assigned OCID
### bash / OCI CLI
TENANCY_OCID=ocid1.tenancy.oc1..aaaaaaaaq26………
oci iam user create --name sandbox-user --description "Sandbox user" --query "data.id" -c $TENANCY_OCID

## List existing users whose names start with "sandbox"
### bash / OCI CLI
oci iam user list -c $TENANCY_OCID --query "data [?starts_with(name,'sandbox')].name" --all

## Generate password for a given user
### bash / OCI CLI
USER_OCID=ocid1.user.oc1..aa………dzqpxa
oci iam user ui-password create-or-reset --user-id $USER_OCID --query "data.password"

## Generate API Signing keys for both users
### bash
mkdir ~/apikeys
cd ~/apikeys
openssl genrsa -out api.sandbox-user.pem -aes128 2048
chmod go-r api.sandbox-user.pem
openssl rsa -pubout -in api.sandbox-user.pem -out api.sandbox-user.pem.pub
openssl genrsa -out api.sandbox-admin.pem -aes128 2048
chmod go-r api.sandbox-admin.pem
openssl rsa -pubout -in api.sandbox-admin.pem -out api.sandbox-admin.pem.pub
ls -l | awk '{print $1, $9}'

## Find user OCID by name
### bash / OCI CLI
echo $TENANCY_OCID
oci iam user list -c $TENANCY_OCID --query "data[?name=='sandbox-admin'].{OCID:id,Name:name}" --all

## Upload API Signing key for a user
### bash / OCI CLI
USER_OCID=ocid1.user.oc1..aa………7d5dca
oci iam user api-key upload --user-id $USER_OCID --key-file ~/apikeys/api.sandbox-admin.pem.pub --query "data.fingerprint"

## Testing insufficient credentials for sandbox-admins (through the SANDBOX-ADMIN profile)
### bash / OCI CLI
oci iam user list -c $TENANCY_OCID --query "data [?starts_with(name,'sandbox')].name" --all --profile SANDBOX-ADMIN


# SECTION: Groups and Policies

## Create a group
### bash / OCI CLI
oci iam group create --name sandbox-users --description "Group for the regular users of the Sandbox compartment" --query "data.id" -c $TENANCY_OCID

## List existing groups
### bash / OCI CLI
oci iam group list -c $TENANCY_OCID --all --query "data[?starts_with(name,'sandbox')].{Name:name,OCID:id}" --output table

## Find user OCID by name
### bash / OCI CLI
oci iam user list -c $TENANCY_OCID --query "data[?name=='sandbox-admin'].{Name:name,OCID:id}" --all

## Find group OCID by name
### bash / OCI CLI
oci iam group list -c $TENANCY_OCID --query "data[?name=='sandbox-admins'].{Name:name,OCID:id}" --all

## Add a user to a group
### bash / OCI CLI
USER_OCID=ocid1.user.oc1..aa………7d5dca
GROUP_OCID=ocid1.group.oc1..aa………hlotwa
oci iam group add-user --user-id $USER_OCID --group-id $GROUP_OCID

## List group users
### bash / OCI CLI
oci iam group list-users --group-id $GROUP_OCID --query "data[*].name" -c $TENANCY_OCID --all


# SECTION: Policies

## List policies and the number of statements for each
### bash / OCI CLI
oci iam policy list -c $TENANCY_OCID --all --query 'data[*].{Name:name,Statements:length(statements)}' --output table

## List policy statements
### bash / OCI CLI
oci iam policy list -c $TENANCY_OCID --all --query "data[?name=='Tenant Admin Policy'].statements[0]"

## Create a new policy
### bash / OCI CLI
oci iam policy create -c $TENANCY_OCID --name sandbox-admins-policy --description "Policy for the Sandbox compartment admins group"  --statements '["allow group sandbox-admins to manage all-resources in compartment Sandbox"]'

## Test credentials for sandbox-admins (through the SANDBOX-ADMIN profile)
### bash / OCI CLI
oci lb shape list --profile SANDBOX-ADMIN --query 'data[*].name'

## Test insufficient credentials for sandbox-users (through the SANDBOX-USER profile)
### bash / OCI CLI
oci lb shape list --profile SANDBOX-USER --query 'data[*].name'

## Create a new policy from file
### bash / OCI CLI
oci iam policy create --profile SANDBOX-ADMIN --name sandbox-users-policy --description "Policy for regular Sandbox compartment users"  --statements "file://~/sandbox-user-policy.json"

## List policy statements
### bash / OCI CLI
oci iam policy list --profile SANDBOX-ADMIN --all --query "data[*].{Name:name,Statements:statements}"

## Test credentials for sandbox-users (through the SANDBOX-USER profile)
### bash / OCI CLI
oci lb shape list --profile SANDBOX-USER --query 'data[*].name'


# SECTION: Audit and Search

## Run free-text search
### bash / OCI CLI
oci search resource free-text-search --text sandbox --query 'data.items[*].{Type:"resource-type",Name:"display-name",OCID:"identifier",State:"lifecycle-state"}'

## Run structured search to list RUNNING and TERMINATING instances in a particular compartment
### bash / OCI CLI
oci search resource structured-search --query-text "query instance resources where ( lifeCycleState = 'RUNNING' || lifeCycleState = 'TERMINATING' ) && compartmentId = 'ocid1.compartment.oc1..aa………gzwhsa'"

## Run structured search to list users and groups matching given term
### bash / OCI CLI
oci search resource structured-search --query-text "query user, group resources matching 'sandbox-'" --query 'data.items[*].{Type:"resource-type",Name:"display-name",OCID:"identifier"}'

## Searching with pagination
### bash / OCI CLI
oci search resource free-text-search --text sandbox --query '{results:data.items[*].{Type:"resource-type",Name:"display-name",OCID:"identifier",State:"lifecycle-state"}, “opc-next-page”:"opc-next-page"}' --limit 3
oci search resource free-text-search --text sandbox --query '{results:data.items[*].{Type:"resource-type",Name:"display-name",OCID:"identifier",State:"lifecycle-state"}, “opc-next-page”:"opc-next-page"}' --limit 3 --page "eyJhbGciOiJ.........PSDALjGcOY"
