#! /usr/bin/env bash

source ~soft_bio_267/initializes/init_R

less test_case/variant_HP.txt | awk '{ print $1 }' | grep 'dbSNP' > test_case/dbsnp_list.txt

~/projects/Db_documents/bin/rsids2location.R -i test_case/dbsnp_list.txt
