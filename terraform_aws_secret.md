---
date: 2018-12-10
tags: terraform aws secret
---

## Problem

I need to store secrets and retrieve them when building my infrastructure using terraform.

## Solution

1. Use AWS secret manager to store your secret.
2. Retrieve those secrets using terraform

The following gist shows a terraform retrieving a secret by its arn giving its value to the variable `test`.

```bash
variable "region" {}
variable "access_key" {}
variable "secret_key" {}

provider "aws" {
  version    = "~> 1.25"
  region     = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}


data "aws_secretsmanager_secret" "by-arn" {
  arn = "arn:aws:secretsmanager:eu-west-1:xxxxxxx:secret:my_secret"
}

data "aws_secretsmanager_secret_version" "by-version-stage" {
  secret_id = "${data.aws_secretsmanager_secret.by-arn.id}"
}

data "external" "json" {
  program = ["echo", "${data.aws_secretsmanager_secret_version.by-version-stage.secret_string}"]
}
output "test" {value = "${data.external.json.result.test}"}
```
