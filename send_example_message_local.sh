#!/bin/bash
if [ -z $1 ];then printf "usage:\n./send_example_message_local.sh [message]";exit 1; fi;

echo sending $1
curl -X POST localhost:8080/ -d "{\"text\": \"$1\"}" -H "Content-Type: application/json"
