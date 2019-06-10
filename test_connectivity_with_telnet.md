---
date: 2019-06-10
tag: telnet connectivity devops
---

Sometimes you want to write a script checking if the server is up. If the server ip is `172.17.0.3` and the process listens to the port `9200` you can run:

```bash
echo -e '\035\nquit' | telnet 172.17.0.3 9200 | grep Connected && echo "it's up" || echo "it's down"
```

It will print `it's up` in case of success and `it's down` in case of failure.

Another way using unix file descriptors:

```bash
echo > /dev/tcp/172.17.0.3/9200 && echo "it's up" || echo "it's down"
```

[Source](https://unix.stackexchange.com/questions/153834/test-if-telnet-port-is-active-within-a-shell-script)
