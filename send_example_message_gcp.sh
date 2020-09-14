#!/bin/bash
cd terraform_modules

if [ -z $1 ];then printf "usage:\n./send_example_message_gcp.sh [message]";exit 1; fi;

echo sending $1
URI=$(terraform show -json | jq -r '..|objects|select(.type=="google_cloud_run_service")| select(.name=="app-forwarder")|.values.status[0].url')
curl -X POST $URI -d "{\"text\": \"$1\"}" -H "Content-Type: application/json"

echo 'sleeping for two seconds (to increase likelihood of arrival).'
sleep 2

echo receiving
PROJECT_ID=$(terraform show -json | jq -r '.values.root_module.child_modules[0].resources[1].values.project')
gcloud pubsub subscriptions pull projects/$PROJECT_ID/subscriptions/data-processing-response-subscription --auto-ack
