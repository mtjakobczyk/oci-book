import io
import json

from fdk import response


def handler(ctx, data: io.BytesIO=None):
    res_str = json.dumps({"message": "blank message"})
    headers_dict={"Content-Type": "application/json"}
    rsp = response.Response(ctx, response_data=res_str, headers=headers_dict)
    return rsp
