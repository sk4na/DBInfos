#! /usr/bin/env bash

source ~soft_bio_267/initializes/init_R
source ~soft_bio_267/initializes/init_ruby

########################## FOR ANNOTATION FILE #######################
#../bin/profiler.rb -f Hs_disease_phenotype.txt -t tsv -k 'MONDO' > mondo.prof
#../bin/profiler.rb -f phenotype.hpoa -t tsv -k 'OMIM' > omim_hpoa.prof
#../bin/phen2dis_matcher.rb -m mondo.prof -t omim_hpoa.prof > mondo_to_omim_hpoa_with_match_percentages
#../bin/Db_comparer.rb -m Hs_disease_phenotype.txt -o phenotype.hpoa -r mondo.obo -l mondo_to_omim_hpoa_with_match_percentages -k 'OMIM'| cut -f 2 > disID_equivalents_from_obo
#paste mondo_to_omim_hpoa_with_match_percentages disID_equivalents_from_obo > hpoa_final_result
#../bin/xygraph.R -d hpoa_final_result -o 'graph_hpoa' -x 2 -y 4

########################## FOR OMIM FILE ############################
#../bin/profiler.rb -f Hs_disease_phenotype.txt -t tsv -k 'MONDO' > mondo.prof
#../bin/profiler.rb -f OMIM_ALL_FREQUENCIES_diseases_to_genes_to_phenotypes.txt -t tsv -k 'OMIM' > omim.prof
#../bin/phen2dis_matcher.rb -m mondo.prof -t omim.prof > mondo_to_omim_with_match_percentages
#../bin/Db_comparer.rb -m Hs_disease_phenotype.txt -o OMIM_ALL_FREQUENCIES_diseases_to_genes_to_phenotypes.txt -r mondo.obo -l mondo_to_omim_with_match_percentages -k 'OMIM'| cut -f 2 > disID_equivalents_from_obo
#paste mondo_to_omim_with_match_percentages disID_equivalents_from_obo > omim_final_result
#../bin/xygraph.R -d omim_final_result -o 'graph_omim' -x 2 -y 4
########################## FOR HPOS FROM OBO FILE ############################
#../bin/profiler.rb -f Hs_disease_phenotype.txt -t tsv -k 'MONDO' > mondo.prof
#../bin/profiler.rb -f mondo.obo -t obo -k 'HP:' > obo.prof
#../bin/phen2dis_matcher.rb -m mondo.prof -t obo.prof > mondo_to_HPO_with_match_percentages
#../bin/xygraph.R -d mondo_to_HPO_with_match_percentages -o 'graph_hpo_obo' -x 2 -y 4
