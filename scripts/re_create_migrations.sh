#!/bin/bash

cd ./hasura_mam
manual_files=()

echo "(1/4)==>>: Nuke local migrations ..."
# sudo rm -rf ./migrations/*
for f in hasura_mam/migrations/*; do

  # save manual migrations to manual_files
  if [[ $f =~ [[:digit:]]+_manual_.* ]]; then
    manual_files+=( $f )
    continue
  fi

  rm -rf $f
done

echo "(2/4)==>>: Reset the migration history on postgresql server ..."
psql postgresql://hasura:hasura@192.168.1.182:5432/hasura << EOF
TRUNCATE hdb_catalog.schema_migrations;
EOF

echo "(3/4)==>>: Pull the schema from postgresql server ..."
hasura migrate create "init" --from-server --endpoint=http://192.168.1.182:8080
# find the version of the new created migration
for f in $(ls -c hasura_mam/migrations); do
  version=$(echo $f | cut -d'_' -f 1)
  break
done
hasura migrate apply --endpoint=http://192.168.1.182:8080 --version $version --skip-execution

# # update the version of manual_migrations
# echo "-->>: there are manual migrations, need to be applied manually: "
# for f in ${manual_files[@]}; do
#   timestamp=$(date +%s%3N)
#   nf=$(echo $f | sed "s/[0-9]\{13\}/$timestamp/")
#   mv $f $nf
#   echo $nf
# done

echo "(4/4)==>>: Verify the status"
hasura migrate status

cd ..