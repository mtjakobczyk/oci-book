#!/usr/bin/env python3
import sys
import os
import oci

def split_large_file(file_path, part_size):
    """Splits a file into parts"""
    part_list = []
    part_number = 0
    with open(file_path, 'rb') as file_stream:
        part = file_stream.read(part_size)
        while part != b"":
            part_file_path = file_path+'.part'+str(part_number)
            with open(part_file_path, 'wb') as part_stream:
                part_stream.write(part)
            part_list.append(part_file_path)
            part_number += 1
            part = file_stream.read(part_size)
    return part_list

def upload_to_oci(part_list, object_name, bucket_name, config_path, config_profile):
    """Performs a multi-part upload to OCI object storage"""
    config = oci.config.from_file(config_path, config_profile)
    client = oci.object_storage.ObjectStorageClient(config)
    storage_namespace = client.get_namespace().data

    upload_id = create_multipart_upload(storage_namespace, bucket_name, object_name, client)

    part_number = 1
    part_details_list = []
    for part in part_list:
        part_details = upload_part(storage_namespace, bucket_name, object_name, upload_id, part_number, part, client)
        part_details_list.append(part_details)
        part_number += 1

    commit_multipart_upload(storage_namespace, bucket_name, object_name, upload_id, part_details_list, client)

def create_multipart_upload(storage_namespace, bucket_name, object_name, client):
    kwargs = { "object": object_name }
    details = oci.object_storage.models.CreateMultipartUploadDetails(**kwargs)
    upload_id = client.create_multipart_upload(storage_namespace, bucket_name, details).data.upload_id
    print('Upload ID: '+upload_id)
    return upload_id

def upload_part(storage_namespace, bucket_name, object_name, upload_id, part_number, part, client):
    print('Part File: '+part)
    kwargs = {}
    with open(part, 'rb') as part_stream:
        rsp = client.upload_part(storage_namespace, bucket_name, object_name, upload_id, part_number, part_stream)
        kwargs = { "part_num": part_number, "etag": rsp.headers['ETag'] }
        print('Part ETag: '+rsp.headers['ETag'])
    return oci.object_storage.models.CommitMultipartUploadPartDetails(**kwargs)

def commit_multipart_upload(storage_namespace, bucket_name, object_name, upload_id, part_details_list, client):
    kwargs = { "parts_to_commit": part_details_list }
    details = oci.object_storage.models.CommitMultipartUploadDetails(**kwargs)
    client.commit_multipart_upload(storage_namespace, bucket_name, object_name, upload_id, details)

if __name__ == '__main__':
    filepath = str(sys.argv[1])
    part_size_mb = int(sys.argv[2])
    object_name = str(sys.argv[3])
    bucket_name = str(sys.argv[4])
    config_path = str(sys.argv[5])
    config_profile = str(sys.argv[6])
    part_list = split_large_file(filepath, part_size_mb*1024*1024)
    upload_to_oci(part_list, object_name , bucket_name, config_path, config_profile)
