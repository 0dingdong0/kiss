#!/bin/bash

cd ./hasura_mam

echo "(1/2)==>>: Nuke local metadata ..."
sudo rm -rf ./metadata/*

echo "(2/2)==>>: Pull the metadata from hasura server ..."
hasura metadata export --endpoint=http://192.168.1.182:8080

cd ..