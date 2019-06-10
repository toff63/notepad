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

<script src="https://gist.github.com/toff63/d501769a5fbde788a42056652c63240d.js"></script>
