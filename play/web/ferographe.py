#!/usr/bin/python

import os
import json
from bottle import Bottle, run, request, response, template, static_file

from libqicli import QiCli


app = Bottle()


def my_json_response(x):
    response.content_type = "application/json"
    return json.dumps(x)


@app.route('/')
def index():
    qi_url = request.query.qi_url
    qicli = QiCli(qi_url)
    postures = qicli.call("ALRobotPosture.getPostureList")
    current_posture = qicli.call("ALRobotPosture.getPosture")
    languages = qicli.call("ALTextToSpeech.getAvailableLanguages")
    return template(
            'templates/index', 
            current_posture=current_posture,
            postures=postures,
            languages=languages) 

@app.route('/static/<filename:path>')
def serve_static(filename):
    return static_file(filename, root='./static')

@app.get('/qicli/<subcommand>/')
@app.get('/qicli/<subcommand>/<method>/')
@app.post('/qicli/<subcommand>/')
@app.post('/qicli/<subcommand>/<method>/')
def qicli(subcommand, method="--list"):
    qi_url = None
    args = []
    if request.query:
        qi_url = request.query.qi_url  # "192.168.77.102"
    if request.json:
        qi_url = request.json.get("qi_url", qi_url)
        args = request.json.get("args", [])
    qicli = QiCli(qi_url)
    if hasattr(qicli, subcommand):
        rv = getattr(qicli, subcommand)(method, *args)
    else:
        response.status = 404
        rv = 404
    return my_json_response(rv)


if __name__ == '__main__':
    kwargs = {}
    if os.getenv("DEBUG"):
        kwargs = {
            "debug": True,
            "reloader": False
        }

    app.run(host='0.0.0.0', port=8080, **kwargs)
