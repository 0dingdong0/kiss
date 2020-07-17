#!/bin/bash
result=$(docker ps | grep 'kiss_graphql-engine')
echo $result
if [ "$result" ]; then
  echo $result
fi