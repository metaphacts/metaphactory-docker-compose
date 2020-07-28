#!/usr/bin/env sh

apk update
apk add curl
curl -X POST\
    http://graphdb:7200/rest/repositories\
    -H 'Content-Type: multipart/form-data'\
    -F "config=@/config/graphdb-repository-config.ttl"
