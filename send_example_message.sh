#!/bin/bash
curl -X POST localhost:8080/ -d '{"text": "will this be forwarded to a data-processor via pubsub?"}' -H "Content-Type: application/json"
