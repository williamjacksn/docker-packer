import json
import os
import pathlib
import ruamel.yaml
import subprocess
import sys
import tempfile


def read_json_file(path: str):
    path = pathlib.Path(path).resolve()
    with path.open() as f:
        return json.load(f)


def read_yaml_file(path: str):
    path = pathlib.Path(path).resolve()
    with path.open() as f:
        yaml = ruamel.yaml.YAML(typ='safe')
        return yaml.load(f)


def main():
    packer_cmd = list(sys.argv)
    if len(packer_cmd) > 0 and packer_cmd[1] == 'to_yaml':
        source = packer_cmd[2]
        template = read_json_file(source)
        yaml = ruamel.yaml.YAML(typ='safe')
        yaml.default_flow_style = False
        yaml.dump(template, sys.stdout)
    elif len(packer_cmd) > 0 and packer_cmd[1] == 'to_json':
        source = packer_cmd[2]
        template = read_yaml_file(source)
        json.dump(template, sys.stdout, indent=2)
    else:
        packer_cmd[0] = '/home/python/docker-packer/packer'
        for i, arg in enumerate(packer_cmd):
            arg_lower = arg.lower()
            if arg_lower.endswith('.yml') or arg_lower.endswith('.yaml'):
                tmp = tempfile.NamedTemporaryFile(mode='w', suffix='.json', prefix='packer-', dir=os.getcwd())
                packer_cmd[i] = tmp.name
                template = read_yaml_file(arg)
                json.dump(template, tmp, indent=2)
                tmp.flush()
        subprocess.run(packer_cmd)


if __name__ == '__main__':
    main()
