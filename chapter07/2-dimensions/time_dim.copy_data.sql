
BEGIN
  DBMS_CLOUD.COPY_DATA(
    table_name => 'TIME_DIM',
    credential_name => 'OCI_SANDBOX_USER',
    file_uri_list => 'https://objectstorage.<region>.oraclecloud.com/n/<namespace>/b/roadadw-load/o/time_dim.csv',
    format => json_object(
      'type' value 'CSV',
      'skipheaders' value '1',
      'blankasnull' value 'true',
      'dateformat' value 'YYYY-MM-DD')
  );
END;
