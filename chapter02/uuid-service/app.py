import flask
import uuid
import os
import socket
import logging


app = flask.Flask(__name__)


@app.route('/identifiers', methods=['GET'])
def identifiers():
    generator_name = os.getenv('UUID_GENERATOR_NAME', socket.gethostname())
    generator_uuid = uuid.uuid4()
    app.logger.info('Generator: [%s] UUID: [%s]', generator_name, generator_uuid)
    rsp = flask.jsonify(uuid=generator_uuid, generator=generator_name)
    rsp.status_code = 200
    rsp.headers['Content-Type'] = 'application/json'
    return rsp


@app.before_first_request
def setup_logging():
    logging.getLogger('werkzeug').disabled = True
    app.logger.removeHandler(flask.logging.default_handler)
    handler = logging.StreamHandler()
    handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
    app.logger.addHandler(handler)
    app.logger.setLevel(logging.INFO)
    
