---
date: 2019-06-11
tags: jq json
---

Sometimes you want to filter a json and only take a part of it.

Let's say you have this json:

```json
{
   "list":[
      {
         "a":"b",
         "c":"d",
         "e": "f"
      },
      {
         "a":"g",
         "c":"h",
         "e": "i"
      },
      {
         "a":"b",
         "c":"d",
         "e": "i"
      }
   ]
}
```

You only want the objects where the key `a` had the value `"b"`. You are not interested in the key `c`, you only want the key `e`.

You can achieve this by using the jq expression: `.list[] | {a, e} | select(.a == "b")`
* `.list[]` filters to only return its array content.
* `{a, e}` is the equivalent to a `map` in functional programming and only select those keys
* `select(.a == "b")` will only keep objects where the key `a` has the value `"b"`

The result is

```json
{
  "a": "b",
  "e": "f"
}
{
  "a": "b",
  "e": "i"
}

```
You can play and adapt the json to your reality in [jq playground](https://jqplay.org/s/A-coPyznVo)
