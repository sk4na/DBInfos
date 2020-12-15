#! /usr/bin/env bash

source ~soft_bio_267/initializes/init_ruby

#wget --recursive --no-parent --no-verbose --no-host-directories --level=1 --cut-dirs=1 --reject 'md5sums' --accept *.all.tsv.gz https://archive.monarchinitiative.org/202010/tsv/all_associations/
#mkdir monarch_output_data
#../../bin/graphrevealer.rb -o 'monarch_output_data/monarch_graph' -i /mnt/home/users/bio_267_uma/apareslar/projects/Db_documents/test/monarch_graph/tsv/all_associations/
../../bin/graphrevealer.rb -o 'monarch_output_data/monarch_graph' -i sample_data/
