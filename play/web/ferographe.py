#!/usr/bin/python

import os
import json
from bottle import Bottle, run, request, response

from libqicli import QiCli


app = Bottle()


def my_json_response(x):
    response.content_type = "application/json"
    return json.dumps(x)


@app.route('/hello')
def hello():
    return "Hello World!"


@app.route('/qicli/<subcommand>/')
@app.route('/qicli/<subcommand>/<method>/')
def qicli(subcommand, method="--list"):
    qi_url = request.query.qi_url
    args = request.query.args.split(",")
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
