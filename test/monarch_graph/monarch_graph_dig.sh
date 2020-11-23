#! /usr/bin/env bash

source ~soft_bio_267/initializes/init_ruby

#wget --recursive --no-parent --no-verbose --no-host-directories --level=1 --cut-dirs=1 --reject 'md5sums' --accept *.all.tsv.gz https://archive.monarchinitiative.org/202010/tsv/all_associations/

../bin/graphrevealer.rb -o 'monarch_graph'
mv ./tsv/all_associations/monarch_graph.png ../output_data/