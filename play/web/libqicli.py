import copy
import json
import subprocess


class QiCli:

    def __init__(self, qi_url=None):
        self.qi_url = qi_url
        self.qicli_args = []
        self.base_args = ["qicli"]
        if self.qi_url:
            self.base_args.append("--qi-url={}".format(self.qi_url))

    def run(self):
        print("Executing {}...".format(self.qicli_args))
        str_args = map(str, self.qicli_args)
        print("Executing {}...".format(str_args))
        output = subprocess.check_output(str_args)
        print("Output {}".format(output))
        lines = output.split("\n")
        self.outs = []
        self.warnings = []
        self.errors = []

        for line in lines:
            if line.startswith("[W] "):
                self.warnings.append(line)
            elif line.startswith("[E] "):
                self.errors.append(line)
            elif line:
                self.outs.append(line)
        return "\n".join(self.outs)
            
    def get_title_value_list(self):
        self.run()
        return [{"value": x, "title": y} for x,y in [
            line.split() for line in self.outs]
        ]

    def info(self, method="--list", *args):
        self.qicli_args = copy.copy(self.base_args)
        self.qicli_args.append("info")
        self.qicli_args.append(method) # TODO: with Service Details?
        return self.get_title_value_list()

    def call(self, method, *args):
        self.qicli_args = copy.copy(self.base_args)
        self.qicli_args.append("call")
        self.qicli_args.append(method)
        self.qicli_args += args or []
        return json.loads(self.run())


    # TODO?: def __getattr__(self, attr_name):
