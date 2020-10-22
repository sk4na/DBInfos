#! /usr/bin/env bash

source ~soft_bio_267/initializes/init_R
source ~soft_bio_267/initializes/init_ruby

########################## FOR ANNOTATION FILE #######################
../bin/phen2dis_matcher.rb -p ../processed_data/omim_hpoa.prof -t ../processed_data/mondo.prof > mondo_to_omim_hpoa_with_match_percentages
../bin/Db_comparer.rb -m ../input_data/Hs_disease_phenotype.txt -o ../input_data/phenotype.hpoa -r ../input_data/mondo.obo -l mondo_to_omim_hpoa_with_match_percentages -k 'OMIM'| cut -f 2 > disID_equivalents_from_obo
paste mondo_to_omim_hpoa_with_match_percentages disID_equivalents_from_obo > ../output_data/hpoa_final_result
../bin/xygraph.R -d ../output_data/hpoa_final_result -o 'graph_hpoa' -x 2 -y 4
mv graph_hpoa.pdf ../output_data/graph_hpoa.pdf
########################## FOR OMIM FILE ############################
../bin/phen2dis_matcher.rb -p ../processed_data/omim.prof -t ../processed_data/mondo.prof > mondo_to_omim_with_match_percentages
../bin/Db_comparer.rb -m ../input_data/Hs_disease_phenotype.txt -o ../input_data/OMIM_ALL_FREQUENCIES_diseases_to_genes_to_phenotypes.txt -r ../input_data/mondo.obo -l mondo_to_omim_with_match_percentages -k 'OMIM'| cut -f 2 > disID_equivalents_from_obo
paste mondo_to_omim_with_match_percentages disID_equivalents_from_obo > ../output_data/omim_final_result
../bin/xygraph.R -d ../output_data/omim_final_result -o 'graph_omim' -x 2 -y 4
mv graph_omim.pdf ../output_data/graph_omim.pdf