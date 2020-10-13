#! /usr/bin/env bash

source ~soft_bio_267/initializes/init_R
source ~soft_bio_267/initializes/init_ruby

########################## FOR ANNOTATION FILE #######################
#../bin/phen2dis_matcher.rb -m Hs_disease_phenotype.txt -t phenotype.hpoa -s 'annotation' > mondo_to_omim_annot_with_match_percentages
#../bin/Db_comparer.rb -m Hs_disease_phenotype.txt -o OMIM_ALL_FREQUENCIES_diseases_to_genes_to_phenotypes.txt -r mondo.obo -l mondo_to_omim_annot_with_match_percentages -k 'OMIM'| cut -f 2 > omim_equivalents_from_obo
#paste mondo_to_omim_annot_with_match_percentages omim_equivalents_from_obo > annot_final_result
#../bin/xygraph.R -d annot_final_result -o 'graph_annot' -x 2 -y 4

########################## FOR OMIM FILE ############################
#../bin/phen2dis_matcher.rb -m Hs_disease_phenotype.txt -t OMIM_ALL_FREQUENCIES_diseases_to_genes_to_phenotypes.txt -s 'OMIM' > mondo_to_omim_with_match_percentages
#../bin/Db_comparer.rb -m Hs_disease_phenotype.txt -o OMIM_ALL_FREQUENCIES_diseases_to_genes_to_phenotypes.txt -r mondo.obo -l mondo_to_omim_with_match_percentages -k 'OMIM'| cut -f 2 > omim_equivalents_from_obo
#paste mondo_to_omim_with_match_percentages omim_equivalents_from_obo > final_result
#../bin/xygraph.R -d final_result -o 'graph_omim' -x 2 -y 4

########################## FOR HPOS FROM OBO FILE ############################
#../bin/phen2dis_matcher.rb -m Hs_disease_phenotype.txt -t mondo.obo -s 'obo' -k 'HP:' > mondo_to_HPO_with_match_percentages
#../bin/xygraph.R -d mondo_to_HPO_with_match_percentages -o 'graph_hpo' -x 2 -y 4


##### USING THE SCRIPT IN REVERSE MODE####

########################## FOR ANNOTATION FILE #######################
../bin/phen2dis_matcher.rb -m Hs_disease_phenotype.txt -t phenotype.hpoa -s 'annotation' --reverse true > mondo_to_omim_annot_with_match_percentages_rev
../bin/Db_comparer.rb -m Hs_disease_phenotype.txt -o OMIM_ALL_FREQUENCIES_diseases_to_genes_to_phenotypes.txt -r mondo.obo -l mondo_to_omim_annot_with_match_percentages_rev -k 'OMIM' --reverse true| cut -f 2 > omim_equivalents_from_obo
paste mondo_to_omim_annot_with_match_percentages_rev omim_equivalents_from_obo > annot_final_result_rev
../bin/xygraph.R -d annot_final_result_rev -o 'graph_annot_rev' -x 2 -y 4
########################## FOR OMIM FILE ############################
#../bin/phen2dis_matcher.rb -m Hs_disease_phenotype.txt -t OMIM_ALL_FREQUENCIES_diseases_to_genes_to_phenotypes.txt -s 'OMIM' --reverse true > mondo_to_omim_with_match_percentages_rev
#../bin/Db_comparer.rb -m Hs_disease_phenotype.txt -o OMIM_ALL_FREQUENCIES_diseases_to_genes_to_phenotypes.txt -r mondo.obo -l mondo_to_omim_with_match_percentages_rev -k 'OMIM' --reverse| cut -f 2 > omim_equivalents_from_obo
#paste mondo_to_omim_with_match_percentages_rev omim_equivalents_from_obo > final_result_rev
#../bin/xygraph.R -d final_result_rev -o 'graph_omim_rev' -x 2 -y 4

########################## FOR HPOS FROM OBO FILE ############################
#../bin/phen2dis_matcher.rb -m Hs_disease_phenotype.txt -t mondo.obo -s 'obo' -k 'HP:' --reverse true > mondo_to_HPO_with_match_percentages_rev
#../bin/xygraph.R -d mondo_to_HPO_with_match_percentages_rev -o 'graph_hpo_rev' -x 2 -y 4

