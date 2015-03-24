#!/bin/bash
set -ex

echo "$1    `hostname`" >> /etc/hosts
/usr/bin/chronos run_jar --http_port $2 --master $3 --zk_hosts $4