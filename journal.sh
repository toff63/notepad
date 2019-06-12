#!/bin/sh
FILENAME=journal-`date +%Y%m%d`.md
DATE=`date +%Y-%m-%d`
cat > $FILENAME <<- EOM
---
date: $DATE
tags: journal
---
EOM
