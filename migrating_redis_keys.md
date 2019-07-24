---
date: 2019-07-24
tags: redis
---

# Migrate keys from 1 redis to another

To test the script I started a redis server locally and created db 2 where I created 2 keys and added a ttl on one.
The script is supposed to migrate those two keys from db 2 to db1 without loosing the data and the ttl. The redis commands for that are DUMP and RESTORE.

## Script for few keys

```bash
#!/bin/bash -x

KEYS="sidekiq:stat:processed:2017-10-26 sidekiq:stat:failed:2016-06-03"
ORIG_DB=2
ORIG_HOST=localhost
DST_DB=1
DST_HOST=localhost

for key in $KEYS
do
_ttl=$(redis-cli -n $ORIG_DB -h $ORIG_HOST PTTL $key | sed 's/-1/0/')
redis-cli -n $ORIG_DB -h $ORIG_HOST --raw dump $key | head -c-1 | redis-cli -n $DST_DB -h $DST_HOST -x restore $key $_ttl
done
```

It gets the ttl first using the command [PTTL](https://redis.io/commands/pttl) and change -1 responses into 0 as the restore command expect 0 when there is no ttl while PTTL returns -1 in this case.
Then I use [stackoverflow response](https://stackoverflow.com/a/16129052) to dump and restore a key using redis-cli.

## Executing the script

```bash
➜  one-redis ./dump.sh
+ KEYS='sidekiq:stat:processed:2017-10-26 sidekiq:stat:failed:2016-06-03'
+ ORIG_DB=2
+ ORIG_HOST=localhost
+ DST_DB=1
+ DST_HOST=localhost
+ for key in $KEYS
++ redis-cli -n 2 -h localhost PTTL sidekiq:stat:processed:2017-10-26
++ sed s/-1/0/
+ _ttl=6712820 
+ redis-cli -n 2 -h localhost --raw dump sidekiq:stat:processed:2017-10-26
+ head -c-1
+ redis-cli -n 1 -h localhost -x restore sidekiq:stat:processed:2017-10-26 6712820
OK
+ for key in $KEYS
++ redis-cli -n 2 -h localhost PTTL sidekiq:stat:failed:2016-06-03
++ sed s/-1/0/
+ _ttl=0
+ redis-cli -n 2 -h localhost --raw dump sidekiq:stat:failed:2016-06-03
+ head -c-1
+ redis-cli -n 1 -h localhost -x restore sidekiq:stat:failed:2016-06-03 0
OK
```

## Validating the results

```bash
➜  one-redis redis-cli -n 1
127.0.0.1:6379[1]> scan 0
1) "0"
2) 1) "sidekiq:stat:failed:2016-06-03"
   2) "sidekiq:stat:processed:2017-10-26"
127.0.0.1:6379[1]> PTTL sidekiq:stat:failed:2016-06-03
(integer) -1
127.0.0.1:6379[1]> PTTL sidekiq:stat:processed:2017-10-26
(integer) 6653537
127.0.0.1:6379[1]> get  sidekiq:stat:failed:2016-06-03
"1"
127.0.0.1:6379[1]> get sidekiq:stat:processed:2017-10-26
"13189797"
127.0.0.1:6379[1]> exit
➜  one-redis redis-cli -n 2
127.0.0.1:6379[2]> PTTL sidekiq:stat:failed:2016-06-03
(integer) -1
127.0.0.1:6379[2]> PTTL sidekiq:stat:processed:2017-10-26
(integer) 6630439
127.0.0.1:6379[2]> get  sidekiq:stat:failed:2016-06-03
"1"
127.0.0.1:6379[2]>  get sidekiq:stat:processed:2017-10-26
"13189797"
127.0.0.1:6379[2]> exit
```

# Script for a database

To migrate a whole database we can adapt the script above by changing the for loop:

```bash
#!/bin/bash -x

ORIG_DB=2
ORIG_HOST=localhost
DST_DB=1
DST_HOST=localhost

for key in $(redis-cli -n $ORIG_DB -h $ORIG_HOST --scan)
do
        _ttl=$(redis-cli -n $ORIG_DB -h $ORIG_HOST PTTL $key | sed 's/-1/0/')
        redis-cli -n $ORIG_DB -h $ORIG_HOST --raw dump $key | head -c-1 | redis-cli -n $DST_DB -h $DST_HOST -x restore $key $_ttl
done
```
This time we scan all db keys.

```
➜  one-redis redis-cli info keyspace
# Keyspace
db1:keys=1717,expires=1,avg_ttl=6046762
db2:keys=1717,expires=1,avg_ttl=6047350
```
You will notice the average ttl is slightly off but the number of keys is exactly the same.
