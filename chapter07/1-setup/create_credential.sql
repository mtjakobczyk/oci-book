
BEGIN
  DBMS_CLOUD.CREATE_CREDENTIAL(
    credential_name => 'OCI_SANDBOX_USER',
    username => 'sandbox-user',
    password => 'put-here-auth-token'
  );
END;
