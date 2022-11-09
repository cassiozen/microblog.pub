#!/bin/sh
inv migrate-db
mkdir data/uploads
exec supervisord -c misc/docker-supervisord.conf
