import io
import os
import json
import uuid
import oci

from fdk import response
from io import StringIO


def extract_object_name(data: io.BytesIO):
    data_bytes = data.getvalue()
    data_json = json.loads(data_bytes)
    object_name = data_json['data']['resourceName']
    return object_name


def load_object_content(client, storage_namespace, bucket_name, object_name):
    res = client.get_object(storage_namespace, bucket_name, object_name)
    # Response uses oci._vendor.urllib3.response.HTTPResponse
    httpresponse = res.data.raw
    data_bytes = b''
    for chunk in httpresponse.stream(4096):
        data_bytes += chunk
    return data_bytes.decode('UTF-8')


def process_city_attendance_data(object_content_str):
    city_attendance_str = "city,attendance" + os.linesep
    city_attendance_dict = {}
    for line in object_content_str.splitlines():
        line_list = line.split(',')
        city = line_list[1]
        if city_attendance_dict.get(city) is None:
            city_attendance_dict[city] = 0
        attendance = int(line_list[2])
        city_attendance_dict[city] += attendance
    for city,attendance in city_attendance_dict.items():
        city_attendance_str += city + ',' + str(attendance) + os.linesep
    return city_attendance_str


def put_city_attendance_object(client, storage_namespace, bucket_name, object_name, city_attendance_str):
    object_content_stream = StringIO(str(city_attendance_str))
    rsp = client.put_object(storage_namespace, bucket_name, object_name, object_content_stream)
    return rsp


def prepare_function_response(ctx, res_dict, headers_dict):
    res_str = json.dumps(res_dict)
    rsp = response.Response(ctx, response_data=res_str, headers=headers_dict)
    return rsp


def handler(ctx, data: io.BytesIO=None):
    res_dict = {}
    headers_dict={"Content-Type": "application/json"}

    if data is None or not len(data.getvalue())>0:
        res_dict["message"] = "no data received"
        return prepare_function_response(ctx, res_dict, headers_dict)

    try:
        # Process input
        bucket_name = "reports"
        object_name = extract_object_name(data)
        # Process only .raw.csv
        if not str(object_name).endswith('.raw.csv'):
            res_dict["object_name"] = object_name
            res_dict["result"] = "ignoring"
            return prepare_function_response(ctx, res_dict, headers_dict)

        # Authenticate the function instance as an instance principal
        signer = oci.auth.signers.get_resource_principals_signer()
        client = oci.object_storage.ObjectStorageClient(config={}, signer=signer)
        storage_namespace = client.get_namespace().data

        object_content_str = load_object_content(client, storage_namespace, bucket_name, object_name)
        city_attendance_str = process_city_attendance_data(object_content_str)

        processed_object_name = object_name.replace('.raw.csv','.processed.csv')
        put_response = put_city_attendance_object(client, storage_namespace, bucket_name, processed_object_name, city_attendance_str)

        res_dict["object_name"] = object_name
        res_dict["processed_object_name"] = processed_object_name
        res_dict["result"] = "success"
    except (Exception, ValueError) as ex:
        res_dict["result"] = "error"
        res_dict["reason"] = str(ex)

    return prepare_function_response(ctx, res_dict, headers_dict)
