#!/usr/bin/env bash

docker exec -it $(docker ps | awk '/jslicensesrv/ {print $1}') /usr/bin/env bash;
