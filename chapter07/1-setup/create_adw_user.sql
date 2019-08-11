
-- Execute as ADMIN

CREATE USER sandbox_user IDENTIFIED BY "put-here-password";
GRANT dwrole TO sandbox_user;
ALTER USER SANDBOX_USER QUOTA 500M ON DATA;

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
