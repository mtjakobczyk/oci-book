import io
import json
import uuid

from fdk import response


def handler(ctx, data: io.BytesIO=None):
    res_dict = {}
    try:
        # Generate UUID
        res_dict["generator_uuid"] = str(uuid.uuid4())
        # Intercept input and prepare optional response part
        if data is not None:
            data_bytes = data.getvalue()
            if len(data_bytes)>0:
                data_json = json.loads(data_bytes)
                res_dict["generator_client"] = data_json.get("client_name")
    except (Exception, ValueError) as ex:
        res_dict["message"] = str(ex)

    headers_dict={"Content-Type": "application/json"}
    res_str = json.dumps(res_dict)
    rsp = response.Response(ctx, response_data=res_str, headers=headers_dict)
    return rsp
