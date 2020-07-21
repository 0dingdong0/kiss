#!/bin/bash
if [ ! -d "./hasura_mam" ]; then
    mkdir ./hasura_mam
    cd ./hasura_mam
    hasura init
else
    cd ./hasura_mam
fi
echo $(pwd)
echo "create migration ..."
hasura migrate create $1 --from-server --endpoint http://192.168.1.182:8080 --admin-secret tbqIwPZ_7rw
# find the version of the new created migration
for f in $(ls -c migrations); do
  version=$(echo $f | cut -d'_' -f 1)
  break
done
hasura migrate apply --endpoint=http://192.168.1.182:8080 --version $version --skip-execution --admin-secret tbqIwPZ_7rw

echo "create metadata ..."
hasura metadata export --endpoint http://192.168.1.182:8080  --admin-secret tbqIwPZ_7rw

cd ..
echo "done!"