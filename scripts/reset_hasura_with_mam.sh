#!/bin/bash
if [ $(docker ps | grep 'kiss_graphql-engine' | wc -l) -gt 0 ]; then
  echo "==>>: try to stop dockers ..."
  docker-compose down
fi

echo "==>>: try to remove containers ..."
docker container rm $(docker container ls -aq)

echo "==>>: remove & re_create kiss/db_data ..."
sudo rm -rf ./db_data
mkdir db_data

echo "==>>: run containers ..."
docker-compose up -d


while [ true ]
do
  echo "==>>: create user hasura and databse hasura ..."
  psql postgresql://postgres:postgrespassword@192.168.1.182:5432/postgres << '  EOF'
    CREATE USER hasura WITH PASSWORD 'hasura';
    ALTER USER hasura WITH SUPERUSER;
    CREATE DATABASE hasura;
    GRANT ALL PRIVILEGES ON DATABASE hasura TO hasura;
  EOF

  if [ $? -eq 0 ]; then
    break
  fi

  echo "==>>: wait 5 seconds ... "
  sleep 5

done

echo '==>>: restart containers ...'
docker-compose restart 


while [ true ]
do
  echo "==>>: alter database user with nosuperuser ..."
  psql postgresql://postgres:postgrespassword@192.168.1.182:5432/postgres << '  EOF'
    ALTER USER hasura WITH NOSUPERUSER;
  EOF

  if [ $? -eq 0 ]; then
    break
  fi

  echo "==>>: wait 5 seconds ... "
    sleep 5

done


echo "==>>: apply hasura migrate & metadata ..."

cd ./hasura_mam

hasura migrate apply --endpoint "http://192.168.1.182:8080" --admin-secret tbqIwPZ_7rw
sleep 2
sudo hasura metadata apply --endpoint "http://192.168.1.182:8080" --admin-secret tbqIwPZ_7rw

cd ..
