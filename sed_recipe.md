---
date: 2019-07-17
tags: csv sed
---

## Problem
You have a file with lines like:
```
a::key1::b
c::d::key2
```

and you want to generate a csv that looks like:
```
a::key::b,key1
c::d::key2,key2
```

To extract the key you can use the sed command:
```
sed -E  's/.*(key[0-9]+).*/\1/g'
```

To extract the key and keep the original string:

```
ed -E  's/(.*(key[0-9]+).*)/\1,\2/g'
```
