#! /usr/bin/env bash

source ~soft_bio_267/initializes/init_R
source ~soft_bio_267/initializes/init_ruby

########################## FOR ANNOTATION FILE #######################
#../bin/phen2dis_matcher.rb -m Hs_disease_phenotype.txt -t phenotype_annotation.tab -s 'annotation' > mondo_to_omim_annot_with_match_percentages
#../bin/Db_comparer.rb -m Hs_disease_phenotype.txt -o OMIM_ALL_FREQUENCIES_diseases_to_genes_to_phenotypes.txt -r mondo.obo -l mondo_to_omim_annot_with_match_percentages -k 'OMIM'| cut -f 2 > omim_equivalents_from_obo
#paste mondo_to_omim_annot_with_match_percentages omim_equivalents_from_obo > annot_final_result
#../bin/xygraph.R -d annot_final_result -o 'graph_annot' -x 2 -y 4

########################## FOR OMIM FILE ############################
# ../bin/phen2dis_matcher.rb -m Hs_disease_phenotype.txt -t OMIM_ALL_FREQUENCIES_diseases_to_genes_to_phenotypes.txt -s 'OMIM' > mondo_to_omim_with_match_percentages
#../bin/Db_comparer.rb -m Hs_disease_phenotype.txt -o OMIM_ALL_FREQUENCIES_diseases_to_genes_to_phenotypes.txt -r mondo.obo -l mondo_to_omim_with_match_percentages -k 'OMIM'| cut -f 2 > omim_equivalents_from_obo
#paste mondo_to_omim_with_match_percentages omim_equivalents_from_obo > final_result
#../bin/xygraph.R -d final_result -o 'graph_omim' -x 2 -y 4

########################## FOR HPOS FROM OBO FILE ############################
../bin/phen2dis_matcher.rb -m Hs_disease_phenotype.txt -t mondo.obo -s 'obo' -k 'HP:' > mondo_to_HPO_with_match_percentages
../bin/xygraph.R -d mondo_to_HPO_with_match_percentages -o 'graph_hpo' -x 2 -y 4