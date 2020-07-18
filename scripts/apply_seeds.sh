#!/bin/bash
psql -U 'hasura' -h 192.168.1.182 -d 'hasura' -a -f hasura_mam/seeds/001_staff.sql