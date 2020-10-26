#! /usr/bin/env bash

source ~soft_bio_267/initializes/init_R
source ~soft_bio_267/initializes/init_ruby

########################## FOR MAKING .PROF FILES #######################
#../bin/profiler.rb -f ../input_data/Hs_disease_phenotype.txt -t tsv -k 'MONDO' -d 0 -p 1 > ../processed_data/mondo.prof
#../bin/profiler.rb -f ../input_data/phenotype.hpoa -t tsv -k 'OMIM' -d 0 -p 3 > ../processed_data/omim_hpoa.prof
#../bin/profiler.rb -f ../input_data/OMIM_ALL_FREQUENCIES_diseases_to_genes_to_phenotypes.txt -t tsv -k 'OMIM' -d 0 -p 3 > ../processed_data/omim.prof
#../bin/profiler.rb -f ../input_data/disease_phenotype.all.tsv -t tsv -k 'MONDO' -d 0 -p 4 > ../processed_data/mondo_new.prof