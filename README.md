# docker-packer

A Docker image for [hashicorp/packer][a].

[a]: https://github.com/hashicorp/packer

HashiCorp already provides [an official Docker image for Packer][b], so why make another? Easy: this one supports YAML
template files.

[b]: https://hub.docker.com/r/hashicorp/packer

That&#x02bc;s right, forget about JSON and HCL and write your Packer templates with YAML instead.

## Getting started

Here is an example of how to run `packer` from this image:

```sh
/path/to/packer/templates> docker container run --rm -it ghcr.io/williamjacksn/packer:1.6.6 --help
Usage: packer [--version] [--help] <command> [<args>]

Available commands are:
    build       build image(s) from template
    console     creates a console for testing variable interpolation
    fix         fixes templates from old versions of packer
    inspect     see components of a template
    validate    check that a template is valid
    version     Prints the Packer version
```

For convenience, the rest of the commands in this introduction will be run using `docker-compose` and the following
Compose file:

```yaml
version: '3.8'

services:
  packer:
    image: ghcr.io/williamjacksn/packer:1.6.6
    volumes:
      - /path/to/packer/templates:/workdir
    working_dir: /workdir
```

and the following example template file from [the Packer Getting Started guide][c]:

[c]: https://www.packer.io/intro/getting-started/build-image/#the-template

```json
{
  "variables": {
    "aws_access_key": "",
    "aws_secret_key": ""
  },
  "builders": [
    {
      "type": "amazon-ebs",
      "access_key": "{{user `aws_access_key`}}",
      "secret_key": "{{user `aws_secret_key`}}",
      "region": "us-east-1",
      "source_ami_filter": {
        "filters": {
          "virtualization-type": "hvm",
          "name": "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*",
          "root-device-type": "ebs"
        },
        "owners": ["099720109477"],
        "most_recent": true
      },
      "instance_type": "t2.micro",
      "ssh_username": "ubuntu",
      "ami_name": "packer-example {{timestamp}}"
    }
  ]
}
```

## Converting templates

In addition to the regular `packer` commands, this image introduces two new commands to translate template files between
JSON and YAML.

### Convert a JSON template to YAML

```sh
/path/to/packer/templates> docker-compose run packer to_yaml example.pkr.json > example.pkr.yaml

/path/to/packer/templates> cat example.pkr.yaml
builders:
- access_key: '{{user `aws_access_key`}}'
  ami_name: packer-example {{timestamp}}
  instance_type: t2.micro
  region: us-east-1
  secret_key: '{{user `aws_secret_key`}}'
  source_ami_filter:
    filters:
      name: ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*
      root-device-type: ebs
      virtualization-type: hvm
    most_recent: true
    owners:
    - '099720109477'
  ssh_username: ubuntu
  type: amazon-ebs
variables:
  aws_access_key: ''
  aws_secret_key: ''
```

### Convert a YAML template back to JSON

```sh
/path/to/packer/templates> docker-compose run packer to_json example.pkr.yaml
{
  "builders": [
    {
      "access_key": "{{user `aws_access_key`}}",
      "ami_name": "packer-example {{timestamp}}",
      "instance_type": "t2.micro",
      "region": "us-east-1",
      "secret_key": "{{user `aws_secret_key`}}",
      "source_ami_filter": {
        "filters": {
          "name": "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*",
          "root-device-type": "ebs",
          "virtualization-type": "hvm"
        },
        "most_recent": true,
        "owners": [
          "099720109477"
        ]
      },
      "ssh_username": "ubuntu",
      "type": "amazon-ebs"
    }
  ],
  "variables": {
    "aws_access_key": "",
    "aws_secret_key": ""
  }
}
```

## Usage

With your template file in YAML format, all the usual `packer` commands work as expected.

### `inspect`

```sh
/path/to/packer/templates> docker-compose run packer inspect example.pkr.yaml
Optional variables and their defaults:

  aws_access_key =
  aws_secret_key =

Builders:

  amazon-ebs

Provisioners:

  <No provisioners>

Note: If your build names contain user variables or template
functions such as 'timestamp', these are processed at build time,
and therefore only show in their raw form here.
```

### `validate`

```sh
/path/to/packer/templates> docker-compose run packer validate example.pkr.yaml
Template validated successfully.
```

### `build`

```sh
/path/to/packer/templates> docker-compose run packer build \
    -var 'aws_access_key=YOUR ACCESS KEY' \
    -var `aws_secret_key=YOUR SECRET KEY' \
    example.pkr.yaml
amazon-ebs output will be in this color.

==> amazon-ebs: Prevalidating AMI Name: packer-example 1575909162
    amazon-ebs: Found Image ID: ami-09f9d773751b9d606
==> amazon-ebs: Creating temporary keypair: packer_5dee772a-658b-a6cb-3663-156e8b35516d
==> amazon-ebs: Creating temporary security group for this instance: packer_5dee772d-6d99-30c3-4e49-f74f7e048a5c
==> amazon-ebs: Authorizing access to port 22 from [98.6.145.218/32] in the temporary security groups...
==> amazon-ebs: Launching a source AWS instance...
==> amazon-ebs: Adding tags to source instance
    amazon-ebs: Adding tag: "Name": "Packer Builder"
    amazon-ebs: Instance ID: i-0b05f206048847631
==> amazon-ebs: Waiting for instance (i-0b05f206048847631) to become ready...
==> amazon-ebs: Using ssh communicator to connect: 3.218.142.191
==> amazon-ebs: Waiting for SSH to become available...
==> amazon-ebs: Connected to SSH!
==> amazon-ebs: Stopping the source instance...
    amazon-ebs: Stopping instance
==> amazon-ebs: Waiting for the instance to stop...
==> amazon-ebs: Creating AMI packer-example 1575909162 from instance i-0b05f206048847631
    amazon-ebs: AMI: ami-0145c1c20c7f11109
==> amazon-ebs: Waiting for AMI to become ready...
==> amazon-ebs: Terminating the source AWS instance...
==> amazon-ebs: Cleaning up any extra volumes...
==> amazon-ebs: No volumes to clean up, skipping
==> amazon-ebs: Deleting temporary security group...
==> amazon-ebs: Deleting temporary keypair...
Build 'amazon-ebs' finished.

==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs: AMIs were created:
us-east-1: ami-0145c1c20c7f11109
```

## How it works

This image works by wrapping the `packer` command in a Python script. The script checks the argument list for values
that end in `.yaml` or `.yml`. If it finds such an argument, it converts the contents to JSON then writes that JSON to a
temporary file in the current working directory. The script then invokes `packer`, replacing the YAML file in the
argument list with the new temporary JSON file.

After the `packer` command completes, the script deletes the temporary JSON file.
