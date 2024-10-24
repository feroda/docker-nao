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
    return template('templates/index', postures=postures) 

@app.route('/static/<filename:path>')
def serve_static(filename):
    return static_file(filename, root='./static')

@app.route('/qicli/<subcommand>/')
@app.route('/qicli/<subcommand>/<method>/')
def qicli(subcommand, method="--list"):
    qi_url = request.query.qi_url
    args = request.query.args.split(",") if request.query.args else []
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
