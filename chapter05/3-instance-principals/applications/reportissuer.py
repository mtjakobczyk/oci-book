#!/usr/bin/env python3
import datetime
import time
import uuid
import os
import sys
import oci

def prepare_report_entries(storage_namespace, bucket_name, object_prefix, client):
    report_entries = []
    objects = client.list_objects(storage_namespace, bucket_name, fields="name,size", prefix=object_prefix).data.objects
    for obj in objects:
        entry = str(obj.name)+' ('+str(obj.size/1024)+'K)'
        report_entries.append(entry)
    return report_entries

def upload_report(report_entry_list, tmp_directory, storage_namespace, bucket_name, object_name, client):
    tmp_report_filename = tmp_directory+'/bucket_report.'+str(uuid.uuid4())+'.txt'
    with open(tmp_report_filename, 'w') as stream:
        for entry in report_entry_list:
            stream.write(entry+'\n')
        report_timestamp_str = '### Report generated '+str(datetime.datetime.now())+'\n'
        stream.write(report_timestamp_str)
        print(report_timestamp_str)
    with open(tmp_report_filename, 'r') as stream:
        client.put_object(storage_namespace, bucket_name, object_name, stream)
    os.remove(tmp_report_filename)

if __name__ == '__main__':
    bucket_name = os.environ['APP_BUCKET_NAME']
    summary_object_name = os.environ['APP_OBJECT_NAME']
    object_prefix = os.environ['APP_OBJECT_PREFIX']
    polling_interval_seconds = int(os.environ['APP_POLLING_INTERVAL_SECONDS'])
    tmp_directory = os.environ['HOME']
    while True:
        print('Creating a report')
        signer = oci.auth.signers.InstancePrincipalsSecurityTokenSigner()
        client = oci.object_storage.ObjectStorageClient(config={}, signer=signer)
        storage_namespace = client.get_namespace().data
        report_entry_list = prepare_report_entries(storage_namespace, bucket_name, object_prefix, client)
        upload_report(report_entry_list, tmp_directory, storage_namespace, bucket_name, summary_object_name, client)
        time.sleep(polling_interval_seconds)
